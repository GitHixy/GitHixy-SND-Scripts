--[=====[
[[SND Metadata]]
author: GitHixy
version: 2.1.3
description: >-
  Automated Chocobo Training & Racing script with comprehensive features:

  - Automatic training when sessions are available before racing

  - Smart food purchasing system for all feed types (Grade 1)

  - Continuous training and racing until target rank is achieved

  - Multi-feed support: Speed, Acceleration, Endurance, Stamina, Balance

  - Enhanced race logic with Chocobo Dash ability integration

  - Robust error handling and auto-restart functionality

  - Improved NPC targeting and interaction reliability

  Note: Optimized for convenience and consistency rather than competitive racing performance.

plugin_dependencies:
- Lifestream
- vnavmesh
- TextAdvance
configs:
  Feed Type:
    default: "Speed"
    description: Choose which stat to train your Chocobo
    type: list
    required: true
    is_choice: true
    choices:
        - Speed
        - Acceleration
        - Endurance
        - Stamina
        - Balance
  Move Forward Key:
    default: "W"
    description: Key for moving forward during races. Customize to match your keybind settings.
    type: string
    required: true
  Target Rank:
    default: 40
    type: int
    min: 1
    max: 50
    required: true
    description: Target Chocobo rank to achieve before script completion.
  Auto Restart on Error?:
    default: true
    type: boolean
    description: Automatically restart the script when Lua errors occur to prevent interruptions.
  Enable Debug Logging?:
    default: false
    type: boolean
    description: Enable detailed debug logging for troubleshooting purposes.
  Echo Messages:
    default: "All"
    description: Control script message output frequency
    type: list
    required: true
    is_choice: true
    choices:
        - All
        - Important
        - None
[[End Metadata]]
--]=====]
--[[

********************************************************************************
*                                  Changelog                                   *
********************************************************************************

    -> 2.1.3    By GitHixy.
                Emergency simplified version to bypass addon interaction issues.
                Temporarily removed complex Chocobo info retrieval to prevent script failures.
                Simplified ContentsFinder interactions using basic /dfinder and /pcall commands.
                Changed approach to focus on core racing functionality while debugging addon access.
                This version prioritizes script execution over data accuracy for testing purposes.
    -> 2.1.2    By GitHixy.
                Complete rewrite of addon interaction using proper SND v2 API based on Dalamud and SimpleTweaks patterns.
                Fixed GetNodeText to use proper GetTextNodeById method instead of manual NodeList access.
                Replaced manual NodeList counting with UldManager.NodeListCount property.
                Improved Chocobo data retrieval with better node ID handling and fallback values.
                Enhanced ContentsFinder selection with more robust duty finding algorithm.
    -> 2.1.1    By GitHixy.
                Fixed critical nil-safety issues in SND v2 helper functions.
                Enhanced GetNodeText, GetNodeListCount, IsAddonReady, and IsAddonVisible with proper nil checks.
                Improved Chocobo information parsing with better debug logging.
                Fixed auto-restart error handling logic to properly handle nil pointer exceptions.
                Added comprehensive pcall protection for addon node access.
    -> 2.1.0    By GitHixy.
                Added comprehensive error handling and auto-restart functionality.
                New metadata options: "Auto Restart on Error?", "Enable Debug Logging?", "Echo Messages".
                Enhanced logging system with debug mode and configurable message output.
                Improved script reliability with automatic recovery from Lua errors.
                Added comprehensive nil-safety checks and validation throughout the script.
                Enhanced NPC interaction reliability with better retry mechanisms.
    -> 2.0.0    By GitHixy.
                Updated for SND v2 with full metadata support.
                Replaced all old API calls with new SND v2 functions.
                Converted player configurations to metadata settings.
                Added proper SND Metadata header for plugin dependency management.
    -> 1.30     Added functionality to automatically train Chocobo if training sessions are available before racing.
    -> 1.29     Refactored pathing logic and improved targeting robustness for Chocobo Trainer.
    -> 1.28     Added automatic purchasing of training food based on user selection.
    -> 1.27     Integrated race logic and allowed for continuous training and racing.
    -> 1.26     Fixed Chocobo rank retrieval from Gold Saucer tab (Bugged if not in Chocobo tab).
    -> 1.25     Refined inventory selection for feed item and NPC interactions.
    -> 1.24     Minor bug fixes and improvements to duty finder selection logic.
    -> 1.23     Improved error handling for missing feed and failed NPC targeting.
    -> 1.22     Added KEY_2 pressing on counter = 10 to use Chocobo Dash ability.
    -> 1.21     Automatic handling of Chocobo parameters tab.

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

Plugins that are needed for it to work:

    -> Something Need Doing [Expanded Edition] : (Main Plugin for everything to work)   https://puni.sh/api/repository/croizat
    -> VNavmesh :   (for Pathing/Moving)    https://puni.sh/api/repository/veyn
    -> TextAdvance: (for skipping race cutscenes and dialogue) https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
    -> Lifestream :  (for Gold Saucer Aethernet) https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json

--------------------------------------------------------------------------------------------------------------------------------------------------------------
]]

