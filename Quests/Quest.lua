-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys  = require "Libs/syslib"
local game = require "Libs/gamelib"

local blacklist = require "blacklist"

local Quest = {}

function Quest:new(name, description, level, dialogs)
	local o = {}
	setmetatable(o, self)
	self.__index     = self
	o.name        = name
	o.description = description
	o.level       = level or 1
	o.dialogs     = dialogs
	o.training    = true
	return o
end



function Quest:isDoable()
	sys.error("Quest:isDoable", "function is not overloaded in quest: " .. self.name)
	return nil
end

function Quest:isDone()
	return self:isDoable() == false
end

function Quest:mapToFunction()
	local mapName = getMapName()
	local mapFunction = sys.removeCharacter(mapName, ' ')
	mapFunction = sys.removeCharacter(mapFunction, '.')
	mapFunction = sys.removeCharacter(mapFunction, '-') -- Map "Fisherman House - Vermilion"
	return mapFunction
end

function Quest:hasMap()
	local mapFunction = self:mapToFunction()
	if self[mapFunction] then
		return true
	end
	return false
end

function Quest:pokecenter(exitMapName) -- idealy make it work without exitMapName
	self.registeredPokecenter = getMapName()
	sys.todo("add a moveDown() or moveToNearestLink() or getLinks() to PROShine")
	if not game.isTeamFullyHealed() then
		return usePokecenter()
	else
		return moveToMap(exitMapName)
	end
end

-- at a point in the game we'll always need to buy the same things
-- use this function then
function Quest:pokemart(exitMapName)
	local pokeballCount = getItemQuantity("Pokeball")
	local money         = getMoney()
	if money >= 200 and pokeballCount < 20 then
		if not isShopOpen() then
			return talkToNpcOnCell(3,5) 
		else
			local pokeballToBuy = 30 - pokeballCount
			local maximumBuyablePokeballs = money / 200
			if maximumBuyablePokeballs < pokeballToBuy then
				pokeballToBuy = maximumBuyablePokeballs
			end
			return buyItem("Pokeball", pokeballToBuy)
		end
	else
		return moveToMap(exitMapName)
	end
end


function Quest:isTrainingOver()
 	if game.maxTeamLevel() >= self.level then
 		if self.training then -- end the training
 			self:stopTraining()
 		end
 		return true
 	end
 	return false
end

function Quest:leftovers()
	ItemName = "Leftovers"
	local PokemonNeedLeftovers = game.getFirstUsablePokemon()
	local PokemonWithLeftovers = game.getPokemonIdWithItem(ItemName)
	
	-- EXCEPTIONS FOR REMOVE LEFTOVERS FROM POKEMON
	if getMapName() ==  "Transmat Station" then --REMOVE LEFTOVERS FROM ODDISH - GoldenrodCityQuest.lua
		if PokemonWithLeftovers < 0 then
			giveItemToPokemon(ItemName,PokemonNeedLeftovers)
			return true
		end
		return false
	end

	
	--if getTeamSize() > 0 and not hasItem("HM02 - Fly") then
	--	if PokemonWithLeftovers > 0 then
		--	if PokemonNeedLeftovers == PokemonWithLeftovers  then
		--		return false -- now leftovers is on rightpokemon
		--	else
		--		takeItemFromPokemon(PokemonWithLeftovers)
			--	return true
		--	end
		--else
		  --  if hasItem(ItemName) and PokemonNeedLeftovers ~= 0 then
			--	giveItemToPokemon(ItemName,PokemonNeedLeftovers)
			--	return true
		--	else
				return false-- don't have leftovers in bag and is not on pokemons
		--	end
	--	end
	--else
	--	return false
	--end
end

function Quest:useBikeAndOtherStuffs()
	if isOutside() and ( hasItem("Bicycle") or hasItem("Yellow Bicycle") or hasItem("Blue Bicycle") or hasItem("Green Bicycle") ) and not isSurfing() and not isMounted() then
           log("Getting on Bicycle")
           return useItem("Bicycle") or useItem("Yellow Bicycle") or useItem("Green Bicycle") or useItem("Blue Bicycle")  
	end 

	
