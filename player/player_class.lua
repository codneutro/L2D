--- 
-- Player class
--
-- @classmod Player
-- @author x[N]ir
-- @release 28/03/16
--
Player                = {};
Player.meta           = {__index = Player};

--- USGN number
-- @tfield int usgn
Player.usgn           = 0; 

--- Nickname
-- @tfield string nick
Player.nick           = "Player";

--- Rank in general ladder
-- @tfield int rank
Player.rank           = 0;

--- Elo points
-- @tfield int elo
Player.elo            = 1500;

--- Total number of kills
-- @tfield int totalKills
Player.totalKills     = 0;

--- Total number of deaths
-- @tfield int totalDeaths
Player.totalDeaths    = 0;

--- MVP count
-- @tfield int totalMvp
Player.totalMvp       = 0;

--- Total number of wins
-- @tfield int wins
Player.wins           = 0;
 
--- Total number of looses 
-- @tfield int looses
Player.looses         = 0;
 
--- Total number of draws
-- @tfield int draws
Player.draws          = 0;

--- Total number of played matches
-- @tfield int matchesPlayed
Player.matchesPlayed  = 0;

--- Temp variable for matches (kills)
-- @tfield int kills
Player.kills          = 0;

--- Temp variable for matches (deaths)
-- @tfield int deaths
Player.deaths         = 0;

--- Temp variable for matches (kpd)
-- @tfield number kpd
Player.kpd            = 0;

--- Temp variable for matches (mvp)
-- @tfield int mvp
Player.mvp            = 0;

--- 
-- Constructs a new player
--
-- @tparam int id player's ID
-- @treturn Player a new player
--
function Player.new(id)
	local p = {};
	setmetatable(p, Player.meta);

	p.usgn        = player(id, "usgn");
	p.nick        = player(id, "name");
	p.rank        = 0;
	p.elo         = 1500;
	p.totalKills  = 0; 
	p.totalDeaths = 0;
	p.totalMVP    = 0;
	p.wins        = 0;
	p.looses      = 0;
	p.draws       = 0;
	p.mixsPlayed  = 0;
	p.kills       = 0;
	p.deaths      = 0;
	p.kpd         = 0;
	p.mvp         = 0;

	return p;
end