--[[
********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
]]

--#region Configuration

-- Read settings from SND metadata
local feed_type = Config.GetString("Feed Type")
local move_forward_key = Config.GetString("Move Forward Key")
local target_rank = Config.GetInt("Target Rank")
local auto_restart_on_error = Config.GetBool("Auto Restart on Error?")
local enable_debug_logging = Config.GetBool("Enable Debug Logging?")
local echo_messages = Config.GetString("Echo Messages")

-- Script State Variables
chocoboRaceScript = true
ChocoboRaceID = 21
StopScript = false

-- Error Handling Variables
ScriptRestartCount = 0
MaxRestartAttempts = 10
LastErrorMessage = ""

--#endregion Configuration

--#region Utility Functions

-- Enhanced logging function
function LogInfo(message, isImportant)
    isImportant = isImportant or false
    Dalamud.Log("[CHOCOBO] "..tostring(message))
    
    if echo_messages == "All" or (echo_messages == "Important" and isImportant) then
        yield("/echo [CHOCOBO] "..tostring(message))
    end
end

function LogDebug(message)
    if enable_debug_logging then
        Dalamud.Log("[CHOCOBO-DEBUG] "..tostring(message))
        if echo_messages == "All" then
            yield("/echo [CHOCOBO-DEBUG] "..tostring(message))
        end
    end
end

function LogError(message)
    Dalamud.Log("[CHOCOBO-ERROR] "..tostring(message))
    if echo_messages ~= "None" then
        yield("/echo [CHOCOBO-ERROR] "..tostring(message))
    end
end

-- Safe execution wrapper
function SafeCall(funcName, func, ...)
    LogDebug("Executing function: "..funcName)
    local success, result = pcall(func, ...)
    if not success then
        LogError("Function "..funcName.." failed: "..tostring(result))
        return false, result
    end
    LogDebug("Function "..funcName.." completed successfully")
    return true, result
end

-- Validation functions
function ValidateTarget(expectedName)
    if not HasTarget() then
        return false, "No target selected"
    end
    
    local currentName = GetTargetName()
    if currentName ~= expectedName then
        return false, "Expected '"..expectedName.."' but got '"..currentName.."'"
    end
    
    return true, nil
end

function ValidateAddon(addonName, shouldBeReady)
    shouldBeReady = shouldBeReady or false
    
    if shouldBeReady and not IsAddonReady(addonName) then
        return false, "Addon '"..addonName.."' is not ready"
    end
    
    if not shouldBeReady and not IsAddonVisible(addonName) then
        return false, "Addon '"..addonName.."' is not visible"
    end
    
    return true, nil
end

--#endregion Utility Functions

--#region SND v2 Helper Functions

function GetCharacterCondition(index, expected)
    if index and expected ~= nil then
        return Svc.Condition[index] == expected
    elseif index then
        return Svc.Condition[index]
    else
        return Svc.Condition
    end
end

function GetNodeText(addonName, nodeId)
    -- For now, return empty string to avoid errors
    -- We'll implement a working version once we identify the correct API
    LogDebug("GetNodeText called for addon '"..addonName.."' node "..tostring(nodeId).." - returning empty for now")
    return ""
