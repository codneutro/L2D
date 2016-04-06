---
-- Team Generator
--
-- @author x[N]ir
-- @release 04/04/16
Generator                  = {};

--- Random players ID
Generator.randomPlayers    = {};

--- Every possible combinations are stored here
Generator.combinations     = {};

--- List of players ID
Generator.availablePlayers = {};

--- How much people have to be picked
-- @tfield int nbPlayersToPick
Generator.nbPlayersToPick  = 0;

-- Creator ID
-- @tfield int creatorID
Generator.creatorID        = 0;

---
-- Resets generator state
--
function Generator.reset()
	Generator.randomPlayers    = {};
	Generator.combinations     = {};
	Generator.nbPlayersToPick  = 0;
	Generator.creatorID        = 0;
end

---
-- Main generating process
-- 
function Generator.generateTeams()
	local success;	
	local teamA;
	local teamB;
	
	Generator.reset();
	success = Generator.getRandomPlayers();
	printDebug("Randoms players [OK]");

	if(success == -1) then
		cancelCurrentMatch("Generation has failed ! Not enough players");
		return;
	end
	
	-- Unnecessary on 1v1 but anyways working 
	Generator.generateCombinations();
	printDebug("Combinations [OK]");
	teamA, teamB = Generator.getBestCombinations();
	printDebug("Best Combinations [OK]");

	if(not teamA or not teamB) then
		cancelCurrentMatch("Generation has failed !");
		return;
	end

	for _, playerID in pairs(teamA.playersID) do
		currentMatch:addPlayerInTeamA(playerID);
	end

	for _, playerID in pairs(teamB.playersID) do
		currentMatch:addPlayerInTeamB(playerID);
	end

	printDebug("Adding players in teams [OK]");

	Generator.reset();
	serverMessage(0, "Team A Elo: "..teamA.elo.." VS Team B Elo:"..teamB.elo);
end

---
-- Gets randoms players id
--
function Generator.getRandomPlayers()
	printDebug("Random Players [START]");
	local randomPlayerID   = 0;

	Generator.nbPlayersToPick  = currentMatch.nbPlayers;
	Generator.creatorID        = getPlayerID(currentMatch.creator);
	
	if (#Generator.availablePlayers < Generator.nbPlayersToPick) then
		return -1;
	end

	--> Inserts creator
	if (Generator.creatorID ~= -1) then
		Generator.randomPlayers[Generator.creatorID] = true;
		Generator.nbPlayersToPick = Generator.nbPlayersToPick - 1;
	end

	--> Not enough players
	if (#player(0, "table") < Generator.nbPlayersToPick) then
		return -1;
	end

	local k = 0;
	while k < Generator.nbPlayersToPick  do
		randomPlayerID = Generator.availablePlayers[math.random(1, 
			#Generator.availablePlayers)];
		printDebug("Random Player ID: "..randomPlayerID);
		--> Not already picked
		if (Generator.randomPlayers[randomPlayerID] == nil and
				player(randomPlayerID, "exists")) then
			Generator.randomPlayers[randomPlayerID] = true;
			k = k + 1;
		end
	end

	Generator.availablePlayers = {};
	printDebug("Random Players [END]");
	return 1;
end

---
-- Generates combinations from randoms players
--
function Generator.generateCombinations()
	for randomID, _ in pairs(Generator.randomPlayers) do
        Generator.formCombinations(randomID, 
        	currentMatch.playersPerTeam - 1, Combination.new());
    end
end	

---
-- Recursive function which forms every combinations cases
--
-- @tparam int playerID the previous player from the tree
-- @tparam int nbOfPlayers how much times thiss function has to repeat
-- @tparam Combination previousCombination previous combination
--
function Generator.formCombinations(playerID, nbOfPlayers, previousCombination)
	local newCombination = Combination.new();

	--> Add previous players ID
	for key, previousID in pairs(previousCombination.playersID) do
		newCombination:addPlayerID(previousID);
	end

	newCombination:addPlayerID(playerID);

	if(nbOfPlayers > 0) then
		for randomID, _ in pairs(Generator.randomPlayers) do
			Generator.formCombinations(randomID, nbOfPlayers - 1,
				newCombination);
		end
	else
		Generator.addCombination(newCombination);
	end
end

---
-- Adds a new combination in the combination array
--
function Generator.addCombination(combination)
	for _, prevCombination in pairs(Generator.combinations) do
		if(prevCombination:hasSamePlayers(combination)) then
			return;
		end
	end
        
	table.insert(Generator.combinations, combination);
end


---
-- Main idea: Iterates over all combinations to find the lowest difference
-- 
-- @treturn Combination first team 
-- @treturn Combination second team 
---
function Generator.getBestCombinations()
    local bestDifference = 10000000;
    local bestCombination1;
    local bestCombination2;
    
    --> Steps through all combinations
    for k, combi1 in pairs(Generator.combinations) do
        for k2, combi2 in pairs(Generator.combinations) do
        	--> Not same teams and not player in both team
            if(k ~= k2 and not combi1:hasPlayerIn(combi2) and
            	combi1:hasDistinctPlayers() and 
            	combi2:hasDistinctPlayers()) then
            	--> Update
    			if(math.abs(combi1.elo - combi2.elo) < bestDifference) then
                    bestCombination1 = combi1;
                    bestCombination2 = combi2;
                    bestDifference = math.abs(combi1.elo - combi2.elo);
                end
            end
        end
    end
    
    return bestCombination1, bestCombination2;
end