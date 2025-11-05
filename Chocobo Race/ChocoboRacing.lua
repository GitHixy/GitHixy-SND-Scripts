--[=====[
[[SND Metadata]]
author: GitHixy
version: 1.0.0
description: >-
  Chocobo Racing automation script with the following features:

  - Automatically farms races until your chocobo reaches target rank

  - Reads chocobo name and current rank from Gold Saucer menu

  - Handles race registration and completion automatically
configs:
  Rank:
    default: 40
    description: Target rank for your chocobo (1-40)
    type: int
    min: 1
    max: 40
    required: true
  Forward Key:
    default: "w"
    description: Key used to move forward during races
    type: string
    required: true
[[End Metadata]]
]=====]

--[[
####################################################
##          Chocobo Racing Automation             ##
##                  Version 1.0.0                 ##
####################################################

Script for automating chocobo racing in FFXIV Gold Saucer

-> 1.0.0: Initial release with rank checking functionality
]]

----------------------------------------------------
--               Required Functions               --
----------------------------------------------------

-- IsPlayerAvailable()
-- Player.Available wrapper, use to check if player is available
function IsPlayerAvailable()
    return Player.Available
end

-- IsPlayerCasting()
-- Player.Entity.IsCasting wrapper
function IsPlayerCasting()
    return Player.Entity and Player.Entity.IsCasting
end

-- GetCharacterCondition(index, expected)
-- Player or self conditions service wrapper
function GetCharacterCondition(index, expected)
    if index and expected ~= nil then
        return Svc.Condition[index] == expected
    elseif index then
        return Svc.Condition[index]
    else
        return Svc.Condition
    end
end

-- IsAddonReady(name)
-- Check if addon is ready to be interacted with
function IsAddonReady(name)
    local success, result = pcall(function()
        local addon = Addons.GetAddon(name)
        return addon and addon.Ready or false
    end)
    return success and result
end

-- IsAddonVisible(name)
-- Check if addon exists/is visible
function IsAddonVisible(name)
    local success, result = pcall(function()
        local addon = Addons.GetAddon(name)
        return addon and addon.Exists or false
    end)
    return success and result
end

-- GetAddonText(addonName, nodeIds)
-- Gets text from a specific node in an addon using the proper Dalamud API
-- nodeIds is a table/array of node IDs to traverse
-- Example: GetAddonText("GoldSaucerInfo", {2, 2})
function GetAddonText(addonName, nodeIds)
    if not IsAddonReady(addonName) then
        return ""
    end
    
    local addon = Addons.GetAddon(addonName)
    if not addon then
        return ""
    end
    
    local node = addon
    for _, id in ipairs(nodeIds) do
        node = node:GetNode(id)
        if not node then
            return ""
        end
    end
    
    if node and node.Text then
        return tostring(node.Text)
    end
    
    return ""
end

-- GetAddonNodeById(addonName, nodeId)
-- Gets a node by its ID from an addon
function GetAddonNodeById(addonName, nodeId)
    if not IsAddonReady(addonName) then
        return nil
    end
    
    local addon = Addons.GetAddon(addonName)
    if not addon then
        return nil
    end
    
    return addon:GetNode(nodeId)
end

-- GetNodeTextById(addonName, nodeId)
-- Gets text from a node by its ID
function GetNodeTextById(addonName, nodeId)
    local node = GetAddonNodeById(addonName, nodeId)
    if node and node.Text then
        return tostring(node.Text)
    end
    return ""
end

-- LogInfo(message)
-- Logs info level messages
function LogInfo(message)
    Dalamud.Log(message)
end

-- LogDebug(message)
-- Logs debug level messages
function LogDebug(message)
    Dalamud.Log(message, "Debug")
end

-- WaitUntilPlayerAvailable()
-- Waits until player is available and not casting
function WaitUntilPlayerAvailable()
    repeat
        Sleep(0.1)
    until IsPlayerAvailable() and not IsPlayerCasting()
end

