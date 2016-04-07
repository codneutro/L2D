---
-- Team Generator
--
-- @author x[N]ir
-- @release 04/04/16
Generator                  = {};

--- Random players ID
Generator.randomPlayers    = {};

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
	local startTime;
	local elapsed;
	
	Generator.reset();
	success = Generator.getRandomPlayers();
	printDebug("Randoms players [OK]: ");

	if(success == -1) then
		cancelCurrentMatch("Generation has failed ! Not enough players");
		return;
	end
	
	-- Unnecessary on 1v1 but anyways working
	startTime = os.clock();
	teamA, teamB = Generator.getBestTeams();
	printDebug("Best Combinations [OK]: " .. (os.clock() - startTime));

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

	local k    = 0;
	local rand = 0;
	while k < Generator.nbPlayersToPick  do
		rand = math.random(1, #Generator.availablePlayers);
		randomPlayerID = Generator.availablePlayers[rand];
		
		--> Not already picked
		if (Generator.randomPlayers[randomPlayerID] == nil) then
			Generator.randomPlayers[randomPlayerID] = true;
			table.remove(Generator.availablePlayers, rand);
			k = k + 1;
		end
	end

	Generator.availablePlayers = {};
	printDebug("Random Players [END]");
	return 1;
end

---
-- Generates the best teams according to the Hajt Idea
--
-- @treturn tab teamA
-- @treturn tab teamB
-- 
function Generator.getBestTeams()
	local teamA = {elo = 0, playersID = {}};
	local teamB = {elo = 0, playersID = {}};
	local elos = {};

	--> Adding all players elos 
	for randomPlayerID, _ in pairs(Generator.randomPlayers) do
		table.insert(elos, {id = randomPlayerID, 
			elo = players[randomPlayerID].elo});
	end

	--> sorting elos
	table.sort(elos, function(a, b) return a.elo > b.elo end);

	--> adding each elo once to teamA, once to teamB
	for i = 1, #elos do
		if (i % 2 == 0) then
			table.insert(teamA.playersID, elos[i].id)
			add(teamA, "elo", elos[i].elo);
		else
			table.insert(teamB.playersID, elos[i].id);
			add(teamB, "elo", elos[i].elo);
		end
	end

	return teamA, teamB;
end

