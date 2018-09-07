local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Teleport Quest'
local level = 0
local cities = 
{
   ["Pokecenter Oldale Town"] = false,
   ["Pokecenter Petalburg City"] = false,
   ["Pokecenter Rustboro City"] = false,
   ["Pokecenter Dewford Town"] = false,
   ["Pokecenter Slateport"] = false,
   ["Pokecenter Mauville City"] = false,
   ["Pokecenter Verdanturf"] = false,
   ["Pokecenter Fallabor Town"] = false,
   ["Pokecenter Lavaridge Town"] = false,
   ["Pokecenter Fortree City"] = false,
   ["Pokecenter Lilycove City"] = false,
   ["Pokecenter Mossdeep City"] = false,
   ["Pokecenter Sootopolis City"] = false,
   ["Pokecenter Pacifidlog Town"] = false,
   ["Pokecenter Ever Grande City"] = false,
}

local dialogs = {
	npcGuardian = Dialog:new({
	    "Hello.",
		"speaking to the power plant's site-manager in Wattson",
	}),
	npcFinish = Dialog:new({
		"23trbddijd"
	}),
	npcWatsonInMauville	 = Dialog:new({
		"Find my Plusle and Minun in the facility, and tell them to charge up the generators!"
	}),
	npcCaughtP	 = Dialog:new({
		"The Plusle latches itself to the conductorial rod and harnesses its electrical energy to charge it up"
	}),
	npcFinishedMauville	 = Dialog:new({
	"What are you doing here?",
	"Go to all the transmat station lobbies in each Pokemon center and install the program from disk I gave you on at least 3 computers!"
	}),
	npcStartQuest =  Dialog:new({
	"So you might as well bring everything back on.",
	"Lots of people in the city are also being affected.",
    "Who would have thought the gym leader would have gone insane so early!",

}),
}

local TeleportQuest = Quest:new()

function TeleportQuest:new()
	o = Quest.new(TeleportQuest, name, description, level, dialogs)
	o.pokemonId = 1
	return o
end


function TeleportQuest:isDoable()
	if self:hasMap()  then
		return true
	end
	return false
end

function TeleportQuest:isDone()
	if  dialogs.npcFinish.state then
		return true
	else
		return false
	end
end
function CheckMaps(mapName)
    cities[mapName] = true
end	
function TeleportQuest:MauvilleCity()
if   dialogs.npcFinishedMauville.state and game.isTeamFullyHealed() then
 return fatal("Done the  first part of the quest  , need find 3 pc ")
elseif getItemQuantity("Super potion") < 20 and getMoney() >  14000 then 
 return moveToMap("Mart Mauville City")
elseif  not game.isTeamFullyHealed() then
		return moveToMap("Pokecenter Mauville City")
		
elseif   not dialogs.npcGuardian.state   then
		return moveToMap("Pokecenter Mauville City")
	elseif not dialogs.npcWatsonInMauville.state then
		return moveToCell(22,30)
	end
end
function TeleportQuest:MartMauvilleCity()
if getItemQuantity("Super potion") < 20 and getMoney() >  14000 then 
		if not isShopOpen() then
			return talkToNpcOnCell(3,5) 
		else
			
			return buyItem("Super potion", 20)
		end
else 
     return	moveToMap("Mauville City")
end 
end
function TeleportQuest:PokecenterMauvilleCity()  
if not game.isTeamFullyHealed() then 
   return self:pokecenter("Mauville City")
elseif getTeamSize() < 6 and not hasPokemonInTeam("Gyarados") then 
  if isPCOpen() then
if isCurrentPCBoxRefreshed() then
	if getCurrentPCBoxSize() ~= 0 then
	    for pokemon=1, getCurrentPCBoxSize() do
		if getPokemonNameFromPC(getCurrentPCBoxId(),pokemon) == "Gyarados" and getTeamSize() == 6  then	
	 return  swapPokemonFromPC(getCurrentPCBoxId(),pokemon) --swap the pokemon with last pokemon in team
    elseif getPokemonNameFromPC(getCurrentPCBoxId(),pokemon) == "Gyarados" and getTeamSize() < 6  then	
	return  withdrawPokemonFromPC(getCurrentPCBoxId(),pokemon) --swap the pokemon with last pokemon in team
	elseif getPokemonLevelFromPC(getCurrentPCBoxId(),pokemon)>= 90  then	
	return  withdrawPokemonFromPC(getCurrentPCBoxId(),pokemon) --swap the pokemon with last pokemon in team
								end
						end
						return openPCBox(getCurrentPCBoxId()+1)
					end
				else
					return
				end
