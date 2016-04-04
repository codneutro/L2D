---
-- Elo player
--
-- @classmod EloPlayer 
-- @author: x[N]ir
-- @release: 04/04/16
EloPlayer      = {};
EloPlayer.meta = {__index = EloPlayer};

--- New Elo value
-- @tfield int newElo
EloPlayer.newElo = 0;

--- Elo value to add to the player
-- @tfield int elo
EloPlayer.elo    = 0;

--- Elo change
-- @tfield int eloChange
EloPlayer.eloChange = 0;

--- How much opponents this player has fought against
-- @tfield int opponents
EloPlayer.opponents = 0;

---
-- Creates a new elo player
-- 
-- @tparam int elo player's elo
-- @treturn EloPlayer a new EloPlayer
--
function EloPlayer.new(elo)
	local ep  = {};
	setmetatable(ep, EloPlayer.meta);

	ep.newElo    = 0;
	ep.elo       = elo;
	ep.eloChange = 0;
	ep.opponents = 0;

	return ep;
end

---
-- Returns the K Factor depending on elo value
--
-- @treturn int the k factor
--
function EloPlayer:getK()
	if (self.elo < 1000) then
		return 80;
	elseif (self.elo >= 1000 and self.elo < 2000) then
		return 50;
	elseif (self.elo >= 2000 and self.elo < 2400) then
		return 30;
	elseif (self.elo > 2400) then
		return 20;
	end
end

---
-- Returns the estimation of the player to win against an other player (elo here)
--
-- @treturn number the estimation of the player
--
function EloPlayer:getEstimation(elo)
	return 1 / (1 + math.pow(10, ((elo - self.elo) / 400)));
end

---
-- Process a match against an opponent
--
-- @tparam EloPlayer opponent an opponent
-- @tparam number result (0 => lost / 0.5 => draw / 1 => won)
--
function EloPlayer:match(opponent, result)
	local opponentResult = 0;

	if (result == 0) then
		opponentResult = 1;
	elseif (result == 0.5) then
		opponentResult = 0.5;
	elseif (result == 1) then
		opponentResult = 0;
	end

	self.newElo     = math.floor(self.elo + self:getK() * 
								(result - self:getEstimation(opponent.elo)));
	opponent.newElo = math.floor(opponent.elo + opponent:getK() * 
								(opponentResult - opponent:getEstimation(self.elo)));

	self.eloChange     = self.eloChange + (self.newElo - self.elo);
	opponent.eloChange = opponent.eloChange + (opponent.newElo - opponent.elo);

	self.opponents     = self.opponents + 1;
	opponent.opponents = opponent.opponents + 1;
end

---
-- Fixes the elo of the player
--
function EloPlayer:fixElo()
	--> This value isn't the real elo
	--> It corresponds to the average difference of won points.
	self.elo = math.floor(self.eloChange / self.opponents);
end