-- HasPlugin(pluginName)
-- Check if a plugin is installed and loaded
function HasPlugin(pluginName)
    -- Try to check if the plugin is loaded via DalamudReflector
    local success, result = pcall(function()
        return DalamudReflector.GetPluginNames()
    end)
    
    if success and result then
        for _, name in ipairs(result) do
            if name == pluginName then
                return true
            end
        end
    end
    
    -- Fallback: For now, just assume plugins are available
    -- This is a temporary workaround until we can properly detect plugins
    LogDebug("[CHOCOBO] Plugin check for " .. pluginName .. " (assuming available)")
    return true
end

----------------------------------------------------
--               Global Variables                 --
----------------------------------------------------

-- Config values
local TargetRank = Rank or 40
local ForwardKey = Forward_Key or "W"

-- State tracking
local ChocoboName = ""
local CurrentRank = 0
local ScriptRunning = true

----------------------------------------------------
--            Chocobo Info Functions              --
----------------------------------------------------

-- OpenGoldSaucerMenu()
-- Opens the Gold Saucer menu
function OpenGoldSaucerMenu()
    LogInfo("[CHOCOBO] Opening Gold Saucer menu...")
    
    yield("/goldsaucer")
    yield("/wait 1")
    
    local timeout = 0
    repeat
        yield("/wait 0.1")
        timeout = timeout + 0.1
        if timeout > 5 then
            LogInfo("[CHOCOBO] Timeout waiting for Gold Saucer menu")
            return false
        end
    until IsAddonVisible("GoldSaucerInfo")
    
    LogInfo("[CHOCOBO] Gold Saucer menu opened")
    return true
end

-- NavigateToChocoboTab()
-- Navigates to the Chocobo Racing tab in Gold Saucer menu
function NavigateToChocoboTab()
    LogInfo("[CHOCOBO] Navigating to Chocobo Racing tab...")
    
    if not IsAddonVisible("GoldSaucerInfo") then
        if not OpenGoldSaucerMenu() then
            return false
        end
    end
    
    yield("/callback GoldSaucerInfo true 0 1 119 0 0")
    yield("/wait 0.5")
    
    LogInfo("[CHOCOBO] Navigated to Chocobo Racing tab")
    return true
end

-- GetChocoboInfo()
-- Reads chocobo name and rank from Gold Saucer menu using AtkValues
-- AtkValue 6 = Chocobo Name
-- AtkValue 8 = Chocobo Rank
function GetChocoboInfo()
    LogInfo("[CHOCOBO] Reading chocobo information...")
    
    if not NavigateToChocoboTab() then
        return false
    end
    
    yield("/wait 0.5")
    
    local success, addon = pcall(function()
        return Addons.GetAddon("GoldSaucerInfo")
    end)
    
    if not success or not addon then
        LogInfo("[CHOCOBO] Failed to get GoldSaucerInfo addon")
        return false
    end
    
    -- Read chocobo name (AtkValue 6)
    local nameSuccess, nameValue = pcall(function()
        return addon:GetAtkValue(6)
    end)
    
    if nameSuccess and nameValue then
        ChocoboName = tostring(nameValue.ValueString)
        LogInfo("[CHOCOBO] Chocobo Name: " .. ChocoboName)
    end
    
    -- Read chocobo rank (AtkValue 8)
    local rankSuccess, rankValue = pcall(function()
        return addon:GetAtkValue(8)
    end)
    
    if rankSuccess and rankValue then
        CurrentRank = tonumber(rankValue.ValueString) or 0
        LogInfo("[CHOCOBO] Current Rank: " .. CurrentRank .. " / Target Rank: " .. TargetRank)
    end
    
    if ChocoboName ~= "" and CurrentRank > 0 then
        yield("/echo [CHOCOBO] " .. ChocoboName .. " - Rank " .. CurrentRank .. "/" .. TargetRank)

        -- Close Gold Saucer menu
        yield("/callback GoldSaucerInfo true -1")
        yield("/wait 0.3")

        return true
    end
    
    LogInfo("[CHOCOBO] Failed to read chocobo information")
    return false
end

