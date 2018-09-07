local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Subway Quest'
local level = 0
local localCheck = 
{
    ["Saffron Pokemart"] = false,
	["Digglet"] = false,
	["Power Plant"] = false,
	["Route 21"] = false,
	["Victory Road"] = false
}
local dialogs = {
	acceptQuestFromYorkie = Dialog:new({ 
		"I have no idea where my brother is, but he would never leave Kanto, so I guess that's a start.."
	}),
	acceptFindingNocturnalFeather = Dialog:new({ 
		"If you are looking for the Nocturnal Feather, look for Pidgeotto on this Route."
	}),
	openSubway = Dialog:new({ 
		"Enjoying our Subway System?"
	}),
	acceptFindingNocturnalFeather2 = Dialog:new({
	"The people from these parts say that at night, Pidgeotto come on this route."
}),
}

local SubwayQuest = Quest:new()

function SubwayQuest:new()
	local o = Quest.new(SubwayQuest, name, description, level, dialogs)
	o.pokemonId = 1
	return o
end

function SubwayQuest:isDoable()
	if self:hasMap()  then
		return true
	end
	return false
end

function SubwayQuest:isDone()
	if hasItem("HM02 - Fly") and dialogs.openSubway.state == true   then
		return true
	else
		return false
	end
end

function SubwayQuest:CeladonCity()
    if hasItem("HM02 - Fly")  then 
	 return moveToMap("Route 7")
	elseif ( dialogs.acceptQuestFromYorkie.state == false and  not dialogs.acceptFindingNocturnalFeather.state and not   dialogs.acceptFindingNocturnalFeather2.state  ) 
	or ( not hasItem("Nocturnal Feather") and (dialogs.acceptFindingNocturnalFeather.state or dialogs.acceptFindingNocturnalFeather2.state))
    or hasItem("Yorkie Parcel")	then 
		return moveToCell(0,42)
    else 
	    return moveToMap("Route 7")
end
end 
function SubwayQuest:Route16()
 for i=1,getTeamSize() do
  if  getPokemonHeldItem(i)	then 
   return takeItemFromPokemon(i)
  end 
  end
if hasItem("HM02 - Fly") and  game.inRectangle(25,0,63,17) then 
 return moveToMap("Route 16 Stop House") 
elseif hasItem("HM02 - Fly") and game.inRectangle(70,0,90,20) then 
return  moveToMap("Celadon City")
elseif   hasItem("Nocturnal Feather") and game.inRectangle(25,0,63,17)  then  
return  moveToMap("Route 16 house")
elseif game.inRectangle(25,0,63,17) and  ((dialogs.acceptQuestFromYorkie.state == false and   dialogs.acceptFindingNocturnalFeather.state == false and dialogs.acceptFindingNocturnalFeather2.state == false) or  hasItem("Yorkie Parcel") ) then 
    return  moveToMap("Route 16 house")
elseif  game.inRectangle(25,0,63,17) and 	((dialogs.acceptQuestFromYorkie.state == true and not  hasItem("Yorkie Parcel") ) or ((dialogs.acceptFindingNocturnalFeather.state == true or  dialogs.acceptFindingNocturnalFeather2.state == true) and not hasItem("Nocturnal Feather") ) ) then 
return  moveToMap("Route 16 Stop House") 
elseif (hasItem("Yorkie Parcel") or ( dialogs.acceptQuestFromYorkie.state == false and dialogs.acceptFindingNocturnalFeather.state == false and dialogs.acceptFindingNocturnalFeather2.state == false))
  and game.inRectangle(70,0,90,20) and not hasItem("Nocturnal Feather") then 
   return  moveToMap("Route 16 Stop House") 
elseif (dialogs.acceptFindingNocturnalFeather.state == true or dialogs.acceptFindingNocturnalFeather2.state == true  )  and not hasItem("Nocturnal Feather") and game.inRectangle(70,0,90,20)  then 
  if isNight()  then
 return moveToGrass()
 else
 return fatal("Wait the time to catch , only  Night  you can catch Pidgeotto with Nocturnal Feather")
 end
