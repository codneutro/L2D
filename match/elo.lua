---
-- Elo ranking system
--
-- @author x[N]ir
-- @release 04/04/2016
Elo = {};

--- EloPlayers of team A
Elo.teamA   = {};

--- EloPlayers of team B
Elo.teamB   = {};

---
-- Resets the elo ranking system
--
function Elo.reset()
	Elo.teamA   = {};
	Elo.teamB   = {};
end

---
-- Adds the specific player into a team
--
-- @tparam int id a player ID
-- @tparam string team A or B
--
function Elo.addPlayerInTeam(id, team)
	if (team == "A") then
		if (not Elo.teamA[id]) then
			Elo.teamA[id] = EloPlayer.new(players[id].elo);
		end
	else
		if (not Elo.teamB[id]) then
			Elo.teamB[id] = EloPlayer.new(players[id].elo);
		end
	end
end

---
-- Updates players elos 
-- info: https://en.wikipedia.org/wiki/Elo_rating_system
--
-- @tparam number teamAResult (0 => lost / 0.5 => draw / 1 => won)
--
function Elo.updateElos(teamAResult)
	for _, playerA in pairs(Elo.teamA) do
		for __, playerB in pairs(Elo.teamB) do
			playerA:match(playerB, teamAResult);
		end
	end

	for _, playerA in pairs(Elo.teamA) do
		playerA:fixElo();
	end

	for _, playerB in pairs(Elo.teamB) do
		playerB:fixElo();
	end
end
