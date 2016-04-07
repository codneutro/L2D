---	
-- Match hooks
-- @author x[N]ir
-- @release 30/03/16

---
-- Calls the saveMatchesQueue function on map change
--
-- @tparam string newmap the name of the new map
--
function hookMapChange(newmap)
	saveMatchesQueue();
	saveMatchesData();
end

---
-- Updates every matches states every second
--
function hookUpdateMatches()
	if(not currentMatch) then
		--> Process an action on different match status
		for key, match in pairs(matchesQueue) do
			--> Remove the match
			if (match.status == MATCH_CANCELED or
				match.timer >= MATCH_REMOVE_DELAY) then
				cancelMatch(match);
				matchesQueue[key] = nil;
				break;
			end

			--> Map changed priority
			if (match.status == MATCH_MAP_CHANGE) then
				startMatch(match);
				matchesQueue[key] = nil;
				break;
			end

			--> Standard matches
			if (match.status == MATCH_WAITING) then
				if(isMatchPlayable(match)) then
					startMatch(match);
					matchesQueue[key] = nil;
					break;
				else
					inc(match, "timer");
				end
			end
		end
	end
end

---
-- Process actions on start round
--
-- @tparam int mode start round mode
--
function hookMatchStartRound(mode)
	if (currentMatch.status == MATCH_KNIFE_ROUND) then
		if ((mode == 1 and currentMatch.order == 0) or
			(mode == 2 and currentMatch.order == 1)) then
			currentMatch:displaySideMenu("B");
			currentMatch.knifeRoundWinner = "B";
		elseif ((mode == 1 and currentMatch.order == 1) or
				(mode == 2 and currentMatch.order == 0)) then 
			currentMatch:displaySideMenu("A");
			currentMatch.knifeRoundWinner = "A";
		end

		if (mode == 1 or mode == 2) then
			freezeAll();
			timer(MATCH_VOTE_DELAY * 1000, "processVote", "side");
		end
	elseif (currentMatch.status == MATCH_FIRST_HALF) then
        if (mode ~= 3 and mode ~= 4 and mode ~= 5) then
        	currentMatch:updateResults();
			inc(currentMatch, "currentRound");
		end
        
		if (currentMatch.currentRound == currentMatch.halfRounds) then
            announceNewPhase(MATCH_TACTICTIME_DELAY,
                "First half is now finished !", "phaseTacticTime");
            
            currentMatch.status = MATCH_PRE_SECOND_HALF;
            swapTeams();
		end
	elseif (currentMatch.status == MATCH_SECOND_HALF) then
        if (mode ~= 3 and mode ~= 4 and mode ~= 5) then
        	currentMatch:updateResults();
			inc(currentMatch, "currentRound");
		end

        if (currentMatch:isFinished()) then
        	currentMatch:finishMatch();
        	currentMatch:save();
        	currentMatch = nil;
        	refreshLeaderBoard();
        	saveMatchesData();
        	loadMatchesData();
        	
        	disableMatchSettings();
        end
	end

	if (currentMatch) then
		restartVotes  = {};
		cancelVotes   = {};
		kickVotes     = {};
		if (currentMatch:mustCancel()) then
			cancelCurrentMatch("Players left");
		end
	end

	--> Reset on restart/game commencing
	if (mode == 4 or mode == 5) then
		for _, playerID in pairs(player(0, "table")) do
			damages[playerID].round = 0;
			damages[playerID].total = 0;
		end
	end
end


---
-- Controls match access
--
-- @tparam int id player ID
-- @tparam int team current player team (0 spec, 1 tt, 2 ct)
-- @tparam int look (0 spec, 1 tt, 2ct)
-- @treturn int access 0 => OK / 1 => DECLINED
--
function hookChangeTeam(id, team, look)
	--> A match is being played
	if (currentMatch) then
		--> A match player
		if (currentMatch.players[id]) then
			--> Going to spec => removed from the match
			if (team == 0) then
				matchLeave(id, 0);
				return 0;
			end	

			return currentMatch:isAllowedToChangeTeam(id, team);
		else
			--> Subs
			local needed, incompleteTeam = currentMatch:isTeamIncomplete();
			local side = currentMatch:getSide(incompleteTeam);

			if (needed and team == side) then
				currentMatch:addPlayerInTeam(id, incompleteTeam);
				return 0;
			else
				serverMessage(id, "You can't join at the moment !");
				return 1;
			end
		end
	end

	return 0;
end

---
-- Disable C4 for knife round
--
-- @tparam int id player ID
-- @tparam int x bomb x (tiles)
-- @tparam int y bomb y (tiles)
-- @treturn int 0 (proceed normally) / 1 don't plant
--
function hookDisableC4(id, x, y)
	errorMessage(id, "You can't plant the bomb !");
	return 1;
end

---
-- Only knife on spawn
--
-- @tparam int id player ID
-- @treturn string weapons
--
function hookKnifeOnly(id)
	return "x";
end

---
-- Updates player kills and deaths
--
-- @tparam int killer player ID
-- @tparam int victim player ID
-- @tparam int weapon weapon type ID
-- @tparam int x death x (pixels)
-- @tparam int y death y (pixels)
--
function hookMatchKill(killer, victim, weapon, x, y)
	if (currentMatch.status == MATCH_FIRST_HALF) then
		inc(currentMatch.players[killer], "firstHalfKills");
		inc(currentMatch.players[victim], "firstHalfDeaths");
	elseif (currentMatch.status == MATCH_SECOND_HALF) then
		inc(currentMatch.players[killer], "secondHalfKills");
		inc(currentMatch.players[victim], "secondHalfDeaths");
	end
end

---
-- Displays MVP + Damages on start round
--
-- @tparam int mode start round mode
--
function hookMVPEndRound(mode)
	if (mode ~= 4 and mode ~= 5) then
		--> Display the mvp of the previous round
		local bestDamages = 0;
		local mvp         = 0;

		--> Sort
		for playerID, dmg in pairs(damages) do
			if (dmg.round >= bestDamages) then
				bestDamages = dmg.round;
				mvp         = playerID;
			end
		end

		serverMessage(0, "[DAMAGE]: "..player(mvp, "name").." is MVP "..
		bestDamages.." HP");
		
		--> Display player damages
		for _, playerID in pairs(player(0, "tableliving")) do
			serverMessage(playerID, "[DAMAGE]: in this round "..
				damages[playerID].round.." HP");
			add(damages[playerID], "total", damages[playerID].round);
			serverMessage(playerID, "[DAMAGE]: in total "..
				damages[playerID].total.." HP");
			damages[playerID].round = 0;
		end
	end
end

---
-- Updates players damages
--
-- @treturn int 0 (default)
--
function hookMVPHit(id, source, weapon, hpdmg, apdmg, rawdmg)
	add(damages[source], "round", hpdmg);
	return 0;
end

---
-- Say commands
--
-- @tparam int id player ID
-- @tparam string message player's message
-- @treturn int 0 (displayed) 1 (not displayed)
--
function hookSay(id, message)
	if (message == "!on") then
		if (not tableContains(Generator.availablePlayers, id)) then
			serverMessage(id, "You've joined the player queue");
			table.insert(Generator.availablePlayers, id);
		else
			serverMessage(id, "You are already in the player queue !");
		end

		return 1;
	elseif (message == "!off") then
		local index = tableIndex(Generator.availablePlayers, id);

		if (index ~= -1) then
			table.remove(Generator.availablePlayers, index);
			serverMessage(id, "You have left the player queue !");
		end
	end
	return 0;
end