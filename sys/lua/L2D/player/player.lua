--- 
-- Player implementation
--
-- @author x[N]ir
-- @release 04/04/16
--

--- Player array
-- @tfield table players
players = {};

---
-- Saves the specified player into the database
--
-- @tparam int id player ID
--
function savePlayer(id)
	local lines  = {};
	local player = players[id];
	local userFile = USERS_FOLDER..player.usgn..".dat";

	for k, v in pairs(player) do
		lines[#lines + 1] = v;
	end

	File.writeLines(userFile, lines);
	printDebug(player(id, "name").." ["..player(id, "usgn").."] has been saved");
end

---
-- Returns the loaded player
--
-- @tparam int id player ID
-- @treturn Player a player
--
function loadPlayer(id)
	local usgn     = player(id, "usgn");
	local userFile = USERS_FOLDER..usgn..".dat";
	local p        = Player.new(id);
	p.usgn         = usgn;

	if (File.isFile(userFile)) then
		File.loadFile(userFile);

		for k, v in pairs(p) do
			if (k ~= "nick") then
				p[k] = tonumber(File.getLine());
			else
				p[k] = File.getLine();
			end
		end
	end

	printDebug(player(id, "name").." ["..player(id, "usgn").."] has been loaded");
	return p;
end

---
-- Returns a player id from usgn or -1 on error
--
-- @tparam int usgn player USGN
-- @treturn int player's ID associated with the usgn 
--
function getPlayerID(usgn)
	for k, id in pairs(player(0, "table")) do
		if(player(id, "usgn") == usgn) then
			return id;
		end
	end

	return -1;
end