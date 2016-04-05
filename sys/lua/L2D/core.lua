--- 
-- Main file of L2D Project
--
-- @script core.lua
-- @author: x[N]ir
-- @release 04/04/16

if L2D then return end
L2D = {};

--- Root folder of L2D Project
-- @tfield string ROOT_FOLDER
ROOT_FOLDER       = "sys/lua/L2D/";

--- Users save folder
-- @tfield string USERS_FOLDER
USERS_FOLDER      = ROOT_FOLDER.."data/players/";

--- Match root folder
-- @tfield string MATCHS_FOLDER
MATCHS_FOLDER     = ROOT_FOLDER.."data/matches/";

-- Includes
dofile(ROOT_FOLDER..'config/constants.lua');
dofile(ROOT_FOLDER..'io/file.lua');
dofile(ROOT_FOLDER..'misc/utils.lua');
dofile(ROOT_FOLDER..'misc/settings.lua');
dofile(ROOT_FOLDER..'ui/gui.lua');
dofile(ROOT_FOLDER..'menu/button_class.lua');
dofile(ROOT_FOLDER..'menu/menu_class.lua');
dofile(ROOT_FOLDER..'menu/menu.lua');
dofile(ROOT_FOLDER..'menu/menu_hook.lua');
dofile(ROOT_FOLDER..'player/player_class.lua');
dofile(ROOT_FOLDER..'player/player.lua');
dofile(ROOT_FOLDER..'player/player_hook.lua');
dofile(ROOT_FOLDER..'match/combination_class.lua');
dofile(ROOT_FOLDER..'match/match_class.lua');
dofile(ROOT_FOLDER..'match/match_manager.lua');
dofile(ROOT_FOLDER..'match/match_utils.lua');
dofile(ROOT_FOLDER..'match/match.lua');
dofile(ROOT_FOLDER..'match/match_phases.lua');
dofile(ROOT_FOLDER..'match/match_hook.lua');
dofile(ROOT_FOLDER..'match/generator.lua');
dofile(ROOT_FOLDER..'match/elo.lua');
dofile(ROOT_FOLDER..'match/elo_player_class.lua');
dofile(ROOT_FOLDER..'stats/leaderboard.lua');
dofile(ROOT_FOLDER..'stats/leaderboard_hook.lua');
dofile(ROOT_FOLDER..'stats/matches.lua');
dofile(ROOT_FOLDER..'stats/matches_hook.lua');

--- 
-- Main entry point <br>
-- Initializes everything and sets up hooks
--
function main()
	loadMaps();
	loadMatchesQueue();
	loadMatchesData();
	initStaticMenus();
	refreshLeaderBoard();
	applySettings(generalSettings);

	addhook("second", "hookUpdateMatches");
	addhook("mapchange", "hookMapChange");
	addhook("serveraction", "hookServerAction");
	addhook("menu", "hookMenu");
	addhook("join", "hookJoin");
	addhook("leave", "hookLeave");
	addhook("name", "hookName");
	addhook("startround", "hookRestartRound");
	addhook("attack", "hookAttack");
	addhook("clientdata", "hookClientData");

	freeMemory();
end

---
-- Free some memory
--
function freeMemory()
	generalSettings = nil;
	L2D             = nil;
	grabmaps        = nil;
	loadMaps        = nil;
end

main();