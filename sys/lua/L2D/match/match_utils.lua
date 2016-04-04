---
-- Match utilitaries functions
-- @author: x[N]ir
-- @release: 31/03/16

---
-- Makes everybody spec
--
function allSpec()
	for key, playerID in pairs(player(0, "table")) do
		parse("makespec " .. playerID);
	end
end

---
-- Limits access to mix players
-- 
function lockTeams()
	serverMessage(0, 'Team access has been restricted to match players');
	addhook('team', 'hookChangeTeam');
end

---
-- Removes limits access to mix players
-- 
function unlockTeams()
	serverMessage(0, 'Team access is now open to everybody');
	freehook('team', 'hookChangeTeam');
end

---
-- Freeze all players
--
function freezeAll()
	for _, playerID in pairs(player(0, "table")) do
		parse('speedmod '..playerID..' -100');
	end
end

---
-- UnFreeze all players
--
function unFreezeAll()
	for _, playerID in pairs(player(0, "table")) do
		parse('speedmod '..playerID..' 0');
	end
end

---
-- Swaps players
--
function swapTeams()
	for _, playerID in pairs(player(0, "tableliving")) do
		if (player(playerID, "team") == 1) then
			parse("makect "..playerID);
		else
			parse("maket "..playerID);
		end
	end
end