end

function Quest:autoEvolve()
	if getTeamSize() >= 1 and getPokemonLevel(1) <= 95 then 
		
		disableAutoEvolve() 
	else
		enableAutoEvolve()
	end
end

function Quest:startTraining()
	self.training = true
end

function Quest:stopTraining()
	self.training = false
	self.healPokemonOnceTrainingIsOver = true
end

function Quest:needPokemart()
	-- TODO: ItemManager
	if getItemQuantity("Pokeball") < 20 and getMoney() >= 200 then
		return true
	end
	return false
end

function Quest:needPokecenter()
	if getTeamSize() == 1 then
		
			return false

	-- else we would spend more time evolving the higher level ones
	
	else
		if not game.isTeamFullyHealed() then
			if self.healPokemonOnceTrainingIsOver then
				return true
			end
		else
			-- the team is healed and we do not need training
			self.healPokemonOnceTrainingIsOver = false
		end
	end
	return false
end

function Quest:message()
	return self.name .. ': ' .. self.description
end

-- I'll need a TeamManager class very soon


function Quest:advanceSorting()
	local pokemonsUsable = game.getTotalUsablePokemonCount()
	for pokemonId=1, pokemonsUsable, 1 do
		if not isPokemonUsable(pokemonId) then --Move it at bottom of the Team
			for pokemonId_ = pokemonsUsable + 1, getTeamSize(), 1 do	
				if isPokemonUsable(pokemonId_) then
					swapPokemon(pokemonId, pokemonId_)
					return true
				end
			end
			
		end
	end
   if getTeamSize() >=2  and game.minTeamLevel() >= 40 then
		if not isTeamRangeSortedByLevelAscending(1, pokemonsUsable) then --Sort the team without not usable pokemons
		return sortTeamRangeByLevelAscending(1, pokemonsUsable)
		end
	elseif not isTeamRangeSortedByLevelDescending(1, pokemonsUsable) then --Sort the team without not usable pokemons
		return sortTeamRangeByLevelDescending(1, pokemonsUsable)
		end
	return false
end



function Quest:path()
	if self.inBattle then
		self.inBattle = false
		self:battleEnd()
	end
	if self:leftovers() then
		return true
	end
	if self:autoEvolve() then
		return true
	end
	if self:advanceSorting() then
		return true
	end
	if self:useBikeAndOtherStuffs() then
		return true
	end
	local mapFunction = self:mapToFunction()
	assert(self[mapFunction] ~= nil, self.name .. " quest has no method for map: " .. getMapName())
	self[mapFunction](self)
end



function Quest:isPokemonBlacklisted(pokemonName)
	return sys.tableHasValue(blacklist, pokemonName)
end

function Quest:battleBegin()
	self.canRun = true
end

function Quest:battleEnd()
	self.canRun = true
end

-- I'll need a TeamManager class very soon
local blackListTargets = { --it will kill this targets instead catch
	 "Caterpie",     
	 "Metapod",      
	 "Butterfree",   
	 "Weedle",       
	 "Kakuna",       
	 "Beedrill",     
	 "Pidgey",       
	 "Pidgeotto",    
	 "Pidgeot",      
	 "Rattata",      
	 "Raticate",     
	 "Spearow",      
	 "Fearow",       
	 "Ekans",     
	 "Arbok",        
	 "Pikachu",      
	 "Raichu",       
	 "Sandshrew",    
	 "Sandslash",    
	 "Nidoran F",    
	 "Nidorina",     
	 "Nidoqueen",    
	 "Nidoran M",    
	 "Nidorino",     
	 "Nidoking",          
	 "Clefable",     
	 "Vulpix",       
	 "Ninetales",    
	 "Jigglypuff",   
	 "Mankey",       
	 "Poliwag",          
	 "Onix",    
	 "Abra",    
	 "Ponyta", 
	  "Doduo",     
	  "Sentret",      
	 "Furret",       
	 "Hoothoot",
	 	 "Spinarak",  
	 "Dodrio",  
	"Zigzagoon"
}

