--[=====[
[[SND Metadata]]
author: GitHixy
version: 1.0.0
description: >-
  Chocobo Race automation script for Final Fantasy XIV.

  Basic functionality:
  - Access Gold Saucer menu
  - Navigate to Chocobo racing section
  - Retrieve Chocobo name and current rank

plugin_dependencies:
- TextAdvance
configs:
  Rank to reach:
    default: 40
    description: Target rank to achieve (maximum is 40)
    type: int
    min: 1
    max: 40
    required: true
  Key to go forward:
    default: W
    description: Movement key for racing
    type: string
    required: true
[[End Metadata]]
--]=====]

-- Plugin checks
yield("/echo [CHOCOBO] TextAdvance plugin required - please ensure it's installed")

-- Main script logic
function Main()
    yield("/echo [CHOCOBO] Starting Chocobo Race script v1.0.0")

    -- Wait for player to be ready
    LoginCheck()

    -- Access Gold Saucer menu
    if not AccessGoldSaucer() then
        yield("/echo [CHOCOBO] Failed to access Gold Saucer menu")
        return
    end

    -- Navigate to Chocobo section
    if not NavigateToChocobo() then
        yield("/echo [CHOCOBO] Failed to navigate to Chocobo section")
        return
    end

    -- Get Chocobo information
    local chocoboName, currentRank = GetChocoboInfo()
    if chocoboName and currentRank then
        yield("/echo [CHOCOBO] Chocobo Name: " .. chocoboName)
        yield("/echo [CHOCOBO] Current Rank: " .. currentRank .. " / 40")
    else
        yield("/echo [CHOCOBO] Failed to retrieve Chocobo information")
    end

    yield("/echo [CHOCOBO] Script completed - basic functionality implemented")
end

-- Function to access Gold Saucer menu
function AccessGoldSaucer()
    yield("/echo [CHOCOBO] Accessing Gold Saucer menu...")

    -- Open main menu
    yield("/g")
    yield("/wait 1")

    -- Navigate to Gold Saucer option (typically option 3 or similar)
    -- This may need adjustment based on menu structure
    yield("/callback SelectString true 3")
    yield("/wait 2")

    -- Check if Gold Saucer menu opened
    if IsAddonVisible("GoldSaucerReward") or IsAddonVisible("GoldSaucer") then
        yield("/echo [CHOCOBO] Gold Saucer menu accessed successfully")
        return true
    end

    yield("/echo [CHOCOBO] Gold Saucer menu not detected")
    return false
end

-- Function to navigate to Chocobo section
function NavigateToChocobo()
    yield("/echo [CHOCOBO] Navigating to Chocobo section...")

    -- Navigate to Chocobo racing option
    -- This may need adjustment based on Gold Saucer menu structure
    yield("/callback GoldSaucer true 1")
    yield("/wait 2")

    -- Check if Chocobo menu opened
    if IsAddonVisible("ChocoboRace") then
        yield("/echo [CHOCOBO] Chocobo section accessed successfully")
        return true
    end

    yield("/echo [CHOCOBO] Chocobo section not detected")
    return false
end

-- Function to get Chocobo information
function GetChocoboInfo()
    yield("/echo [CHOCOBO] Retrieving Chocobo information...")

    -- Wait for menu to load
    yield("/wait 1")

    -- Get Chocobo name (this will need to be implemented based on actual menu structure)
    local chocoboName = GetNodeText("ChocoboRace", 2) -- Placeholder - needs actual node path

    -- Get current rank (this will need to be implemented based on actual menu structure)
    local currentRank = GetNodeText("ChocoboRace", 3) -- Placeholder - needs actual node path

    if chocoboName and currentRank then
        return chocoboName, tonumber(currentRank)
    end

    return nil, nil
end

-- Start the script
Main()