-- OpenDutyFinder()
-- Opens the Duty Finder menu and navigates to Gold Saucer tab
function OpenDutyFinder()
    LogInfo("[CHOCOBO] Opening Duty Finder...")
    
    yield("/dutyfinder")
    yield("/wait 1")
    
    local timeout = 0
    repeat
        yield("/wait 0.1")
        timeout = timeout + 0.1
        if timeout > 5 then
            LogInfo("[CHOCOBO] Timeout waiting for Duty Finder menu")
            return false
        end
    until IsAddonVisible("ContentsFinder")
    
    LogInfo("[CHOCOBO] Duty Finder opened")
    
    -- Navigate to Gold Saucer tab
    yield("/callback ContentsFinder true 1 9")
    yield("/wait 3")
    
    LogInfo("[CHOCOBO] Navigated to Gold Saucer tab")
    return true
end


-- SelectChocoboRace()
-- Selects Chocobo Race (Random) from the Gold Saucer tab
function SelectChocoboRace()
    LogInfo("[CHOCOBO] Selecting Chocobo Race (Random)...")
    
    if not IsAddonVisible("ContentsFinder") then
        LogInfo("[CHOCOBO] ContentsFinder not visible")
        return false
    end
    
    -- Check if duty is already selected (AtkValue 18 contains "ChocoboRace: Random")
    local success, addon = pcall(function()
        return Addons.GetAddon("ContentsFinder")
    end)
    
    if success and addon then
        local atkSuccess, atkValue = pcall(function()
            return addon:GetAtkValue(18)
        end)
        
        if atkSuccess and atkValue and atkValue.ValueString then
            local selectedDuty = tostring(atkValue.ValueString)
            LogInfo("[CHOCOBO] Current selected duty: " .. selectedDuty)
            if selectedDuty:find("Chocobo") or selectedDuty:find("Race") then
                LogInfo("[CHOCOBO] Duty already selected, skipping")
                return true
            end
        end
    end
    
    -- Select Chocobo Race using duty number
    -- Gold Saucer tab (9), Chocobo Race Random duty number
    LogInfo("[CHOCOBO] Selecting race with callback...")
    yield("/callback ContentsFinder true 3 10")
    yield("/wait 0.5")
    
    LogInfo("[CHOCOBO] Chocobo Race (Random) selected")
    return true
end

-- QueueForRace()
-- Queues for the selected race
function QueueForRace()
    LogInfo("[CHOCOBO] Queueing for race...")
    
    if not IsAddonVisible("ContentsFinder") then
        LogInfo("[CHOCOBO] ContentsFinder not visible")
        return false
    end
    
    -- Queue for the duty (callback true 12 0)
    yield("/callback ContentsFinder true 12 0")
    yield("/wait 1")
    
    LogInfo("[CHOCOBO] Queued for race")
    return true
end

-- RaceLogic()
-- Executes the race: holds forward key and uses abilities until race ends
function RaceLogic()
    yield("/echo [CHOCOBO] Race started! Running race logic...")
    
    -- Wait a moment for the race to fully load
    yield("/wait 3")
    
    -- Hold forward key down continuously
    yield("/hold " .. ForwardKey)
    yield("/echo [CHOCOBO] Holding forward key: " .. ForwardKey)
    
    local cycleCount = 0
    
    -- Loop until race results appear, using abilities
    while not IsAddonVisible("RaceChocoboResult") do
        -- Use abilities 1-5 in sequence
        yield("/send KEY_1")
        yield("/wait 2")
        yield("/send KEY_2")
        yield("/wait 2")
        yield("/send KEY_3")
        yield("/wait 2")
        yield("/send KEY_4")
        yield("/wait 2")
        yield("/send KEY_5")
        yield("/wait 2")
        
        cycleCount = cycleCount + 1
        if cycleCount % 5 == 0 then
            LogInfo("[CHOCOBO] Race ongoing... (cycle " .. cycleCount .. ")")
        end
    end
    
    -- Release forward key
    yield("/release " .. ForwardKey)
    LogInfo("[CHOCOBO] Race finished! Results screen detected")
end

----------------------------------------------------
--              Main Script Logic                 --
----------------------------------------------------

function MainLoop()
    yield("/e [CHOCOBO-RACE] Script Started!")
    LogInfo("[CHOCOBO] Target Rank: " .. TargetRank)
    LogInfo("[CHOCOBO] Forward Key: " .. ForwardKey)
