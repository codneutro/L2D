---	
-- Match Implementation
-- @author x[N]ir
-- @release 04/04/16

--- MVP Damages
damages = {};

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
	currentMatch.status        = MATCH_CANCELED;
	currentMatch               = nil;
	matchesNumber              = matchesNumber - 1;
	Generator.availablePlayers = {};
	disableMatchSettings();
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

		--> Waiting for players opinions
		timer(MATCH_VOTE_DELAY * 1000, "processPlayingVotes");

		serverMessage(0, "<!on> playing for the next match");
		serverMessage(0, "<!off> not playing for the next match(es)");
	else
		cancelCurrentMatch("There aren't enough players to play the match, "..
			"this one has been moved to the match queue !");
	end
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

---
-- Removes all match hooks and applies general settings
--
function disableMatchSettings()
	freehook('bombplant', 'hookDisableC4');
	freehook('spawn', 'hookKnifeOnly');
	freehook('team', 'hookChangeTeam');
	freehook('startround', 'hookMatchStartRound');
	freehook('kill', "hookMatchKill");
	freehook("startround", "hookMatchStartRound");
	freehook('endround', 'hookMVPEndRound');
	freehook('hit', 'hookMVPHit');	
	addhook("second", "hookUpdateMatches");
	applySettings(publicSettings);
end