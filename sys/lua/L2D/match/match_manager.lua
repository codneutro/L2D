---
-- Match management (Saving / Creating process)
-- @author: x[N]ir
-- @release: 29/03/16

--- All previous matches
matches       = {};

--- Waiting matches
matchesQueue  = {};

--- currentMatch
-- @tfield Match currentMatch
currentMatch  = nil;

--- Total number of played matches since the beginning
-- @tfield int matchesNumber
matchesNumber = 0; 

--- Contains players ID (who has voted for restart)
restartVotes  = {};

--- Contains players ID (who has voted for cancel the match)
cancelVotes   = {};

--- Contains table of players ID layout: {[targetID] = {voterID, ...}, ...}
kickVotes     = {};

--- Layout: {[playerID] = true(TT)/false(CT)}
sideVotes     = {};

---
-- First step for creating a match
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickCreateMatch(id, args)
	if (#matchesQueue >= MATCH_QUEUE_LIMIT or currentMatch) then
		serverMessage(id, "You can't create matches at the moment !");
		changeMenu(id, "main", true, false);
	else
		if(matchesQueue[player(id, "usgn")]) then
			serverMessage(id, "Your old match will be erased !");
		end
		matchesQueue[player(id, "usgn")] = Match.new();
		matchesQueue[player(id, "usgn")].creator = player(id, "usgn");
		changeMenu(id, "playersPerTeam", true, true);
	end
end

---
-- Sets the number of player per team
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickSetPlayersPerTeam(id, args)
	matchesQueue[player(id, "usgn")].playersPerTeam = args.players;
	matchesQueue[player(id, "usgn")].nbPlayers = args.players * 2;
	changeMenu(id, "maps", true, true);
end

---
-- Sets the match's map
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickSetMatchMap(id, args)
	matchesQueue[player(id, "usgn")].map = args.map;
	changeMenu(id, "matchRounds", true, true);
end

---
-- Sets the match's rounds and finalize the creating process
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickSetMatchRounds(id, args)
	matchesQueue[player(id, "usgn")].halfRounds = args.rounds;
	matchesQueue[player(id, "usgn")].matchRounds = args.rounds * 2;

	if (#matchesQueue >= MATCH_QUEUE_LIMIT) then
		serverMessage(id, "Sadly, there are no more places for your match !");
		table.remove(matchesQueue, player(id, "usgn"));
	else
		matchesQueue[player(id, "usgn")].status = MATCH_WAITING;
		matchesQueue[player(id, "usgn")].id     = matchesNumber + 1;
		matchesNumber = matchesNumber + 1;
		serverMessage(id, "Your match have been successfully created !");
	end

	changeMenu(id, "main", true, false);
end

---
-- Displays the lastest matches to a player
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickShowLastMatches(id, args)
	if (#matches ~= 0) then
		local lastMatchesMenu = Menu.new('Last matches');

		for i = 1, #matches do 
			lastMatchesMenu.buttons[i] = Button.new("Match #"..matches[i].id, 
				displayMatchResult, {index = i});
		end

		changeMenu(id, lastMatchesMenu, false, true);
	else
		serverMessage(id, "There are currently no matches available !");
		changeMenu(id, "main", true, false);
	end
end

---
-- Process a player vote for restarting the current half <br>
-- This option is only available for the 2 first rounds !
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickRestartHalf(id, args)
	if (currentMatch) then
		if (currentMatch.currentRound <= 2 and (
			currentMatch.status == MATCH_FIRST_HALF or 
			currentMatch.status == MATCH_SECOND_HALF or 
			currentMatch.status == MATCH_KNIFE_ROUND)) then
				if (restartVotes[id]) then
					errorMessage(id, "You have already voted !");
				else
					restartVotes[id] = 1;
					serverMessage(0, players[id].nick.." has voted for restarting half !");
					processVote("restart");
				end
		else
			errorMessage(id , "You can't vote for restarting the half !"..
				" More than 2 rounds have been already played !");
		end
	end
	changeMenu(id, "main", true, false);
end

---
-- Performs an action depending on player votes
--
-- @tparam string action restart/kick/cancel
-- @tparam table args additionnal arguments
--
function processVote(action, args)
	if (action == "restart") then
		local count = #restartVotes;

		if ((count / currentMatch.nbPlayers) >= MATCH_VOTE_FACTOR) then
			parse("sv_restart 5");
            currentMatch:restartHalf();
			restartVotes = {};
		end
	elseif (action == "cancel") then
		local count = #cancelVotes;

		if ((count / currentMatch.nbPlayers) >= MATCH_VOTE_FACTOR) then
			cancelVotes = {};
			cancelCurrentMatch("Voted by players");
		end
	elseif (action == "kick") then
		local count = #kickVotes[args.target];

		if ((count / currentMatch.nbPlayers) >= MATCH_VOTE_FACTOR) then
			kickVotes[args.target] = nil;
			serverMessage(0, players[args.target].nick.." has been kicked of the match by the community");
			parse('makespec '..args.target);
			currentMatch:removePlayer(args.target);
		end
	elseif (action == "side") then
		local count   = tableCount(sideVotes);
		local swap    = false;

		if ((count / currentMatch.playersPerTeam) >= MATCH_VOTE_FACTOR) then
			local ttCount = tableCountValue(sideVotes, true);
			local ctCount = tableCountValue(sideVotes, false);
			
			if (ttCount > ctCount) then
				if (currentMatch.order == 0) then
					if (currentMatch.knifeRoundWinner == "A") then
						currentMatch.order = 1;
						swap = true;
					end
				else
					if (currentMatch.knifeRoundWinner == "B") then
						currentMatch.order = 0;
						swap = true;
					end
				end
			elseif (ttCount < ctCount) then
				if (currentMatch.order == 0) then
					if (currentMatch.knifeRoundWinner == "B") then
						currentMatch.order = 1;
						swap = true;
					end
				else
					if (currentMatch.knifeRoundWinner == "A") then
						currentMatch.order = 0;
						swap = true;
					end
				end
			end
		end

		if (swap) then
			swapTeams();
		end

		announceNewPhase(5, "TACTIC TIME", "phaseTacticTime");
	end
end

---
-- Show players
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickShowPlayers(id, args)
	if (currentMatch) then
		local m = Menu.new("Vote to kick a player");
		local k = 1;

		for playerID, player in pairs(currentMatch.players) do
			if (playerID ~= id) then
				m.buttons[k] = Button.new(string.gsub(player.nick, "|", ""), 
					onClickVotePlayer, {target = playerID, action = "kick"}); 
				k = k + 1;
			end
		end

		changeMenu(id, m, false, true);
	else
		changeMenu(id, "main", true, false);
	end
end

---
-- Process a vote to kick a specific player
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickVotePlayer(id, args)
	if (currentMatch) then
		if (not kickVotes[args.target]) then
			kickVotes[args.target] = {};
		end

		if (tableContains(kickVotes[args.target], id)) then
			serverMessage(id, "You have already voted !");
		else
			table.insert(kickVotes[args.target], id);
			serverMessage(0, players[id].nick.." wants to kick "..
				players[args.target].nick);
			processVote("kick", args);
		end
	end

	changeMenu(id, "main", true, false);
end

---
-- Process a vote to cancel the match
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickCancelMatch(id, args)
	if (currentMatch) then
		if (cancelVotes[id]) then
			errorMessage(id, "You have already voted !");
		else
			cancelVotes[id] = 1;
			serverMessage(0, player(id, "name").." has voted for canceling the match !");
			processVote("cancel");
		end
	end
	changeMenu(id, "main", true, false);
end

---
-- Process a vote to choose the side
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickChooseSide(id, args)
	if (currentMatch and currentMatch.status == MATCH_KNIFE_ROUND) then
		if (args.side == "TT") then
			sideVotes[id] = true;
			serverMessage(id, "You have voted for terrorists side !");
		else
			sideVotes[id] = false;
			serverMessage(id, "You have voted for counter-terrorists side !");
		end
	end

	changeMenu(id, "main", true, false);
end

---
-- Process action on match leave
--
-- @tparam int id player ID
-- @tparam int reason (0 normal, >0 kick/ban/timeout)
--
function matchLeave(id, reason)
	if (currentMatch:isParticipating(id)) then
		serverMessage(0, player(id, "name").." has left the match !");
		currentMatch.players[id] = nil;

		if (reason == 0) then
			serverMessage(0, player(id, "name").." has lost 100 elo points !");
			add(players[id], "elo", -100);
			if (players[id].elo < 0) then
				players[id].elo = 0;
			end
		end
		
		--> Sub for spec
		for _, playerID in pairs(player(0, "table")) do
			if (player(playerID, "team") == 0) then
				changeMenu(playerID, "sub", true, true);
			end
		end
	end
end

---
-- Process sub action
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickSub(id, args)
	if (currentMatch) then
		local needed, team = currentMatch:isTeamIncomplete();
		if (needed) then
			currentMatch:addPlayerInTeam(id, team);
			serverMessage(id, "You can now join the match !");
		else
			serverMessage(id, "You can't join the match !");
		end
	end

	changeMenu(id, "main", true, false);
end

---
-- Resets all variables
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickResetServer(id, args)
	Generator.reset();
	Elo.reset();
	disableMatchSettings();
	currentMatch = nil;
	Generator.availablePlayers = {};
	matchesQueue = {};
	matches = {};
	refreshLeaderBoard();
    loadMatchesData();
	serverMessage(id, "Server has been reset");
	changeMenu(id, "main", true, false);
end

---
-- Loads the specific match into memory
--
-- @tparam string path match path
--
function loadMatch(path)
	if(File.isFile(path)) then
		File.loadFile(path);

		match = Match.new();

		match.id                   = tonumber(File.getLine());
		match.creator              = tonumber(File.getLine());
		match.map                  = File.getLine();
		match.matchRounds          = tonumber(File.getLine());
		match.result.finalTeamA    = tonumber(File.getLine());
		match.result.finalTeamB    = tonumber(File.getLine());
		match.playersPerTeam       = tonumber(File.getLine());

		local p      = "";
		local line;
		local kills  = 0;
		local deaths = 0;
		local kpd    = 0;
		local mvp    = 0;
		local team   = "";
		local nick   = "";

		for i = 1, match.playersPerTeam * 2 do
			line = File.getLine();
			--> Leavers issue
			if (line ~= nil) then
				p = {};

				kills, deaths, kpd, mvp, team = string.match(line, 
					"(%d+)%s(%d+)%s(%d+%.%d+)%s(%d+)%s(%a)");

				p.kills = tonumber(kills);
				p.deaths = tonumber(deaths);
				p.kpd = tonumber(kpd);
				p.mvp = tonumber(mvp);
				p.team = team;
				
				nick = string.gsub(line, "%s%d+%s%d+%s%d+%.%d+%s%d+%s%a", "");
				nick = string.gsub(nick, "(%d+%s)", "");
				p.nick = nick;

				match.leaderboard[i] = p;
			end
		end

		matches[#matches + 1] = match;
		printDebug("Match #"..match.id.." loaded [OK]");
	end
end

---
-- Save all queue matches into the database
--
function saveMatchesQueue()
	local lines = {};
	local i = 1;
	local queuePath = MATCHS_FOLDER.."queue/queue.dat";

	lines[1] = tableCount(matchesQueue);

	-- Iterate over all waiting matches
	for k, match in pairs(matchesQueue) do
		lines[i + 1] = match.map;
		lines[i + 2] = match.creator;
		lines[i + 3] = match.status;
		lines[i + 4] = match.playersPerTeam;
		lines[i + 5] = match.halfRounds;
		i = i + 5;
	end

	File.writeLines(queuePath, lines);
	printDebug("Saving queue [OK]");
end

---
-- Loads all previous matches on queue
--
function loadMatchesQueue()
	local queuePath = MATCHS_FOLDER.."queue/queue.dat";
	local match;
	local map;
	local status;
	local creator;
	local playersPerTeam;
	local matchRounds;

	File.loadFile(queuePath);
	
	if(#File.buffer ~= 0) then
		local nbMatches = tonumber(File.getLine());

		for i = 1, nbMatches do
			map            = File.getLine();
			creator        = tonumber(File.getLine());
			status         = tonumber(File.getLine());
			playersPerTeam = tonumber(File.getLine());
			halfRounds     = tonumber(File.getLine());

			match          = Match.new(map, halfRounds, playersPerTeam);
			match.status   = status;
			match.creator  = creator;
			matchesQueue[#matchesQueue + 1] = match;
		end

		File.eraseFile(queuePath);
	end

	printDebug("Loading queue [OK]");
end

---
-- Saves new matches and General match states
--
function saveMatchesData()
	--> General data
	local matchFile = MATCHS_FOLDER.."general.dat";
	local lines = {};

	lines[1] = matchesNumber;
	File.writeLines(matchFile, lines);

	--> Individual matches
	for i = 1, #matches do
		matches[i]:save();
	end

	printDebug("Saving general match data [OK]");
end

---
-- Loads previous matches and general match states
--
function loadMatchesData()
	local matchFile = MATCHS_FOLDER.."general.dat";

	File.loadFile(matchFile);

	if (#File.buffer ~= 0) then
		matchesNumber = tonumber(File.getLine());
	end

	-- Collect files numbers
	local lsCmd = io.popen('ls ' .. MATCHS_FOLDER..'old/')
	local lsOut = lsCmd:read('*a');
	local matchesNumbers = {};

	for number in string.gmatch(lsOut, '(%d+)\.dat') do
		matchesNumbers[#matchesNumbers + 1] = tonumber(number);
	end

	-- Sort in descending order
	table.sort(matchesNumbers, function(a,b) return a > b end)

	--> Finally loads matches.
	matches = {};

	local filePath;

	for i = 1, MATCH_LOADED do
		if(i <= #matchesNumbers) then
			filePath = MATCHS_FOLDER..'old/'..matchesNumbers[i]..".dat";
			loadMatch(filePath);
		else
			break;
		end
	end

	printDebug("Loading matches data [OK]");
end