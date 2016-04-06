--- 
-- Player hook
--
-- @author x[N]ir
-- @release 04/04/16
--

---
-- Loads the player on join
--
-- @tparam int id player ID
--
function hookJoin(id)
	players[id]        = loadPlayer(id);
	playersImages[id]  = {};
	playersTexts[id]   = {};

	welcomeMessage(id);
end

---
-- Saves the player and free some memory
--
-- @tparam int id player ID
-- @tparam int reason (0 normal, >0 kick/ban/timeout)
--
function hookLeave(id, reason)
	if (currentMatch) then
		matchLeave(id, reason);
	end

	savePlayer(id);
	removeGUI(id);
	
	players[id]       = nil;
	pMenus[id]        = nil;
	pFails[id]        = nil;
	playersImages[id] = nil;
	playersTexts[id]  = nil;
	leaderBoards[id]  = nil;
end

---
-- Updates player's nick
--
-- @tparam int id player ID
-- @tparam string oldname previous player nick
-- @tparam string newname new player nick
-- @tparam int forced 1 when forced by the server
-- @treturn int 0 (default)
function hookName(id, oldname, newname, forced)
	players[id].nick = newname;
	return 0;
end