--[[

      ***********************************************
      *            Auto Jumbo Cactpot               * 
      ***********************************************

      *************************
      *  Author: GitHixy      *
      *************************

      **********************
      * Version  |  1.0    *
      **********************

      ***************
      * Description *
      ***************

      This script buys weekly Jumbo Tickets.
      You can make a macro with /snd run "Your_script_name_here"

      *********************
      *  Required Plugins *
      *********************

      Plugins that are used are:
      -> Teleporter
      -> vnavmesh 
      -> Something Need Doing [Expanded Edition]
      -> Lifestream
           
]]--



-- Function to check if the player is in The Gold Saucer

function getCurrentZone()
    local currentZoneId = GetZoneID()  
    return currentZoneId == 144
end

-- Function to teleport to The Gold Saucer if not already there

function teleportToGoldSaucer()
    if not getCurrentZone() then
        yield('/tp The Gold Saucer')
        yield('/wait 12')  -- Wait for teleportation to complete, Adjust if needed.
    end
    useAethernetToJumboCactpot()
end

-- Function to use Aethernet to teleport to the Jumbo Cactpot Broker

function useAethernetToJumboCactpot()
    yield('/target Aetheryte')  
    yield('/vnav movetarget')   
    yield('/vnav stop')
    yield('/wait 0.5')
    yield('/li Cactpot Board')
    yield('/vnav reload')
    yield('/wait 8')
    yield('/target Jumbo Cactpot Broker')  
    yield('/vnav movetarget')  
    yield('/wait 8')
    yield('/vnav stop')
    yield('/interact')
    yield('/wait 0.5')
    yield('/click Talk Click')
    yield('/wait 3')
end

-- Function to handle purchasing all Jumbo Cactpot tickets

function purchaseAllCactpotTickets()

    repeat
        yield('/wait 0.5')
    until IsAddonVisible('SelectString')
    yield('/wait 0.5')
    yield('/callback SelectString true 0')
    yield('/wait 0.5')

    -- Loop to purchase each Cactpot ticket

    for i = 0, 2 do
        if IsAddonVisible('SelectYesno') then
            yield('/callback SelectYesno true 0')
        end
        repeat
            yield('/wait 1')
        until IsAddonVisible('LotteryWeeklyInput')
        yield('/wait 0.5')
        yield('/callback LotteryWeeklyInput true ' .. math.random(9999))
        yield('/wait 0.5')
        yield('/callback SelectYesno true 0')
        yield('/wait 0.5')
    end

    -- Finalize and exit the dialog

    repeat
        yield('/click Talk Click')
        yield('/wait 1')
    until not IsAddonVisible('Talk')
end


-- Main function to handle buying Jumbo Cactpot tickets

function buyJumboCactpotTickets()
    teleportToGoldSaucer()
    purchaseAllCactpotTickets()
end

-- Start the main function

buyJumboCactpotTickets()