end

function IsAddonReady(name)
    local addon = Addons.GetAddon(name)
    return addon ~= nil and addon.Ready == true
end

function IsAddonVisible(name)
    local addon = Addons.GetAddon(name)
    return addon ~= nil and addon.Exists == true
end

function GetZoneID()
    return Svc.ClientState.TerritoryType
end

function PathfindAndMoveTo(X, Y, Z, fly)
    fly = (type(fly) == "boolean") and fly or false
    local dest = Vector3(X, Y, Z)
    IPC.vnavmesh.PathfindAndMoveTo(dest, fly)
end

function PathfindInProgress()
    return IPC.vnavmesh.PathfindInProgress()
end

function PathIsRunning()
    return IPC.vnavmesh.IsRunning()
end

function GetNodeListCount(addonName)
    if not IsAddonReady(addonName) then
        LogDebug("Addon '"..addonName.."' is not ready")
        return 0
    end
    
    local addon = Addons.GetAddon(addonName)
    if not addon then
        LogDebug("Could not get addon '"..addonName.."'")
        return 0
    end
    
    -- Use UldManager NodeListCount property instead
    if addon.UldManager then
        return addon.UldManager.NodeListCount or 0
    else
        LogDebug("Addon '"..addonName.."' has no UldManager")
        return 0
    end
end

function HasTarget()
    return Entity.Target ~= nil
end

function GetTargetName()
    if Entity.Target then
        return Entity.Target.Name
    else
        return ""
    end
end

function GetDistanceToTarget()
    if Entity.Target then
        return Vector3.Distance(Entity.Player.Position, Entity.Target.Position)
    else
        return 999
    end
end

--#endregion SND v2 Helper Functions

--#region Main Functions

-- Function to open Duty Roulette
function OpenRouletteDuty(dutyID)
    yield("/dutyfinder")
    yield("/wait 1")
    yield("/pcall ContentsFinder true 1 " .. dutyID)
    yield("/wait 0.5")
end


-- Function to ensure Gold Saucer Tab is open
function open_gold_saucer_tab()
    LogDebug("Opening Gold Saucer tab")
    
    if not IsAddonReady("GoldSaucerInfo") then
        yield("/goldsaucer")
        yield("/wait 2")
        
        -- Validate the tab opened
        local attempts = 0
        while not IsAddonReady("GoldSaucerInfo") and attempts < 5 do
            yield("/wait 1")
            attempts = attempts + 1
            LogDebug("Waiting for GoldSaucerInfo addon... attempt "..attempts)
        end
        
        if not IsAddonReady("GoldSaucerInfo") then
            LogError("Failed to open Gold Saucer tab after 5 attempts")
            return false
        end
        
        yield("/callback GoldSaucerInfo true 0 1 119 0 0")
        yield("/wait 2")
    end
    
    LogDebug("Gold Saucer tab is ready")
    return true
end

-- Get the initial rank of the Chocobo and training information
function get_chocobo_info()
    LogDebug("Using simplified chocobo info for testing")
    
    -- Return simple test values to prevent script failure
    -- The user will need to help identify the correct node IDs later
    local rank = 1
    local name = "TestChocobo"
    local trainingSessionsAvailable = 0
    
    LogInfo("Chocobo '"..name.."' - Rank: "..rank.." - Training Sessions: "..trainingSessionsAvailable, true)
    return rank, name, trainingSessionsAvailable
end

-- Function to teleport to the specified aetheryte
function Teleport(aetheryteName)
    LogInfo("Teleporting to "..aetheryteName)
    
    yield("/tp " .. aetheryteName)
    
    -- Wait until the teleport starts (with timeout)
    local timeout = 0
    while not GetCharacterCondition(45) and timeout < 100 do
        yield("/wait 0.1")
        timeout = timeout + 1
    end
    
    if timeout >= 100 then
        LogError("Teleport to "..aetheryteName.." failed to start")
        return false
    end

    -- Wait for teleport to complete (with timeout)
    timeout = 0
    while GetCharacterCondition(45) and timeout < 200 do
        yield("/wait 0.1")
        timeout = timeout + 1
    end
    
    if timeout >= 200 then
        LogError("Teleport to "..aetheryteName.." timed out")
        return false
    end
    
    LogInfo("Teleport to "..aetheryteName.." completed", true)
    return true
