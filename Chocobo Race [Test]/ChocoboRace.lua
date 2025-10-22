--[=====[
[[SND Metadata]]
author: GitHixy
version: 2.0.0
description: >-
  Auto Chocobo Train & Race script with the following features:

  - Automatically trains Chocobo if training sessions are available before racing

  - Purchases training food automatically based on user selection (Grade 1 only)

  - Continuous training and racing until desired rank is reached

  - Supports multiple feed types: Speed, Acceleration, Endurance, Stamina, and Balance

  - Integrates Chocobo Dash ability during races

  - Improved targeting logic for Chocobo Trainer NPC

  Note: This script is more about convenience than competitiveness, so don't expect first place every time!

plugin_dependencies:
- Lifestream
- vnavmesh
- TextAdvance
configs:
  Feed Type:
    default: "Speed"
    description: Choose which stat to train
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
    description: Key for moving forward during the race. Change to your desired move forward key.
    type: string
    required: true
  Target Rank:
    default: 40
    type: int
    min: 1
    max: 50
    required: true
    description: The rank your Chocobo will aim to achieve before the script stops.
[[End Metadata]]
--]=====]
--[[

********************************************************************************
*                                  Changelog                                   *
********************************************************************************

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

--Declarations
chocoboRaceScript = true
ChocoboRaceID = 21

--#endregion Configuration

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

function GetNodeText(addonName, ...)
    if IsAddonReady(addonName) then
        local node = Addons.GetAddon(addonName):GetNode(...)
        return tostring(node.Text)
    else
        return ""
    end
end

function IsAddonReady(name)
    return Addons.GetAddon(name).Ready
end

function IsAddonVisible(name)
    return Addons.GetAddon(name).Exists
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
    if IsAddonReady(addonName) then
        return Addons.GetAddon(addonName).NodeList:Count()
    else
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
    if not IsAddonReady("GoldSaucerInfo") then
        yield("/goldsaucer")
        yield("/wait 2")  -- Wait for the Gold Saucer tab to open
        yield("/callback GoldSaucerInfo true 0 1 119 0 0")
        yield("/wait 2")
    end
end

-- Get the initial rank of the Chocobo and training information
function get_chocobo_info()
    open_gold_saucer_tab()
    yield("/wait 1")
    
    local rank = tonumber(GetNodeText("GoldSaucerInfo", 16)) or 0
    local name = GetNodeText("GoldSaucerInfo", 20) or "Unknown"
    local trainingSessionsAvailable = 0

    if IsAddonReady("GSInfoChocoboParam") then
        trainingSessionsAvailable = tonumber(GetNodeText("GSInfoChocoboParam", 9, 0)) or 0
    else
        yield("/echo Warning: GSInfoChocoboParam not ready. Defaulting training sessions to 0.")
    end

    return rank, name, trainingSessionsAvailable
end

-- Function to teleport to the specified aetheryte
function Teleport(aetheryteName)
    yield("/tp " .. aetheryteName)
    
    -- Wait until the teleport is completed
    while not GetCharacterCondition(45) do
        yield("/wait 0.1")
    end

    -- Wait for a short delay to ensure the character finishes the teleport animation
    while GetCharacterCondition(45) do
        yield("/wait 0.1")
    end
    yield("/echo Teleport to " .. aetheryteName .. " completed.")
end

-- Function to navigate to Gold Saucer training NPC
function path_to_gold_saucer_training_npc()
    yield("/echo Initiating pathing to Gold Saucer training NPC...")

    -- Step 1: Teleport to Gold Saucer if not already in zone 144 or 388
    zone = GetZoneID()

    if zone ~= 144 and zone ~= 388 then
        Teleport("Gold Saucer")
    end

    -- Step 2: Move to the Aetheryte and attune if needed
    yield("/target Aetheryte")
    if not HasTarget() or GetTargetName() ~= "Aetheryte" or GetDistanceToTarget() > 7 then
        yield("/echo Moving to Aetheryte...")
        PathfindAndMoveTo(-4.82, 1.04, 2.21) 
        while PathIsRunning() or PathfindInProgress() do
            yield("/wait 1")
        end
    end

    -- Step 3: If near the Aetheryte, select "Chocobo Square"
    if GetDistanceToTarget() <= 7 then
        yield("/vnav stop")
        yield("/li Chocobo Square")
        yield("/wait 3")
    end

    -- Step 4: Path to the training NPC
    PathfindAndMoveTo(-7.57, -1.78, -67.54)  
    while PathIsRunning() or PathfindInProgress() do
        yield("/wait 1")
    end

    -- Step 5: Target and interact with the NPC
    repeat
        yield("/target Tack & Feed Trader")
        yield("/wait 0.1")
    until HasTarget() and GetTargetName() == "Tack & Feed Trader"

    repeat
        yield("/interact")
        yield("/wait 0.2")
    until IsAddonVisible("SelectIconString")

    -- Select the first item in the menu to enter the correct NPC interface
    yield("/click SelectIconString Entry1")
    yield("/wait 1")

    yield("/echo Pathing completed. Ready to interact with NPC for training.")
end

-- Function to buy food for training based on user-selected feed type
function buy_training_food(training_sessions_available)
    yield("/echo Starting the process of buying " .. feed_type .. " for " .. training_sessions_available .. " training sessions.")

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
        yield("/echo Error: Invalid feed type selected. Please choose from Speed, Acceleration, Endurance, Stamina, or Balance.")
        return
    end

    -- Buy the specified feed in the required quantity
    local purchase_command = feed_callbacks[feed_type] .. tostring(training_sessions_available) .. " 0"
    yield(purchase_command)
    yield("/wait 2")

    -- Confirm purchase
    yield("/click SelectYesno Yes")
    yield("/wait 1")
    yield("/callback Shop true -1")
    
    yield("/echo Successfully bought " .. training_sessions_available .. " units of " .. feed_type .. " Blend.")
end

-- Function to repeat training based on the remaining sessions
function repeat_training(remaining_sessions, chocobo_name)
    while remaining_sessions > 0 do
        -- Proceed to the Race Chocobo Trainer for each session
        yield("/echo Remaining training sessions: " .. remaining_sessions)
        path_to_race_chocobo_trainer()

        -- Decrement the number of available sessions
        remaining_sessions = remaining_sessions - 1

        yield("/echo Completed one training session for Chocobo '" .. chocobo_name .. "'. Remaining sessions: " .. remaining_sessions)
    end

    yield("/echo All training sessions for Chocobo '" .. chocobo_name .. "' have been completed.")
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

    -- Open Roulette Duty for Chocobo Racing
    yield("/wait 2")
    OpenRouletteDuty(ChocoboRaceID)

    -- Wait for ContentsFinder to be ready
    while not IsAddonReady("ContentsFinder") do
        yield("/wait 0.5")
    end

    -- Get the number of duties in the ContentsFinder
    if IsAddonReady("ContentsFinder") then
        list = GetNodeListCount("ContentsFinder")
        yield("/echo Total Duties Found: " .. list)
        yield("/wait 0.5")
    end

    -- Clear previous selection
    yield("/pcall ContentsFinder true 12 1")

    -- Search for "Chocobo Race: Random"
    FoundTheDuty = false
    for i = 1, list do  -- Iterate over List duties
        yield("/pcall ContentsFinder true 3 " .. i)
        yield("/wait 0.1")
        
        if GetNodeText("ContentsFinder", 14) == "Chocobo Race: Random" then
            FoundTheDuty = true
            yield("/echo Random Chocobo Race selected at position " .. i)
            break
        end
    end

    -- Check if Random Chocobo Race was found
    if FoundTheDuty == false then
        yield("/echo You don't have the Duty")
        yield("/snd stop")
        return
    end

    -- Start Duty Finder
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
    current_rank, chocobo_name, training_sessions_available = get_chocobo_info()

    -- Echo the Chocobo info
    yield("/echo Current Chocobo: '" .. chocobo_name .. "' Rank: " .. current_rank .. " Training Sessions Available: " .. training_sessions_available)

    -- Check if training sessions are available
    if training_sessions_available > 0 then
        yield("/echo Training sessions available for Chocobo '" .. chocobo_name .. "'. Preparing to go to the Gold Saucer.")
        
        -- Pathing logic to navigate to the NPC
        path_to_gold_saucer_training_npc()

        -- Logic to buy food for training
        buy_training_food(training_sessions_available)

        -- Proceed to repeat training for the remaining sessions
        repeat_training(training_sessions_available, chocobo_name)
    end

    -- After training, or if no training sessions, start the race
    start_chocobo_race()
end

--#endregion Main Functions

--#region Script Entry Point

-- Start the entire process
check_and_train_chocobo_then_race()

--#endregion Script Entry Point