function Quest:wildBattle()
if (getTeamSize() < 2 and getPokemonHealthPercent(1) <= 25 ) or (getTeamSize() == 6 and getMapName() == "Route 16" )then 
    return relog(1,"Relogggg!!!") 
end
if getOpponentName() == "Diglett" or getOpponentName() == "Dugtrio" then 
	     return  attack() or sendUsablePokemon() or run()  
end 
if getOpponentName() == "Pidgeotto" then 
	   if useItem("Pokeball")or useItem("Great Ball") or  useItem("Ultra Ball")  then
			return true
	end
end 

	if isOpponentShiny() and getTeamSize() >= 3 then
		if useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball") or sendUsablePokemon() or run() or sendAnyPokemon() then
			return true
		end
	elseif sys.canRun == false then
		sys.canRun = true
		return  attack()  or run() or sendAnyPokemon()
	elseif self:isTrainingOver() then
		return attack()or sendAnyPokemon()  or run()
	else
		return  attack()  or sendUsablePokemon() or run() or sendAnyPokemon()
	end
end

function Quest:trainerBattle()

	-- bug: if last pokemons have only damaging but type ineffective
	-- attacks, then we cannot use the non damaging ones to continue.
	if getMapName() == "Transmat Station"  then
		 return useMove("Sucker Punch") or attack() or useMove("Struggle") or sendUsablePokemon() or sendAnyPokemon() 
	else
	   return useMove("Sucker Punch") or attack() or useMove("Struggle") or sendUsablePokemon() or sendAnyPokemon() 
	end 
	-- bug: if last pokemons have only damaging but type ineffective
	-- attacks, then we cannot use the non damaging ones to continue.
	if not self.canRun then -- trying to switch while a pokemon is squeezed end up in an infinity loop
		return useMove("Acrobatics") or attack() or game.useAnyMove()
	end
end

function Quest:battle()
	if not self.inBattle then
		self.inBattle = true
		self:battleBegin()
	end
	if isWildBattle() then
		return self:wildBattle()
	else
		return self:trainerBattle()
	end
end

function Quest:dialog(message)
	if self.dialogs == nil then
		return false
	end
	for _, dialog in pairs(self.dialogs) do
		if dialog:messageMatch(message) then
			dialog.state = true
			return true
		end
	end
	return false
end

function Quest:battleMessage(message)
	if sys.stringContains(message, "You can not run away!") then
		sys.canRun = false
	elseif self.pokemon ~= nil and self.forceCaught ~= nil then
		if sys.stringContains(message, "caught") and sys.stringContains(message, self.pokemon) then --Force caught the specified pokemon on quest 1time
			log("Selected Pokemon: " .. self.pokemon .. " is Caught")
			self.forceCaught = true
			return true
		end
	elseif sys.stringContains(message, "black out") and self.level < 49 and self:isTrainingOver() then
		self.level = self.level + 1
		self:startTraining()
		log("Increasing " .. self.name .. " quest level to " .. self.level .. ". Training time!")
		return true
	elseif sys.stringContains(message, "You can not switch this Pokemon!") then
		return relog(1,"Hello")
		

	end
	return false
end

function Quest:systemMessage(message)	
	return false
end

local hmMoves = {
	"cut",
	"surf",
	"flash"
}


function Quest:learningMove(moveName, pokemonIndex)
	return forgetAnyMoveExcept({"Leech Seed", "Shadow Ball", "Dark Pulse", "Surf", "Hex", "Air Slash", "Cut", "Acrobatics", "Poison Fang", "Thunderbolt", "Sleep Powder",  "Petal Dance",}) 
end

return Quest
