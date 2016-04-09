--- Statistics
--	@author x[N]ir
--	@release 09/04/16

--- Delay between updates
-- @tfield int Limit of loaded players
LEADER_BOARD_MAX_PLAYERS  = 100;

--- Array which contains players informations
leaderBoards         = {};

--- Counter for update
-- @tfield int ticks
leaderBoards.ticks   = 0;

--- Array of loaded players
leaderBoards.players = {};

--- Number of pages
-- @tfield int pages
leaderBoards.pages   = 1;

--- 
-- Loads player data in memory
--
-- @tparam string filePath player file path
--
function loadPlayerStats(filePath)
	--> TODO: necessary check ?
	if(File.isFile(filePath)) then
		File.loadFile(filePath);

		local p = Player.new(0);


		for k, v in pairs(p) do
			if (k ~= "nick") then
				p[k] = tonumber(File.getLine());
			else
				p[k] = File.getLine();
			end
		end

		leaderBoards.players[#leaderBoards.players + 1] = {nick = p.nick, 
		wdl = p.wins .. "/" .. p.draws .. "/"..p.looses, elo = p.elo};
	end
end

---
-- Parses users folder and loads player data
--
function collectPlayersData()
	--> Collect files numbers
	local lsCmd = io.popen('ls ' .. USERS_FOLDER)
	local lsOut = lsCmd:read('*a');
	local playersNumbers = {};

	for number in string.gmatch(lsOut, '(%d+)\.dat') do
		playersNumbers[#playersNumbers + 1] = tonumber(number);
	end

	--> Finally loads players.
	local filePath;

	--> Reset
	leaderBoards.players = {};

	for i = 1, LEADER_BOARD_MAX_PLAYERS do
		if(i <= #playersNumbers) then
			filePath = USERS_FOLDER .. playersNumbers[i] .. ".dat";
			loadPlayerStats(filePath);
		else
			break;
		end
	end

	printDebug(#leaderBoards.players .." Players have been loaded !");
end

---
-- Sort player data and update leaderboard status
-- @see collectPlayersData
--
function refreshLeaderBoard()
	local ceil = math.ceil;

	collectPlayersData();
	table.sort(leaderBoards.players, 
		function(a, b) return a.elo > b.elo end);

	leaderBoards.pages = ceil(#leaderBoards.players / 10);
end

---
-- Displays the leaderboard to the specified player
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function displayLeaderBoard(id, args)
	if (not leaderBoards[id]) then
		leaderBoards[id] = {page = 1}; 
	end

	--> Array Fix
	if (leaderBoards[id].page < 1) then leaderBoards[id].page = 1; end
	if (leaderBoards[id].page > leaderBoards.pages) then leaderBoards[id].page = leaderBoards.pages; end

	setKnife(id);
	removeGUI(id);

	--> HUD
	displayImage(id, "hud_frame", "gfx/L2D/GUI/Frames/big_frame2.png", 320, 240, 2, id);

	--> Arrows
	if (leaderBoards[id].page > 1) then
		displayImage(id, "hud_prev_arrow", "gfx/L2D/GUI/Buttons/previous.png", 173, 421, 2, id);
	end

	if (leaderBoards[id].page < leaderBoards.pages) then
		displayImage(id, "hud_next_arrow", "gfx/L2D/GUI/Buttons/next.png", 468, 421, 2, id);
	end

	--> Texts
	displayText(id, "leader_board", 0, "Top "..LEADER_BOARD_MAX_PLAYERS.." (Page "..
		leaderBoards[id].page.." of "..leaderBoards.pages..")", 320, 50, 1, "255255255");
	displayText(id, "label_position", 1, "Position", 100, 100, 1, "212175055");
	displayText(id, "label_nick", 2, "Nick", 200, 100, 1, "255255255");
	displayText(id, "label_wl", 3, "Wins/Draws/Looses", 350, 100, 1, "255165000");
	displayText(id, "label_elo", 4, "Elo", 550, 100, 1, "000078255");

	local index      = 0;  
	local k          = 4;
	local pColor     = "061061061";
	local p          = nil;

	--> All players from the current page
	for i = 1, 10 do
		index = (leaderBoards[id].page - 1) * 10 + i;
		p     = leaderBoards.players[index];

		if (p) then
			--> Crowns
			if (index == 1) then
				displayImage(id, "stat_gold_crown", "gfx/L2D/Stats/gold_crown.png", 50, 125, 2, id);
				pColor = "255215000";
			elseif (index == 2) then
				displayImage(id, "stat_silver_crown", "gfx/L2D/Stats/silver_crown.png", 50, 145, 2, id);
				pColor = "192192192";
			elseif (index == 3) then
				displayImage(id, "stat_bronz_crown", "gfx/L2D/Stats/bronz_crown.png", 50, 165, 2, id);
				pColor = "205127050";
			else
				pColor = "128128128";
			end

			displayText(id, "position"..index, k + 1, "#"..index, 100, 100 + i * 20, 1, pColor);
			displayText(id, "nick"..index, k + 2, p.nick, 200, 100 + i * 20, 1, pColor);
			displayText(id, "wl"..index, k + 3, p.wdl, 350, 100 + i * 20, 1, pColor);
			displayText(id, "elo"..index, k + 4, p.elo, 550, 100 + i * 20, 1, pColor);

			k = k + 4;
		else
			break;
		end
	end

	changeMenu(id, "main", true, false);
end

---
-- Displays the stats informations to the specified player
--
-- @tparam int id player ID
--
function displayStatsInfo(id)
	serverMessage(id, "Nick: " .. player(id, "name"));
	serverMessage(id, "USGN: " .. player(id, "usgn"));

	local userRank = -1;

	for rank, p in pairs(leaderBoards.players) do
		if (p.nick == players[id].nick and 
			p.elo == players[id].elo) then
			userRank = rank;
		end
	end

	if (userRank ~= -1) then
		serverMessage(id, "Rank: " .. userRank);
	else
		serverMessage(id, "Rank: Unknown");
	end

	if (players[id].elo >= 0 and players[id].elo < 1000) then
		serverMessage(id, "Division: Bronz");
	elseif (players[id].elo >= 1000 and players[id].elo < 1800) then
		serverMessage(id, "Division: Silver");
	elseif (players[id].elo >= 1800 and players[id].elo < 2500) then
		serverMessage(id, "Division: Gold");
	elseif (players[id].elo >= 2500 and players[id].elo < 3000) then
		serverMessage(id, "Division: Diamond");
	elseif (players[id].elo >= 3000 and players[id].elo < 3500) then
		serverMessage(id, "Division: Master");
	else
		serverMessage(id, "Division: Legends");
	end

	serverMessage(id, "Elo: " .. players[id].elo);
end