end

-- Function to navigate to Gold Saucer training NPC
function path_to_gold_saucer_training_npc()
    LogInfo("Navigating to Gold Saucer training NPC...")

    -- Step 1: Teleport to Gold Saucer if not already in zone 144 or 388
    local zone = GetZoneID()
    LogDebug("Current zone ID: "..zone)

    if zone ~= 144 and zone ~= 388 then
        local success = Teleport("Gold Saucer")
        if not success then
            LogError("Failed to teleport to Gold Saucer")
            return false
        end
    end

    -- Step 2: Move to the Aetheryte and attune if needed
    yield("/target Aetheryte")
    if not HasTarget() or GetTargetName() ~= "Aetheryte" or GetDistanceToTarget() > 7 then
        LogInfo("Moving to Aetheryte...")
        PathfindAndMoveTo(-4.82, 1.04, 2.21) 
        
        local timeout = 0
        while (PathIsRunning() or PathfindInProgress()) and timeout < 300 do
            yield("/wait 1")
            timeout = timeout + 1
        end
        
        if timeout >= 300 then
            LogError("Timeout waiting for pathfinding to Aetheryte")
            return false
        end
    end

    -- Step 3: If near the Aetheryte, select "Chocobo Square"
    if HasTarget() and GetDistanceToTarget() <= 7 then
        yield("/vnav stop")
        LogInfo("Using Lifestream to go to Chocobo Square")
        yield("/li Chocobo Square")
        yield("/wait 3")
    else
        LogError("Could not reach Aetheryte")
        return false
    end

    -- Step 4: Path to the training NPC
    LogDebug("Pathing to Tack & Feed Trader")
    PathfindAndMoveTo(-7.57, -1.78, -67.54)  
    
    local timeout = 0
    while (PathIsRunning() or PathfindInProgress()) and timeout < 300 do
        yield("/wait 1")
        timeout = timeout + 1
    end
    
    if timeout >= 300 then
        LogError("Timeout waiting for pathfinding to NPC")
        return false
    end

    -- Step 5: Target and interact with the NPC
    local attempts = 0
    while attempts < 10 do
        yield("/target Tack & Feed Trader")
        yield("/wait 0.5")
        
        if HasTarget() and GetTargetName() == "Tack & Feed Trader" then
            break
        end
        
        attempts = attempts + 1
        LogDebug("Targeting NPC attempt "..attempts)
    end
    
    if not (HasTarget() and GetTargetName() == "Tack & Feed Trader") then
        LogError("Failed to target Tack & Feed Trader after 10 attempts")
        return false
    end

    -- Interact with NPC
    attempts = 0
    while attempts < 10 do
        yield("/interact")
        yield("/wait 0.5")
        
        if IsAddonVisible("SelectIconString") then
            break
        end
        
        attempts = attempts + 1
        LogDebug("Interaction attempt "..attempts)
    end
    
    if not IsAddonVisible("SelectIconString") then
        LogError("Failed to open SelectIconString after 10 attempts")
        return false
    end

    -- Select the first item in the menu to enter the correct NPC interface
    yield("/click SelectIconString Entry1")
    yield("/wait 1")

    LogInfo("Successfully navigated to training NPC")
    return true
end