local raceCount = 0
    
    -- Main loop: repeat races until target rank is reached
    while ScriptRunning do
        -- Read chocobo info at start of each iteration
        if not GetChocoboInfo() then
            LogInfo("[CHOCOBO] ERROR: Could not read chocobo information")
            return
        end
        
        -- Check if target rank is reached
        if CurrentRank >= TargetRank then
            LogInfo("[CHOCOBO] Target rank reached!")
            yield("/echo [CHOCOBO] " .. ChocoboName .. " has reached rank " .. TargetRank .. "!")
            yield("/echo [CHOCOBO] Total races completed: " .. raceCount)
            return
        end
        
        -- Target rank not reached, proceed with race logic
        raceCount = raceCount + 1
        yield("/echo [CHOCOBO] ========================================")
        yield("/echo [CHOCOBO] Starting race #" .. raceCount)
        yield("/echo [CHOCOBO] Current: Rank " .. CurrentRank .. " / Target: Rank " .. TargetRank)
        yield("/echo [CHOCOBO] ========================================")
        
        -- Open Duty Finder and navigate to Gold Saucer tab
        if not OpenDutyFinder() then
            LogInfo("[CHOCOBO] ERROR: Could not open Duty Finder")
            return
        end
        
        -- Select Chocobo Race (Random)
        if not SelectChocoboRace() then
            LogInfo("[CHOCOBO] ERROR: Could not select Chocobo Race")
            return
        end
        
        -- Queue for race
        if not QueueForRace() then
            LogInfo("[CHOCOBO] ERROR: Could not queue for race")
            return
        end
        
        -- Wait for queue to pop and accept
        yield("/echo [CHOCOBO] Waiting for queue to pop...")
        repeat
            yield("/wait 1")
            
            -- Check if ContentsFinderConfirm appeared (duty pop)
            if IsAddonVisible("ContentsFinderConfirm") then
                LogInfo("[CHOCOBO] Queue popped! Accepting...")
                yield("/callback ContentsFinderConfirm true 8")
                yield("/wait 2")
                break
            end
        until false
        
        -- Wait until player is available in the duty
        local loadTimeout = 0
        repeat
            yield("/wait 1")
            loadTimeout = loadTimeout + 1
            if loadTimeout > 30 then
                LogInfo("[CHOCOBO] ERROR: Timeout waiting for duty to load")
                return
            end
        until IsPlayerAvailable() and not GetCharacterCondition(45) -- 45 = between areas
        
        LogInfo("[CHOCOBO] Duty loaded, starting race logic...")
        yield("/wait 2")
        
        -- Execute race logic
        RaceLogic()
        
        -- Wait for race results screen
        LogInfo("[CHOCOBO] Waiting for race results...")
        local resultsTimeout = 0
        repeat
            yield("/wait 1")
            resultsTimeout = resultsTimeout + 1
            LogInfo("[CHOCOBO] Checking for results screen... (" .. resultsTimeout .. "s)")
            if resultsTimeout > 60 then
                LogInfo("[CHOCOBO] ERROR: Timeout waiting for race results")
                return
            end
        until IsAddonVisible("RaceChocoboResult")
        
        yield("/echo [CHOCOBO] Race results appeared!")
        yield("/wait 6")
        
        -- Press leave button in race results
        yield("/echo [CHOCOBO] Leaving duty...")
        yield("/callback RaceChocoboResult true 1")
        yield("/wait 5")
        
        -- Wait for return to previous location
        yield("/echo [CHOCOBO] Waiting to return to previous location")
        local returnTimeout = 0
        repeat
            yield("/wait 1")
            returnTimeout = returnTimeout + 1
            if returnTimeout > 30 then
                LogInfo("[CHOCOBO] ERROR: Timeout waiting to return")
                return
            end
        until IsPlayerAvailable() and not GetCharacterCondition(45)
        
        yield("/echo [CHOCOBO] Race #" .. raceCount .. " completed!")
        yield("/wait 3")
        
        -- Loop continues to next race
    end

end

----------------------------------------------------
--              Script Execution                  --
----------------------------------------------------

MainLoop()