elseif   hasItem("Nocturnal Feather") and game.inRectangle(70,0,90,20)  then  
return  moveToMap("Route 16 Stop House")
elseif   hasItem("Nocturnal Feather") and game.inRectangle(25,0,63,17)  then  
return  moveToMap("Route 16 house")
elseif ( dialogs.acceptQuestFromYorkie.state == true  or dialogs.acceptFindingNocturnalFeather.state == true)  and game.inRectangle(70,8,90,20)   then 
return  moveToMap("Celadon City")
end 
end	

function SubwayQuest:Route16StopHouse()
if hasItem("HM02 - Fly") then 
 return  moveToCell(20,6)
elseif hasItem("Nocturnal Feather") then 
return moveToCell(0,6)
elseif  dialogs.acceptQuestFromYorkie.state == false and  dialogs.acceptFindingNocturnalFeather.state == false  then 
	return moveToCell(0,6)
elseif (dialogs.acceptFindingNocturnalFeather.state == true  and  hasItem("Nocturnal Feather")) or hasItem("Yorkie Parcel")  then  
return moveToCell(0,6)
else
    return  moveToCell(20,6)
end
end
function SubwayQuest:Route16house()
if hasItem("HM02 - Fly") then 
 return  moveToMap("Route 16")
elseif dialogs.acceptQuestFromYorkie.state == false  and not  dialogs.acceptFindingNocturnalFeather.state  then 
    return talkToNpcOnCell(5,7)
elseif hasItem("Yorkie Parcel") then 
     return talkToNpcOnCell(5,7)
elseif  hasItem("Nocturnal Feather") then
 return talkToNpcOnCell(5,7)
else 
    return  moveToMap("Route 16")
end
end 
function SubwayQuest:Route17()
	return moveToMap("Route 18")
end

function SubwayQuest:Route18()
	return moveToMap("Bike Road Stop")
end

function SubwayQuest:PokecenterCeladon()
if getTeamSize() >= 3 then 
    if isPCOpen() then
    return  depositPokemonToPC(3)
    else 
	return usePC()
      end

else
	return self:pokecenter("Celadon City")
	end 
end

function SubwayQuest:Route7()
if hasItem("HM02 - Fly") then 
  return moveToMap("Route 7 Stop House")
elseif not hasItem("Yorkie Parcel") then 
   return moveToMap("Route 7 Stop House")
else
   return moveToMap("Celadon City")
end
end 
function SubwayQuest:Route7StopHouse()
if hasItem("HM02 - Fly") then 
return moveToMap("Link")
elseif hasItem("Yorkie Parcel") then 
   return moveToMap("Route 7")
 else
	return moveToMap("Link")
end 
end
function SubwayQuest:SaffronCity()
if hasItem("HM02 - Fly") then 
return moveToMap("Saffron City Station")
elseif hasItem("Yorkie Parcel") then 
		return moveToMap("Route 7 Stop House")
elseif  not hasItem("Yorkie Parcel") and localCheck["Saffron Pokemart"] == false  then 
     return moveToMap("Saffron Pokemart")
elseif not hasItem("Yorkie Parcel") and localCheck["Digglet"] == false  then
 return moveToMap("Route 6 Stop House")
end 
end
function SubwayQuest:Route6StopHouse()
if not hasItem("Yorkie Parcel") and localCheck["Digglet"] == false  then
 return moveToMap("Route 6")
else
    return moveToMap("Link")
end 
end
function SubwayQuest:Route6()
if not hasItem("Yorkie Parcel") and localCheck["Digglet"] == false  then
 return moveToMap("Vermilion City")
else
    return moveToMap("Route 6 Stop House")
end 
end
function SubwayQuest:VermilionCity()
if not hasItem("Yorkie Parcel") and localCheck["Digglet"] == false  then
 return moveToMap("Route 11")
else
    return moveToMap("Route 6")
end 
end 
function SubwayQuest:Route11()
if not hasItem("Yorkie Parcel") and localCheck["Digglet"] == false  then
 return moveToMap("Digletts Cave Entrance 2")