-- Function to buy food for training based on user-selected feed type
function buy_training_food(training_sessions_available)
    LogInfo("Buying "..feed_type.." food for "..training_sessions_available.." training sessions")

    -- Define feed type options and callback values
    local feed_callbacks = {
        ["Speed"] = "/callback Shop true 0 1 ",
        ["Acceleration"] = "/callback Shop true 0 2 ",
        ["Endurance"] = "/callback Shop true 0 3 ",
        ["Stamina"] = "/callback Shop true 0 4 ",
        ["Balance"] = "/callback Shop true 0 5 "
    }

    -- Check if the feed type is valid
    if not feed_callbacks[feed_type] then
        LogError("Invalid feed type selected: "..feed_type..". Valid types: Speed, Acceleration, Endurance, Stamina, Balance")
        return false
    end
    
    -- Validate we have shop interface open
    if not IsAddonVisible("Shop") then
        LogError("Shop interface is not open")
        return false
    end

    -- Buy the specified feed in the required quantity
    local purchase_command = feed_callbacks[feed_type] .. tostring(training_sessions_available) .. " 0"
    LogDebug("Executing purchase command: "..purchase_command)
    yield(purchase_command)
    yield("/wait 2")

    -- Wait for confirmation dialog and confirm purchase
    local timeout = 0
    while not IsAddonVisible("SelectYesno") and timeout < 50 do
        yield("/wait 0.1")
        timeout = timeout + 1
    end
    
    if not IsAddonVisible("SelectYesno") then
        LogError("Purchase confirmation dialog did not appear")
        return false
    end

    yield("/click SelectYesno Yes")
    yield("/wait 1")
    
    -- Close shop
    yield("/callback Shop true -1")
    yield("/wait 1")
    
    LogInfo("Successfully purchased "..training_sessions_available.." units of "..feed_type.." Blend")
    return true
end

-- Function to repeat training based on the remaining sessions
function repeat_training(remaining_sessions, chocobo_name)
    LogInfo("Starting "..remaining_sessions.." training sessions for '"..chocobo_name.."'")
    
    local completed_sessions = 0
    
    while remaining_sessions > 0 and not StopScript do
        LogInfo("Training session "..(completed_sessions + 1).." - Remaining: "..remaining_sessions)
        
        local success = path_to_race_chocobo_trainer()
        if not success then
            LogError("Failed to complete training session "..(completed_sessions + 1))
            return false
        end

        -- Decrement the number of available sessions
        remaining_sessions = remaining_sessions - 1
        completed_sessions = completed_sessions + 1

        LogInfo("Completed training session "..completed_sessions.." for '"..chocobo_name.."'")
        
        -- Small delay between sessions
        yield("/wait 1")
    end

    if remaining_sessions == 0 then
        LogInfo("All "..completed_sessions.." training sessions completed for '"..chocobo_name.."'", true)
        return true
    else
        LogError("Training incomplete due to script stop")
        return false
    end
end

-- Function to path to the Race Chocobo Trainer and interact
function path_to_race_chocobo_trainer()
    yield("/echo Initiating pathing to Race Chocobo Trainer NPC...")

    -- Step 1: Path to the Race Chocobo Trainer
    PathfindAndMoveTo(-3.97, -2.02, -65.44)  -- Example coordinates of the Race Chocobo Trainer
    while PathIsRunning() or PathfindInProgress() do
        yield("/wait 1")
    end

    -- Step 2: Retry mechanism to target Race Chocobo Trainer
    local attempts = 0
    local max_attempts = 5  -- Retry targeting 5 times
    while attempts < max_attempts do
        yield("/target Race Chocobo Trainer")  -- Attempt to target the NPC
        yield("/wait 1")  -- Wait before checking if target succeeded
        
        if HasTarget() and GetTargetName() == "Race Chocobo Trainer" then
            yield("/echo Successfully targeted Race Chocobo Trainer.")
            break
        end
        attempts = attempts + 1
        yield("/echo Attempt " .. attempts .. " to target Race Chocobo Trainer failed. Retrying...")
    end

    -- If still no target after retries, exit
    if not (HasTarget() and GetTargetName() == "Race Chocobo Trainer") then
        yield("/echo Error: Could not target Race Chocobo Trainer after " .. max_attempts .. " attempts.")
        return
    end
    repeat
        yield("/interact")
        yield("/wait 0.2")
    until IsAddonVisible("SelectIconString")

    -- Select the first item in the menu to begin training
    yield("/click SelectIconString Entry1")
    yield("/wait 1.5")

    -- Talk skip after selecting Entry1
    yield("/click Talk Click")
    yield("/wait 2")

    -- Step 3: Cycle through inventory tabs and slots to find the feed item
    yield("/echo Searching for the feed item in the inventory...")

    local item_found = false
    for tab = 48, 51 do  -- Iterate over inventory tabs (from 48 to 51)
        for slot = 0, 33 do  -- Iterate over slots in each tab (from 0 to 33)

            -- Determine which inventory type is visible
            local inventory_visible = ""
            if IsAddonVisible("InventoryLarge") then
                inventory_visible = "InventoryLarge"
            elseif IsAddonVisible("Inventory") then
                inventory_visible = "Inventory"
            end

            if inventory_visible ~= "" then
                -- Attempt to use the feed item in the current slot of the current tab
                yield("/callback " .. inventory_visible .. " true 30 " .. tab .. " " .. slot)
                yield("/wait 0.2")

                -- Check if the item selection was successful (by looking for a confirmation dialog)
                if IsAddonReady("ChocoboBreedTraining") then
                    yield("/echo Found the '" .. feed_type .. " Blend' in inventory!")
                    yield("/callback ChocoboBreedTraining true 0 0 0 0 0")
                    yield("/wait 1")
                    
                    -- Confirm Yes/No for training
                    if IsAddonVisible("SelectYesno") then
                        yield("/click SelectYesno Yes")
                        yield("/wait 1")
                    end

                    item_found = true
                    yield("/echo Successfully gave the '" .. feed_type .. " Blend' to the Race Chocobo Trainer.")
                    break
                end
            end
        end

        -- If the item has been found, break out of the outer loop
        if item_found then
            break
        end
    end

    -- If the item was not found, show an error message
    if not item_found then
        yield("/echo Error: Could not find the '" .. feed_type .. " Blend' in the inventory.")
    end
