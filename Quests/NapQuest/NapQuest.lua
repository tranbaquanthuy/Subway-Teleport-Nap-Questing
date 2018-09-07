local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Nap Quest'
local level = 0


local dialogs = {
	npcGuardian = Dialog:new({
	    "Hello.",
		"speaking to the power plant's site-manager in Wattson",
	}),
	npcquest = Dialog:new({
		"I miss my Jigglypuff"
	}),

}

local NapQuest = Quest:new()

function NapQuest:new()
	o = Quest.new(NapQuest, name, description, level, dialogs)
	o.pokemonId = 1
	return o
end


function NapQuest:isDoable()
	if self:hasMap()  then
		return true
	end
	return false
end

function NapQuest:isDone()
	if  getMapName() == "Nap Cave" then
		return true
	else
		return false
	end
end


function NapQuest:PokecenterNapTown()
moveToMap("Nap Town")
end

function NapQuest:NapTown()
	if isNpcOnCell(31,7) and dialogs.npcquest.state == false  then 
	talkToNpcOnCell(31,7)
    else 	
      moveToMap("Sleeping Path")
	end 
end

function NapQuest:SleepingPath()
	if isNpcOnCell(38,5) and dialogs.npcquest.state == true  then 
	  talkToNpcOnCell(38,5)
	elseif isNpcOnCell(38,5) and dialogs.npcquest.state == false  then 
	   moveToMap("Nap Town")
    else 	
      moveToMap("Nap Cave")
	end 
end


return NapQuest