elseif not hasItem("Yorkie Parcel") and localCheck["Power Plant"] == false  then
 return moveToMap("Link")
else
    return moveToMap("Vermilion City")
end 
end
function SubwayQuest:Route11StopHouse()
if not hasItem("Yorkie Parcel") and localCheck["Power Plant"] == false  then
 return moveToMap("Route 12")
else
    return moveToMap("Route 11")
end 
end
function SubwayQuest:Route12()
if  hasItem("Yorkie Parcel") then 
    return moveToMap("Route 11 Stop House")
elseif  localCheck["Power Plant"] == false  then
 return moveToMap("Lavender Town")
elseif  localCheck["Route 21"] == false  then
 return moveToMap("Route 13")
end 
end
function SubwayQuest:Route13()
 return moveToMap("Route 14") 
end
function SubwayQuest:Route14()
 return moveToMap("Route 15") 
end
function SubwayQuest:Route15()
 return moveToMap("Route 15 Stop House") 
end
function SubwayQuest:Route15StopHouse()
 return moveToMap("Fuchsia City") 
end
function SubwayQuest:FuchsiaCity()
 return moveToMap("Fuchsia City Stop House") 
end
function SubwayQuest:FuchsiaCityStopHouse()
return moveToMap("Route 19")
end
function SubwayQuest:Route19()
return moveToMap("Route 20")
end 
function SubwayQuest:Route20()
if game.inRectangle(55,21,120,38) then 
return moveToMap("Seafoam 1F")
else 
return moveToMap("Cinnabar Island")
end
end
function SubwayQuest:Seafoam1F()
if game.inRectangle(5,5,21,17) then 
return moveToMap("Seafoam B1F")
elseif game.inRectangle(63,5,79,17) then
return moveToMap("Route 20") 
end 
end
function SubwayQuest:SeafoamB1F()
moveToCell(85,22)
end
function SubwayQuest:CinnabarIsland()
moveToMap("Route 21") 
end 
function SubwayQuest:Route21()
if isNpcOnCell(26,40) then 
return talkToNpcOnCell(26,40)
elseif not isNpcOnCell(26,40) then 
  localCheck["Route 21"] = true 
  moveToMap("Pallet Town") 
end
end 
function SubwayQuest:PalletTown()
moveToMap("Route 1") 
end   
function SubwayQuest:Route1()
moveToMap("Route 1 Stop House") 
end
function SubwayQuest:Route1StopHouse()
moveToMap("Viridian City") 
end
function SubwayQuest:ViridianCity()
if not hasItem("Yorkie Parcel") and localCheck["Victory Road"] == false then 
return moveToMap("Route 22") 
else 
return moveToMap("Route 2")
end 
end
function SubwayQuest:Route2()
if game.inRectangle(0,95,45,130) then 
  return moveToMap("Route 2 Stop")
else 
  return moveToMap("Pewter City")
end 
end 
function SubwayQuest:Route2Stop()
  return moveToMap("Viridian Forest")
end
function SubwayQuest:PewterCity()
  moveToCell(65,32)
end  
function SubwayQuest:Route3()
return moveToMap("Mt. Moon 1F")
end 
function SubwayQuest:MtMoon1F()
return moveToCell(21, 20) -- Mt. Moon B1F
end  
function SubwayQuest:MtMoonB1F()
    if game.inRectangle(56, 18, 66, 21) then
		return moveToCell(65, 20) -- Mt. Moon B2F (wrong way)
	elseif game.inRectangle(73, 15, 78, 34)
		or game.inRectangle(53, 29, 78, 34)
	then
		return moveToCell(56, 34) -- Mt. Moon B2F (right way)
	elseif game.inRectangle(32, 19, 42, 22) then
		return moveToCell(41, 20) -- Mt. Moon Exit
	else
		error("MoonFossilQuest:MtMoonB1F(): [" .. getPlayerX() .. "," .. getPlayerY() .. "] is not a known position")
	end