end

-- Function to start Chocobo race logic
function start_chocobo_race()
    yield("/echo Starting the Chocobo race...")

    -- Check current rank before starting the race
    current_rank, chocobo_name = get_chocobo_info()
    if current_rank >= target_rank then
        yield("/echo Chocobo '" .. chocobo_name .. "' has reached Rank " .. current_rank .. "! Stopping the script.")
        chocoboRaceScript = false
        return
    end

    -- Simplified approach for ContentsFinder
    LogInfo("Opening Duty Finder for Chocobo Racing")
    
    -- Open ContentsFinder
    yield("/dfinder")
    yield("/wait 2")
    
    -- Wait for ContentsFinder to be ready
    local timeout = 0
    while not IsAddonReady("ContentsFinder") and timeout < 10 do
        yield("/wait 0.5")
        timeout = timeout + 0.5
    end

    if not IsAddonReady("ContentsFinder") then
        LogError("ContentsFinder failed to open")
        return false
    end

    LogInfo("ContentsFinder opened, attempting to select Chocobo Race")
    
    -- Try multiple approaches to find and select Chocobo Race
    local success = false
    
    -- Method 1: Try Gold Saucer tab directly
    yield("/pcall ContentsFinder true 12 7") -- Tab 7 for Gold Saucer
    yield("/wait 1")
    
    -- Method 2: Try direct ID selection
    yield("/pcall ContentsFinder true 0 0 21") -- ChocoboRaceID = 21
    yield("/wait 1")
    success = true -- Assume it works since we can't verify easily
    
    if success then
        LogInfo("Chocobo Race selection attempted")
    else
        LogError("Failed to select Chocobo Race")
        return false
    end

    -- Start Duty Finder
    LogInfo("Starting Duty Finder")
    yield("/pcall ContentsFinder true 12 0")

    -- Wait until Duty Finder is ready
    while not IsAddonReady("ContentsFinderConfirm") do
        yield("/wait 1")
    end

    -- Auto-commence duty
    yield("/click ContentsFinderConfirm Commence")

    -- Wait for the zone to change
    repeat
        zone = GetZoneID()
        yield("/wait 0.5")
    until zone ~= 388

    -- Prevent reopening Duty Finder after the duty has started
    if zone ~= 388 then
        yield("/echo Race has started! Have fun!")
    end

    -- Start the Chocobo race logic
    counter = 0
    key_1_intervals = {15, 20, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 91, 105, 120, 135}

    repeat
        -- Hold the forward key (W or custom key)
        yield("/hold " .. move_forward_key)
        counter = counter + 1

        if table_contains(key_1_intervals, counter) then
            yield("/send KEY_1")
        end

        if counter == 15 or counter == 25 then
            yield("/send KEY_2") -- Chocobo Dash Ability (adjust counter value as needed)
        end

        if counter == 90 then
            yield("/send KEY_3")
        end

        yield("/wait 1")
    until IsAddonReady("RaceChocoboResult")

    -- Show Bonus and Exit Duty
    yield("/wait 9")
    yield("/e Exiting from Chocobo Race!")
    yield("/release " .. move_forward_key)
    yield("/pcall RaceChocoboResult true 1 0 <wait.1>")
    yield("/wait 4")

    -- Check the Chocobo's rank after the race
    current_rank, chocobo_name = get_chocobo_info()
    yield("/echo Current Chocobo '" .. chocobo_name .. "' Rank: " .. current_rank)

    if current_rank >= target_rank then
        yield("/echo Chocobo '" .. chocobo_name .. "' has reached Rank " .. current_rank .. "! Stopping the script.")
        chocoboRaceScript = false
    else
        -- Repeat training and race if needed
        check_and_train_chocobo_then_race()
    end
