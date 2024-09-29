chocoboRaceScript = true
zone = GetZoneID()
GSPage = 490

while chocoboRaceScript do
    repeat
        zone = GetZoneID()
    until zone == 388

    repeat
        
    yield("/wait 1")
    OpenRegularDuty(GSPage) 
    yield("/wait 0.5")

    if GetNodeListCount("ContentsFinder") > 0 then
       yield("/echo Duty Finder is ready.")
       break  -- Break out of the loop if it's ready
    end

    until false
    
    yield("/pcall ContentsFinder false 12 1") -- Clear Selection
    yield("/wait 1")
    yield("/pcall ContentsFinder false 3 10") -- Check Chocobo Random Race
    yield("/wait 1")
    yield("/echo Random Race Selected.")
    yield("/pcall ContentsFinder false 12 0") -- Start Duty Finder
    yield("/wait 3")
    yield("/dutyfinder")
    yield("/dutyfinder") -- Close Duty Finder Window
    
    
    repeat
        yield("/wait 3")
        until IsAddonReady("ContentsFinderConfirm")
        yield("/click ContentsFinderConfirm Commence") -- Auto Commence Duty When Ready
    
    repeat
        zone = GetZoneID()
        yield("/wait 1")
    until zone ~= 388

    counter = 0
    repeat
        yield("/hold W") -- Set Key that is simulated as pressed
        counter = counter + 1
        if counter == 15 or
            counter == 30 or
            counter == 45 or
            counter == 60 or
            counter == 75 or
            counter == 91 or
            counter == 105 or
            counter == 120 or
            counter == 135 then
            yield("/send KEY_1")  -- Use Skill 1
        end
        if counter == 90 then
            yield("/send KEY_2") -- Use Skill 2
        end
        yield("/wait 1")
    until IsAddonReady("RaceChocoboResult")

    yield("/wait 9")
    yield("/e Exiting from Chocobo Race!")
    yield("/pcall RaceChocoboResult true 1 0 <wait.1>")
    yield("/release W") -- Release the Key
end