end  
function SubwayQuest:MtMoonB2F()
	if game.inRectangle(10, 22, 63, 64) then
		if isNpcOnCell(25, 29) and isNpcOnCell(26, 29) then -- fossile on the way
			if dialogs.fossileGuyBeaten.state then
				if KANTO_FOSSIL_ID == 1 then
					return talkToNpcOnCell(25, 29)
				elseif KANTO_FOSSIL_ID == 2 then
					return talkToNpcOnCell(26, 29)
				else
					fatal("undefined KANTO_FOSSIL_ID")
				end
			else
				return talkToNpcOnCell(23, 31)
			end
		elseif isNpcOnCell(26, 23) then
			return talkToNpcOnCell(26, 23) -- Team Rocket
		else
			return moveToCell(17, 27) -- Mt. Moon B1F
		end
	else
		error("MoonFossilQuest:MtMoonB2F(): [" .. getPlayerX() .. "," .. getPlayerY() .. "] is not a known position")
	end
end
function SubwayQuest:MtMoonExit()
	return moveToMap("Route 4")
end

function SubwayQuest:Route4()
	return moveToCell(96, 21) -- Cerulean City (avoid water link)
end
function SubwayQuest:CeruleanCity()
	return moveToMap("Route 5") -- Cerulean City (avoid water link)
end
function SubwayQuest:Route5()
	return moveToMap("Route 5 Stop House") -- Cerulean City (avoid water link)
end
function SubwayQuest:Route5StopHouse()
	return moveToMap("Link") -- Cerulean City (avoid water link)
end
function SubwayQuest:ViridianForest()
  moveToMap("Route 2 Stop2")
end     
function SubwayQuest:Route2Stop2()
	return moveToMap("Route 2")
end 
function SubwayQuest:Route22()
if localCheck["Victory Road"] == false then 
return moveToMap("Link") 
else 
return moveToMap("Viridian City")
end 
end
function SubwayQuest:PokemonLeagueReceptionGate()
if localCheck["Victory Road"] == false then 
return moveToMap("Victory Road Kanto 1F") 
else 
return moveToMap("Route 22")
end 
end
function SubwayQuest:VictoryRoadKanto1F()
if localCheck["Victory Road"] == false then 
return moveToMap("Victory Road Kanto 2F") 
else 
return moveToMap("Pokemon League Reception Gate")
end 
end
function SubwayQuest:VictoryRoadKanto2F()
if localCheck["Victory Road"] == false and game.inRectangle(31,23,38,26) and isNpcOnCell(38,24)  then 
return talkToNpcOnCell(38,24)
elseif localCheck["Victory Road"] == false and  (game.inRectangle(58,29,65,31) or game.inRectangle(59,11,66,28) or game.inRectangle(49,11,60,20)) then
return moveToCell(62,11)
elseif localCheck["Victory Road"] == false and not game.inRectangle(31,23,38,26)  then 
--return moveToCell(14,9)
return moveToCell(57,25)
elseif game.inRectangle(31,23,38,26) and not isNpcOnCell(38,24)  then
localCheck["Victory Road"] = true 
return moveToCell(33,29)
else 
return moveToMap("Victory Road Kanto 1F") 
end 
end	
function SubwayQuest:VictoryRoadKanto3F()
if game.inRectangle(54,29,65,40) then 
 return moveToCell(61,35)
elseif  game.inRectangle(49,14,65,28) or  game.inRectangle(44,23,49,25)  
or game.inRectangle(44,23,45,34) or game.inRectangle(27,30,45,32) or game.inRectangle(33,33,45,34)then 
  return moveToCell(35,33)
else
moveToCell(29,17)
end 
end               
function SubwayQuest:LavenderTown()
if not hasItem("Yorkie Parcel") and localCheck["Power Plant"] == false  then
 return moveToMap("Route 10")
else
    return moveToMap("Route 12")
end 
end
function SubwayQuest:Route10()
if game.inRectangle(0,41,40,71) and not isNpcOnCell(20,25) and not hasItem("Yorkie Parcel")  then 
  localCheck["Power Plant"] = true 
  return moveToMap("Lavender Town")
