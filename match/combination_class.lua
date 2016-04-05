---
-- Combination class used for team generation
-- 
-- @classmod Combination 
-- @author x[N]ir
-- @release 04/04/16
Combination            = {};
Combination.meta       = {__index = Combination};

--- Contains players id
Combination.playersID  = {};

--- Elo value of this combination
-- @tfield int elo
Combination.elo        = 0;

---
-- Constructs a new combination
--
-- @treturn Combination a new combination
--
function Combination.new()
	local c = {};

	setmetatable(c, Combination.meta);
	c.playersID = {};
	c.elo       = 0; 

	return c;
end

---
-- Adds the specified player id into this combination and updates
-- the combination state
--
-- @tparam int id player ID
-- 
function Combination:addPlayerID(id)
	table.insert(self.playersID, id);
	add(self, "elo", players[id].elo);
end

---
-- Returns true if this combination has same players as the specified combination
--
-- @tparam Combination combination an other combination
-- @treturn bool whether this combination has same players
--
function Combination:hasSamePlayers(combination)
	return tableContainsAll(self.playersID, combination.playersID);
end

---
-- Returns true if this combination has at least one player in the specified
-- combination
--
-- @tparam Combination combination an other combination
-- @treturn bool whether these combinations share at least one player
--
function Combination:hasPlayerIn(combination)
	for _, playerID in pairs(self.playersID) do
		for __, combiPlayerID in pairs(combination.playersID) do
			if (playerID == combiPlayerID) then
				return true;
			end
		end
	end

	return false;
end

---
-- Returns true if this combination has distinct players
--
-- @treturn bool whether this combination has distinct players
--
function Combination:hasDistinctPlayers()
	local count = 0;

	for _, playerID in pairs(self.playersID) do
		count = 0;

		for __, pid in pairs(self.playersID) do
			if (playerID == pid) then
				count = count + 1;

				if (count > 1) then
					return false;
				end
			end
		end
	end

	return true;
end