else
return usePC()
end
elseif  not dialogs.npcGuardian.state  then
   return  talkToNpcOnCell(8,4)
  else
  return	moveToMap("Mauville City")
end
end 
function TeleportQuest:TransmatStation()
       if isNpcOnCell(15,5) then 
		  talkToNpcOnCell(15,5)
	   elseif not isNpcOnCell(15,5) and not isNpcOnCell(1,7) then 
	       fatal("done the quest")
      end 
end

function TeleportQuest:Route118()
	return	moveToMap("Mauville City Stop House 4")

end
function TeleportQuest:MauvilleCityStopHouse2()
	
	return	moveToMap("Mauville City")
end
 function TeleportQuest:MauvilleCityStopHouse1()
 if dialogs.npcFinishedMauville.state then 
	  return moveToMap("Mauville City")
	  else
		return	moveToMap("Route 110")
end	
end
function TeleportQuest:Route110()
	 if dialogs.npcFinishedMauville.state then 
	  return moveToMap("Mauville City Stop House 1")
	  else
		return moveToMap("New Mauville Entrance")
end
end 
function TeleportQuest:NewMauvilleEntrance()
	if isNpcOnCell(12,7) and not dialogs.npcStartQuest.state then
return	talkToNpcOnCell(12,7)
    elseif isNpcOnCell(12,7) and dialogs.npcStartQuest.state then  
	dialogs.npcStartQuest.state = false 
  return relog(1,"relog")
	elseif isNpcOnCell(13,7) then 
return	talkToNpcOnCell(13,7)
   elseif dialogs.npcFinishedMauville.state then
   return moveToMap("Route 110")
	else 
	return	moveToMap("New Mauville")
end
end 
function TeleportQuest:NewMauville()
if dialogs.npcFinishedMauville.state then 
 return moveToMap("New Mauville Entrance")
	if isNpcOnCell(53,57) then
return	talkToNpcOnCell(53,57)
	elseif isNpcOnCell(51,62) then 
return	talkToNpcOnCell(51,62)
elseif isNpcOnCell(59,59) then -- Vortorb
return	talkToNpcOnCell(59,59)
elseif isNpcOnCell(55,38) then 
return	talkToNpcOnCell(56,38)
elseif isNpcOnCell(44,38) then 
return	talkToNpcOnCell(44,38)
elseif isNpcOnCell(27,42) then 
return	talkToNpcOnCell(27,42)
elseif isNpcOnCell(21,55) then 
return	talkToNpcOnCell(21,55)
elseif isNpcOnCell(21,40)   then 
return	talkToNpcOnCell(7,45)
elseif isNpcOnCell(4,9)   then 
return	talkToNpcOnCell(4,9)
elseif isNpcOnCell(25,6)   then 
return	talkToNpcOnCell(25,6)
elseif isNpcOnCell(51,6)   then 
return	talkToNpcOnCell(51,6)
elseif not isNpcOnCell(51,6)  and not isNpcOnCell(56,7) then 
return relog(1,"relog")
elseif not dialogs.npcWatsonInMauville.state and isNpcOnCell(56,7) then
return talkToNpcOnCell(56,7)
elseif  dialogs.npcWatsonInMauville.state  and not  isNpcOnCell(25,60) and not dialogs.npcCaughtP.state  then
return relog(1,"relog")
elseif  dialogs.npcWatsonInMauville.state  and isNpcOnCell(35,29)  and  getPlayerX() <  36 and  getPlayerY() < 29 then
    return  moveToCell(36,29)
elseif  dialogs.npcWatsonInMauville.state  and isNpcOnCell(35,29) then --and  getPlayerX ==  34 and  getPlayerY == 29 then
    return talkToNpcOnCell(35,29)
--elseif   getPlayerX ~=  34 and  getPlayerY ~= 29 then  --dialogs.npcWatsonInMauville.state  and isNpcOnCell(35,29) and 
  --  return moveToCell(34,29)
elseif  dialogs.npcWatsonInMauville.state  and not isNpcOnCell(35,29) and  not dialogs.npcFinishedMauville.state then
    return  talkToNpcOnCell(56,7)
--elseif  dialogs.npcWatsonInMauville.state and isNpcOnCell(25,60)  then
--return talkToNpcOnCell(25,60)

end
end 
function TeleportQuest:MauvilleCityStopHouse3()
	
		moveToMap("Mauville City")
end

function TeleportQuest:Route111South()	
		
			moveToMap("Mauville City Stop House 3")
end
	
function TeleportQuest:Route117()

 moveToMap("Mauville City Stop House 2")
	
end

function TeleportQuest:MauvilleCityGameCorner()
end
	
function TeleportQuest:MauvilleCityHouse2()
end


return TeleportQuest