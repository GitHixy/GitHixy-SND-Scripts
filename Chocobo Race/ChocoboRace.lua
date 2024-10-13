--[[

Auto Chocobo Race v1.20 by GitHixy
Reworked logic inspired by Jaksuhn's Auto-Chocobo

You can make a macro with /snd run "Your_script_name_here"

Note: This script is more about convenience than competitiveness 
      so don't expect first place every time!

Happy Levelling!

Updates:

1.20 - Fix to ensure rank is retrieved from the Gold Saucer tab (Bugged ATM)
1.19 - Implemented Rank Checker and Stop Feature at Target Rank
1.18 - AutoSelect 'Chocobo Race: Random' in Duty Finder
1.17 - Option to set 'Chocobo Race: Random' position on Duty Finder to be selected correctly
1.16 - Custom Key Added
1.15 - Reworked Race Logic
1.14 - Fix Loop
1.13 - Fix Timers
1.12 - Race Logic
1.11 - Bug Fixes
1.1  - Init

]]--

-- Declarations

chocoboRaceScript = true
ChocoboRaceID = 21


-- Player Configurations
move_forward_key = "W"  -- Default is "W", change to your desired move forward key
target_rank = 40  -- Default target rank is 40

-- Function to ensure Gold Saucer Tab is open
function open_gold_saucer_tab()
    if not IsAddonReady("GoldSaucerInfo") then
        yield("/goldsaucer")
        yield("/wait 2")  -- Wait for the Gold Saucer tab to open
    end
end

-- Get the initial rank of the Chocobo
function get_chocobo_info()
    open_gold_saucer_tab()  -- Ensure the Gold Saucer tab is open
    local rank = tonumber(GetNodeText("GoldSaucerInfo", 16))
    local name = GetNodeText("GoldSaucerInfo", 20)
    return rank, name
end

-- Initialize the rank and echo it to the user
current_rank, chocobo_name = get_chocobo_info()
yield("/echo Current Chocobo '" .. chocobo_name .. "' Rank: " .. current_rank)

-- Helper Function to check if an element is in a table
function table_contains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- Main Logic
while chocoboRaceScript do
    repeat
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
            yield("/echo Total Duties: " .. list)
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
            break
        end

    until false

    -- Start the Chocobo race logic
    counter = 0
    key_1_intervals = {15, 30, 45, 60, 75, 91, 105, 120, 135}

    repeat
        -- Hold the forward key (W or custom key)
        yield("/hold " .. move_forward_key)
        counter = counter + 1

        if table_contains(key_1_intervals, counter) then
            yield("/send KEY_1")
        end

        if counter == 90 then
            yield("/send KEY_2")
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
    end
end
