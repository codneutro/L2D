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
	--> Rage-Quit Issue
	if (currentMatch.status == MATCH_SECOND_HALF and 
		reason ~= "Voted by players") then
		currentMatch.status        = MATCH_TERMINATED;

		--> Pick the incomplete team
		local teamACount = currentMatch:teamCount("A");
		local teamBCount = currentMatch:teamCount("B");

		--> Team B RQ
		if (teamACount > teamBCount) then
			currentMatch.result.finalTeamA = currentMatch.matchRounds;
			currentMatch.result.finalTeamB = 0;
		--> Team A RQ
		elseif (teamACount < teamBCount) then
			currentMatch.result.finalTeamB = currentMatch.matchRounds;
			currentMatch.result.finalTeamA = 0;
		--> Both RQ
		else
			currentMatch.result.finalTeamA = 0;
			currentMatch.result.finalTeamB = 0;
		end

		finishCurrentMatch();
	else
		currentMatch.status        = MATCH_CANCELED;
		currentMatch               = nil;
		matchesNumber              = matchesNumber - 1;
		disableMatchSettings();
	end

	Generator.availablePlayers = {};
	enableTeamChange();
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
-- Finishes the current match
--
function finishCurrentMatch()
	currentMatch:finishMatch();
	currentMatch:save();
	currentMatch = nil;
	refreshLeaderBoard();
	saveMatchesData();
	loadMatchesData();
	disableMatchSettings();
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
	timer(1000,"parse",
		'lua "serverMessage(0,\'Waiting for players to join the server !\')"');
	timer(MATCH_WAITING_PLAYER_DELAY * 1000, "prepareMatch");
	disableTeamChange();
	displayMatchInfo();
end

---
-- Changes the server map
--
-- @tparam string map the next map
--
function changeMap(map)
	timer(1000,"parse",'lua "serverMessage(0,\'Changing map for '..map..' in 5 secs !\')"');
	timer(2000,"parse",'lua "serverMessage(0,\'Changing map for '..map..' in 4 secs !\')"');
	timer(3000,"parse",'lua "serverMessage(0,\'Changing map for '..map..' in 3 secs !\')"');
	timer(4000,"parse",'lua "serverMessage(0,\'Changing map for '..map..' in 2 secs !\')"');
	timer(5000,"parse",'lua "serverMessage(0,\'Changing map for '..map..' in 1 secs !\')"');
	timer(6000,"parse","sv_map "..map);
end

---
-- Prepares the upcoming match
--
function prepareMatch()
	if(isMatchPlayable(currentMatch)) then
		applySettings(matchSettings);
		--> Waiting for players opinions
		timer(MATCH_VOTE_DELAY * 1000, "processPlayingVotes");
		allSpec();
		serverMessage(0, "<!on> playing for the next match");
		serverMessage(0, "<!off> not playing for the next match");
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
		enableTeamChange();
		lockTeams();
		announceNewPhase(5, "Match begins !", "phaseKnifeRound");
	end
end

---
-- Removes all match hooks and applies general settings
--
function disableMatchSettings()
	freehook('bombplant', 'hookDisableC4');
	freehook('spawn', 'hookKnifeOnly');
	freehook('startround', 'hookMatchStartRound');
	freehook('kill', "hookMatchKill");
	freehook("startround", "hookMatchStartRound");
	freehook('endround', 'hookMVPEndRound');
	freehook('hit', 'hookMVPHit');	
	addhook("second", "hookUpdateMatches");
	unlockTeams();
	applySettings(publicSettings);
	removeAllServerTexts();
end

---
-- Displays the current match information
--
function displayMatchInfo()
	displayServerText("server_match", 47, "Next Match: "..currentMatch.map.. 
		" "..currentMatch.playersPerTeam.."v"..currentMatch.playersPerTeam,
		5, 215, 0, "255255255");
	displayServerText("server_mr", 48, "MR: "..currentMatch.halfRounds, 
		5, 230, 0, "255255255");
	displayServerText("server_players", 49, "Available Players: "..
		#Generator.availablePlayers, 5, 245, 0, "255255255");
end

---
-- Refresh the current match info
--
function refreshMatchInfo()
	if (serverTexts["server_players"]) then
		displayServerText("server_players", 49, "Available Players: "..
			#Generator.availablePlayers, 5, 245, 0, "255255255");
	end
end