---	
-- Match Implementation
-- @author x[N]ir
-- @release 04/04/16

--- Number of seconds to wait for player to join on map change. <br>
-- recommended (15 - 20) / test (2)
-- @tfield int MATCH_WAITING_PLAYER_DELAY
MATCH_WAITING_PLAYER_DELAY = 20;

--- Number of seconds to wait in order to collect available players ids
-- recommended (20) / test (8)
-- @tfield int MATCH_VOTE_DELAY
MATCH_VOTE_DELAY = 8; 

--- Number of seconds of the tactictime phase
-- recommended (15 - 20) / test (5) 
-- @tfield int MATCH_TACTICTIME_DELAY
MATCH_TACTICTIME_DELAY = 20; 

---
-- Returns true if there is enough players to start the match
--
-- @tparam Match match a match
-- @treturn bool true if there is enough players to start the match
--
function isMatchPlayable(match)
	return #player(0, "table") >= match.nbPlayers;
end

---
-- Cancels the current Match and displays the specified reason
--
-- @tparam string reason the reason to cancel the match
--		
function cancelCurrentMatch(reason)
	serverMessage(0, "Match canceled, reason => " .. reason);
	addhook("second", "hookUpdateMatches");
	currentMatch.status = MATCH_CANCELED;
	currentMatch = nil;
	freehook('bombplant', 'hookDisableC4');
	freehook('spawn', 'hookKnifeOnly');
	freehook('team', 'hookChangeTeam');
	freehook('startround', 'hookMatchStartRound');
	freehook('kill', "hookMatchKill");
	applySettings(publicSettings);
end

---
-- Cancels a queue match
--
-- @tparam int match a match
--
function cancelMatch(match)
	serverMessage(0, "The "..match.playersPerTeam.."v"..
		match.playersPerTeam.." on "..match.map..
		" has been removed !");
	matchesNumber = matchesNumber - 1;
end

---
-- Starts the most recent prepared match in the queue
--
-- @tparam Match match a match
--
function startMatch(match)
	currentMatch = match;
	freehook("second", "hookUpdateMatches");
	serverMessage(0, "Match is going to start !");

	if (currentMatch.map ~= map("name")) then
		currentMatch.status = MATCH_MAP_CHANGE;

		timer(1000,"parse",'lua "serverMessage(0,\'Changing map for '..currentMatch.map..' in 5 secs !\')"');
		timer(2000,"parse",'lua "serverMessage(0,\'Changing map for '..currentMatch.map..' in 4 secs !\')"');
		timer(3000,"parse",'lua "serverMessage(0,\'Changing map for '..currentMatch.map..' in 3 secs !\')"');
		timer(4000,"parse",'lua "serverMessage(0,\'Changing map for '..currentMatch.map..' in 2 secs !\')"');
		timer(5000,"parse",'lua "serverMessage(0,\'Changing map for '..currentMatch.map..' in 1 secs !\')"');
		timer(6000,"parse","sv_map "..currentMatch.map);
	else
		timer(1000,"parse",'lua "serverMessage(0,\'Waiting for players to join !\')"');
		timer(MATCH_WAITING_PLAYER_DELAY * 1000, "prepareMatch");
	end
end

---
-- Prepares the upcoming match
--
function prepareMatch()
	if(isMatchPlayable(currentMatch)) then
		applySettings(matchSettings);
		allSpec();
		lockTeams();

		menus["play"].title = "Play "..currentMatch.map.." "..
			currentMatch.playersPerTeam.."v"..currentMatch.playersPerTeam..
			" MR "..currentMatch.halfRounds.." ?";

		--> Waiting for players opinions
		timer(MATCH_VOTE_DELAY * 1000, "processPlayingVotes");

		for _, id in pairs(player(0, "table")) do
			changeMenu(id, "play", true, true);
		end
	else
		cancelCurrentMatch("There aren't enough players to play the match, "..
			"this one has been moved to the match queue !");
	end
end

---
-- Adds player id to the available players
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickProcessPlayVote(id, args)
	if (currentMatch ~= nil) then
		if (currentMatch.status == MATCH_WAITING) then
			if (args.play) then
				serverMessage(id, "You are now participating to the draw");
				table.insert(Generator.availablePlayers, id);
			end
		end
	end
	changeMenu(id, "main", true, false);
end

---
-- Performs the following phase of the match depending on players votes
--
function processPlayingVotes()
	serverMessage(0, "Generating teams");
	Generator.generateTeams();

	if (currentMatch ~= nil) then
		currentMatch.order = math.random(0, 1);
		currentMatch.result = {teamATT = 0, teamACT= 0, teamBTT = 0, 
			teamBCT = 0, finalTeamA = 0, finalTeamB = 0};
		announceNewPhase(5, "Match begins !", "phaseKnifeRound");
	end
end