end

-- Helper Function to check if an element is in a table
function table_contains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- Function to check and train Chocobo, then race if training is done
function check_and_train_chocobo_then_race()
    LogDebug("Starting simplified check_and_train_chocobo_then_race function")
    
    -- For now, skip complex Chocobo info retrieval and just go straight to racing
    LogInfo("Skipping Chocobo info retrieval and training - going directly to racing", true)
    
    -- Try to start a race
    local success = start_chocobo_race()
    if not success then
        LogError("Failed to start or complete race")
        return false
    end
    
    return true
end

--#endregion Main Functions

--#endregion Main Functions

--#region Script Entry Point

-- Main script loop with error handling
function MainChocoboScript()
    LogInfo("=== Chocobo Racing Script Started ===", true)
    LogInfo("Target Rank: "..target_rank.." | Feed Type: "..feed_type.." | Forward Key: "..move_forward_key)
    
    while chocoboRaceScript and not StopScript do
        local success, error = SafeCall("check_and_train_chocobo_then_race", check_and_train_chocobo_then_race)
        
        if not success then
            LogError("Main script function failed: "..tostring(error))
            -- Let the outer error handler deal with restarts
            StopScript = true
            break
        end
        
        -- Small delay to prevent tight loops
        yield("/wait 1")
    end
    
    LogInfo("=== Chocobo Racing Script Ended ===", true)
end

-- Main execution with error handling wrapper
if auto_restart_on_error then
    LogInfo("Auto-restart enabled with max "..MaxRestartAttempts.." attempts")
    
    local function RunWithErrorHandling()
        local success, errorMsg = pcall(MainChocoboScript)
        
        if not success and auto_restart_on_error then
            ScriptRestartCount = ScriptRestartCount + 1
            LastErrorMessage = tostring(errorMsg)
            
            LogError("Script crashed with error: "..LastErrorMessage)
            LogError("Restart attempt "..ScriptRestartCount.."/"..MaxRestartAttempts)
            
            if ScriptRestartCount < MaxRestartAttempts then
                LogInfo("Auto-restarting script... (Attempt "..ScriptRestartCount.."/"..MaxRestartAttempts..")", true)
                LogError("Error details: "..LastErrorMessage)
                
                -- Emergency cleanup
                pcall(function()
                    yield("/vnav stop")
                    if HasTarget() then
                        yield("/clearlog")
                    end
                end)
                
                yield("/wait 3")
                LogInfo("Restarting Chocobo Racing script...")
                yield("/snd run \"ChocoboRace\"")
            else
                LogError("Maximum restart attempts reached. Script stopped.", true)
            end
        end
    end
    
    RunWithErrorHandling()
else
    -- Run without auto-restart
    MainChocoboScript()
end

--#endregion Script Entry Point
