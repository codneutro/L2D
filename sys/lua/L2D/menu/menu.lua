---
-- Menu management (Menu implementation)
-- @author: x[N]ir
-- @release: 04/04/16

--- Static menus
menus     = {};

--- Players menus
pMenus    = {};

--- Fail counter for players
pFails    = {};

---
-- Changes the menu of the specific player by the newMenu which can be whether <br />
-- a key (which refers to a menus key) in this case static must be set to true, or a menu object.<br />
-- Display parameter is optionnal, set it to true to display the menu immediately
--
-- @tparam int id player ID
-- @param newMenu String / Menu a new menu
-- @tparam[opt] bool static is the new menu a static menu
-- @tparam[opt] bool display should the menu be displayed ?
--
function changeMenu(id, newMenu, static, display)
	if (static) then
		pMenus[id] = menus[newMenu];
	else
		pMenus[id] = newMenu;
	end

	pMenus[id].isOpen = false;

	if(display) then
		pMenus[id]:display(id);
	end
end

---
-- Changes the menu of the specificied player from a button click
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickChangeMenu(id, args)
	changeMenu(id, args.newMenu, args.static, true);
end

---
-- Displays the admin menu to admins...
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function onClickShowAdminMenu(id, args)
	if (tableContains(ADMINS, player(id, "usgn"))) then
		changeMenu(id, "admin", true, true);
	else
		errorMessage(id, "Insufficient permissions");
		changeMenu(id, "main", true, false);
	end
end

---
-- Initialize main menus
--
function initStaticMenus()
	menus["main"]               = Menu.new("Main Menu");
	menus["main"].buttons[1]    = Button.new("Matches", onClickChangeMenu, 
												{static = true, newMenu = "matches"});
	menus["main"].buttons[2]    = Button.new("Stats", displayLeaderBoard);
	menus["main"].buttons[3]    = Button.new("Events", onClickChangeMenu,
												{static = true, newMenu = "main"});
	menus["main"].buttons[4]    = Button.new("Admin", onClickShowAdminMenu);

	menus["matches"]            = Menu.new("Matches Menu");
	menus["matches"].buttons[1] = Button.new("Create", onClickCreateMatch);
	menus["matches"].buttons[2] = Button.new("Last 10 Matches", onClickShowLastMatches);

	menus["maps"]               = Menu.new("Maps Menu");

	for i = 1, #maps do
		menus["maps"].buttons[i] = Button.new(maps[i], 
			onClickSetMatchMap, {map = maps[i]});
	end

	menus["playersPerTeam"]     = Menu.new("Players Per Team");

	for i = 1, 5 do
		menus["playersPerTeam"].buttons[i] = Button.new(i.."v"..i, 
			onClickSetPlayersPerTeam, {players = i});
	end

	menus["matchRounds"] = Menu.new("Match Rounds");
	menus["matchRounds"].buttons[1] = Button.new("8/8", 
					onClickSetMatchRounds, {rounds = 8});
	menus["matchRounds"].buttons[2] = Button.new("10/10", 
					onClickSetMatchRounds, {rounds = 10});
	menus["matchRounds"].buttons[3] = Button.new("12/12", 
					onClickSetMatchRounds, {rounds = 12});
	menus["matchRounds"].buttons[4] = Button.new("15/15", 
					onClickSetMatchRounds, {rounds = 15});
    menus["matchRounds"].buttons[5] = Button.new("2/2", 
					onClickSetMatchRounds, {rounds = 2});

	menus["ingame"] = Menu.new("In-game Menu");
	menus["ingame"].buttons[1] = Button.new("Restart", onClickRestartHalf);
	menus["ingame"].buttons[2] = Button.new("Kick", onClickShowPlayers);
	menus["ingame"].buttons[3] = Button.new("Cancel match", onClickCancelMatch);

	menus["side"] = Menu.new("Choose your side");
	menus["side"].buttons[1] = Button.new("TT", onClickChooseSide, {side = "TT"});
	menus["side"].buttons[2] = Button.new("CT", onClickChooseSide, {side = "CT"});

	menus["sub"] = Menu.new("Do you want to sub ?");
	menus["sub"].buttons[1] = Button.new("YES", onClickSub, {sub = true});
	menus["sub"].buttons[2] = Button.new("NO", onClickSub, {sub = false});

	menus["admin"] = Menu.new("Admin Menu");
	menus["admin"].buttons[1] = Button.new("Reset", onClickResetServer);
end