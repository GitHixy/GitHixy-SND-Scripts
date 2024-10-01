--[[

Auto Chocobo Race v1.15 by GitHixy
Reworked logic inspired by Jaksuhn's Auto-Chocobo

Adjust /wait timers based on your connection and PC

You can make a macro with /snd run "Your_script_name_here"

Note: This script is more about convenience than competitiveness 
      so don't expect first place every time!


Happy Levelling!
      
]]--


-- Declarations

chocoboRaceScript = true
ChocoboRaceID = 21

-- Helper Function (Don't Touch)

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
        
    yield("/wait 3")
    OpenRouletteDuty(21)  
    yield("/wait 2")

    if GetNodeListCount("ContentsFinder") > 0 then
       yield("/echo Duty Finder is ready.")
       break  
    end

    until false

-- Clear Selection

    yield("/pcall ContentsFinder false 12 1") 
    yield("/wait 1")

-- Select Chocobo Race: Random

    yield("/pcall ContentsFinder false 3 10") 
    yield("/wait 1")
    yield("/echo Random Race Selected.")

-- Start Duty Finder

    yield("/pcall ContentsFinder false 12 0") 
    yield("/wait 3")
    yield("/dutyfinder")

-- Close Duty Finder Window

    yield("/dutyfinder") 
    
    
    repeat
        yield("/wait 3")
        until IsAddonReady("ContentsFinderConfirm")

-- Auto Commence Duty When Ready

        yield("/click ContentsFinderConfirm Commence") 
    
    repeat
        zone = GetZoneID()
        yield("/wait 1")
    until zone ~= 388

    counter = 0

-- Intervals for KEY_1

    key_1_intervals = {15, 30, 45, 60, 75, 91, 105, 120, 135}  

    repeat
       yield("/hold W")
       counter = counter + 1

-- Send KEY_1 at the specified intervals

       if table_contains(key_1_intervals, counter) then
          yield("/send KEY_1")
    end

-- Send KEY_2 at counter 90

    if counter == 90 then
        yield("/send KEY_2")
    end

    yield("/wait 1")
until IsAddonReady("RaceChocoboResult")

-- Show Bonus and Exit Duty

    yield("/wait 9")
    yield("/e Exiting from Chocobo Race!")
    yield("/release W")
    yield("/pcall RaceChocoboResult true 1 0 <wait.1>")
    yield("/wait 4")
end