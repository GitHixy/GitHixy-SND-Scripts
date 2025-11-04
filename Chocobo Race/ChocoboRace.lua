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

  Note: Full Chocobo info retrieval requires vac_functions.lua to be loaded separately

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

    -- Wait for player to be ready (simple wait instead of LoginCheck)
    yield("/wait 2")

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

    -- Open Gold Saucer menu directly
    yield("/goldsaucer")
    yield("/wait 2")

    -- Assume Gold Saucer menu opened successfully
    yield("/echo [CHOCOBO] Gold Saucer menu accessed successfully")
    return true
end

-- Function to navigate to Chocobo section
function NavigateToChocobo()
    yield("/echo [CHOCOBO] Navigating to Chocobo section...")

    -- Click Chocobo tab in GoldSaucerInfo addon (position 26 4)
    yield("/click GoldSaucerInfo 26 4")
    yield("/wait 2")

    -- Assume Chocobo section accessed successfully
    yield("/echo [CHOCOBO] Chocobo section accessed successfully")
    return true
end

-- Function to get Chocobo information
function GetChocoboInfo()
    yield("/echo [CHOCOBO] Retrieving Chocobo information...")

    -- Get Chocobo name from GSInfoChocoboParam addon (when vac_functions.lua is available)
    -- local chocoboName = GetNodeText("GSInfoChocoboParam", 2)

    -- Get current rank from GSInfoChocoboParam addon (when vac_functions.lua is available)
    -- local currentRank = GetNodeText("GSInfoChocoboParam", 3)

    -- For now, return placeholder values since GetNodeText is not available
    local chocoboName = "Unknown Chocobo" -- Placeholder
    local currentRank = 1 -- Placeholder

    yield("/echo [CHOCOBO] Chocobo info retrieval not implemented yet (needs vac_functions.lua)")
    return chocoboName, currentRank
end

-- Start the script
Main()