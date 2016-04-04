---	
-- Match Phases
-- @author x[N]ir
-- @release 31/03/16

---
-- Announces and calls the next phase of the match
--
-- @tparam int delay delay before the phaseFunction is called
-- @tparam string announceMessage announcement message
-- @tparam string phaseFunction phase function name
--
function announceNewPhase(delay, announceMessage, phaseFunction)
	serverMessage(0, "Next phase: " .. announceMessage);
	timer(delay * 1000, phaseFunction, "");
end

---
-- Knife round
-- 
function phaseKnifeRound()
	serverMessage(0, "[KNIFE] !");
	serverMessage(0, "Remember [F3] for match menu");
	currentMatch.status = MATCH_KNIFE_ROUND;
	applySettings(knifeSettings);

	--> Making ppl in random side for the beginning
	for playerID, player in pairs(currentMatch.players) do
		if (currentMatch.order == 0) then
			if (player.team == "A") then
				parse('makect ' .. playerID);
			else
				parse('maket ' .. playerID);
			end
		else
			if (player.team == "A") then
				parse('maket ' .. playerID);
			else
				parse('makect ' .. playerID);
			end
		end
	end

	addhook('bombplant', 'hookDisableC4');
	addhook('spawn', 'hookKnifeOnly');
	addhook('startround', 'hookMatchStartRound');
end

---
-- Tactic time
--
function phaseTacticTime()
	if (currentMatch.status == MATCH_KNIFE_ROUND) then
		currentMatch.status = MATCH_PRE_FIRST_HALF;
	else
		currentMatch.status = MATCH_PRE_SECOND_HALF;
	end

	unFreezeAll();
	freehook('bombplant', 'hookDisableC4');
	freehook('spawn', 'hookKnifeOnly');

	announceNewPhase(MATCH_TACTICTIME_DELAY, "LIVE", "phaseLive");
end

---
-- Live phase
--
function phaseLive()
	if (currentMatch.status == MATCH_PRE_FIRST_HALF) then
		currentMatch.status = MATCH_FIRST_HALF;
	elseif (currentMatch.status == MATCH_PRE_SECOND_HALF) then
		currentMatch.status = MATCH_SECOND_HALF;
		currentMatch.currentRound = 0;
	end

	applySettings(matchSettings);
    
    --> Reseting players stats
    for playerID, player in pairs(currentMatch.players) do
        player.kills  = 0;
        player.deaths = 0;
        player.mvp    = 0;
    end

	--> adding hooks
    freehook('kill', "hookMatchKill");
	addhook('kill', "hookMatchKill");
	parse("sv_restart 5");
	serverMessage(0, "[G]ood [L]uck and [H]ave [F]un !");
end