--elseif game.inRectangle(0,41,40,71)  and localCheck["Power Plant"] == false then 
 -- return moveToMap("Rock Tunnel 1")
elseif game.inRectangle(0,41,40,71)  and localCheck["Power Plant"] == false then 
  return moveToMap("Rock Tunnel 1")
elseif game.inRectangle(9,0,24,11) and localCheck["Power Plant"] == true  then
 return moveToMap("Link")
elseif game.inRectangle(9,0,24,11) and localCheck["Power Plant"] == false  then
return moveToMap("Route 9")
elseif (game.inRectangle(27,0,31,30) or game.inRectangle(8,22,26,34) )  and localCheck["Power Plant"] == false and isNpcOnCell(20,25) then
return talkToNpcOnCell(20,25)
elseif (game.inRectangle(27,0,31,30) or game.inRectangle(8,22,26,34) )
  and not isNpcOnCell(20,25) 
  then
  localCheck["Power Plant"] = true 
return moveToCell(28,0)
else
    return moveToMap("Lavender Town")
end 
end
function SubwayQuest:Route9()
if  localCheck["Power Plant"] == false and not hasItem("Yorkie Parcel") then
return moveToCell(91,33)
else
  return moveToCell(86,33)
end
end 
function SubwayQuest:RockTunnel1()
if game.inRectangle(2,20,41,33) and   localCheck["Power Plant"] == false  then
 return moveToCell(7,30)
elseif game.inRectangle(33,8,45,18) and  localCheck["Power Plant"] == true then
		return moveToCell(35,16)
elseif game.inRectangle(33,8,45,18) and  localCheck["Power Plant"] == false then
		return moveToCell(43,11)
elseif game.inRectangle(2,4,30,18) and  localCheck["Power Plant"] == false then
		return moveToCell(7,7)
elseif game.inRectangle(6,6,29,17) and localCheck["Power Plant"] == true then
		return moveToCell(8,15)
else
    return moveToMap("Route 10")
end 
end
function SubwayQuest:RockTunnel2()
if game.inRectangle(3,12,30,30)  and localCheck["Power Plant"] == false  then
 return moveToCell(10,13)
elseif game.inRectangle(3,12,30,30) and localCheck["Power Plant"] == true  then
     return moveToCell(8,26)
elseif ( game.inRectangle(3,5,48,11) or game.inRectangle(36,11,37,17) ) and localCheck["Power Plant"] == false  then
return moveToCell(36,16)
elseif ( game.inRectangle(3,5,48,11) or game.inRectangle(36,11,37,17) ) and localCheck["Power Plant"] == true  then
return moveToCell(7,5)
end 
end
function SubwayQuest:DiglettsCaveEntrance2()
if not hasItem("Yorkie Parcel") and localCheck["Digglet"] == false  then
 return moveToMap("Digletts Cave")
else
return moveToMap("Route 11")
end 
end
function SubwayQuest:DiglettsCave()
if not hasItem("Yorkie Parcel") and localCheck["Digglet"] == false and isNpcOnCell(17,24)  then
 return talkToNpcOnCell(17,24)
elseif not  isNpcOnCell(17,24) and not hasItem("Yorkie Parcel") then 
 localCheck["Digglet"] = true 
 log("Checked Digglet Cave")
 return moveToMap("Digletts Cave Entrance 2")
else
return moveToMap("Digletts Cave Entrance 2")
end 
end    
function SubwayQuest:SaffronCityStation()
if not dialogs.openSubway.state then 
 return talkToNpcOnCell(12,16)
else
  return fatal("Done  subway")
end 
end
function SubwayQuest:SaffronPokemart()
if isNpcOnCell(13,7) then 
    return talkToNpcOnCell(13,7)
elseif hasItem("Yorkie Parcel") then 
   return moveToMap("Saffron City")
elseif not isNpcOnCell(13,7) and not hasItem("Yorkie Parcel") then 
localCheck["Saffron Pokemart"] = true 
log("Checked Saffron Pokemart")
    return moveToMap("Saffron City")
end
end 

return SubwayQuest
