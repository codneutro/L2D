--- Leaderboard hooks
--	@author x[N]ir
--	@release 29/03/16

---
-- Requests client mouse position when leaderboard is opened
--
-- @tparam int id player ID
--
function hookAttack(id)
	if (leaderBoards[id]) then
		reqcld(id, 0);
	end
end

---
-- Handles user clicks on GUI menus 
--
-- @tparam int id player ID
-- @tparam int mode kind of data
-- @tparam int data1 mouse abscissa
-- @tparam int data2 mouse ordinate
--
function hookClientData(id, mode, data1, data2)
	if (mode == 0 and leaderBoards[id]) then
		if (isPointInRect(data1, data2, 593, 51, 13,14) or 
			isPointInRect(data1, data2, 227, 413, 90,15) or
			isPointInRect(data1, data2, 325, 413, 90,15)) then
			removeGUI(id);
			leaderBoards[id] = nil;
		end

		if (isPointInRect(data1, data2, 128, 414, 90, 15) and
			leaderBoards[id].page > 1) then
			dec(leaderBoards[id], "page");
			displayLeaderBoard(id);
		end

		if (isPointInRect(data1, data2, 423, 414, 90, 15) and
			leaderBoards[id].page < leaderBoards.pages) then
			inc(leaderBoards[id], "page");
			displayLeaderBoard(id);
		end
	end
end