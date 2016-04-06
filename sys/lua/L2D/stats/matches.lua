--- Match Result (GUI)
-- @author x[N]ir
-- @release 30/03/16

---
-- Returns the image path associated with the number
--
-- @tparam int number a number
-- @treturn string image path associated with the number
--
function getNumberImagePath(number)
	if (number == 0) then
		return "gfx/L2D/Match/Scores/zero";
	elseif (number == 1) then
		return "gfx/L2D/Match/Scores/one";
	elseif (number == 2) then
		return "gfx/L2D/Match/Scores/two";
	elseif (number == 3) then
		return "gfx/L2D/Match/Scores/three";
	elseif (number == 4) then
		return "gfx/L2D/Match/Scores/four";
	elseif (number == 5) then
		return "gfx/L2D/Match/Scores/five";
	elseif (number == 6) then
		return "gfx/L2D/Match/Scores/six";
	elseif (number == 7) then
		return "gfx/L2D/Match/Scores/seven";
	elseif (number == 8) then
		return "gfx/L2D/Match/Scores/eight";
	elseif (number == 9) then
		return "gfx/L2D/Match/Scores/nine";
	end
end

---
-- Returns the first and second number image path depending on score
--
-- @tparam int score a match final score
-- @tparam string team a team
-- @treturn string the first number image path
-- @treturn string the second number image path
--
function getScoreImagesPath(score, team)
	local firstNumber;
	local secondNumber;

	if (team == "A") then
		firstNumber  = "_a.png";
		secondNumber = "_a.png";
	else
		firstNumber  = "_b.png";
		secondNumber = "_b.png";
	end
	
	if (score < 10) then
		firstNumber  = "gfx/L2D/Match/Scores/zero" .. firstNumber;
		secondNumber = getNumberImagePath(tonumber(string.sub(score, 1, 1))) .. secondNumber;
	else
		firstNumber  = getNumberImagePath(tonumber(string.sub(score, 1, 1))) .. firstNumber;
		secondNumber = getNumberImagePath(tonumber(string.sub(score, 2))) .. secondNumber;
	end

	return firstNumber, secondNumber;
end

---
-- Displays the specified match result
--
-- @tparam int id player ID
-- @tparam table args additional arguments
--
function displayMatchResult(id, args)
	local match                  = matches[args.index];
	local numberOneA, numberTwoA = getScoreImagesPath(match.result.finalTeamA, "A");
	local numberOneB, numberTwoB = getScoreImagesPath(match.result.finalTeamB, "B");
	local p                      = nil;
	local k                      = 2;
	local pColor                 = "";

	setKnife(id);
	removeGUI(id);

	--> HUD
	displayImage(id, "hud_frame", "gfx/L2D/GUI/Frames/big_frame.png", 320, 240, 2, id);

	--> Score
	displayImage(id, "a_first_number", numberOneA, 260, 100, 2, id);
	displayImage(id, "a_second_number", numberTwoA, 280, 100, 2, id);
	displayImage(id, "hbar", "gfx/L2D/Match/Scores/hbar.png", 320, 100, 2, id);
	displayImage(id, "b_first_number", numberOneB, 360, 100, 2, id);
	displayImage(id, "b_second_number", numberTwoB, 380, 100, 2, id);

	--> Texts
	displayText(id, "match_id", 0, "Match #"..match.id, 320, 50, 1, "255255255");
	displayText(id, "match_map", 1, "Map: "..match.map, 320, 130, 1, "218165032");
	displayText(id, "match_creator", 2, "Creator: #"..match.creator, 320, 150, 1, "000255000");

	--> Labels
	displayText(id, "label_nick", 43 , "Nick", 180, 180, 1, "255255255");
	displayText(id, "label_kills", 44 , "Kills", 400, 180, 1, "255255255");
	displayText(id, "label_deaths", 45 , "Deaths", 450, 180, 1, "255255255");
	displayText(id, "label_kpd", 46 , "KPD", 500, 180, 1, "255255255");

	--> Players
	for i = 1, #match.leaderboard do
		p = match.leaderboard[i];

		--> Text Color
		if (p.team == "A") then
			pColor = "255000000";
		else
			pColor = "000078255";
		end

		displayText(id, "nick"..i, 1 + k, p.nick, 180, 180 + i * 20, 1, pColor);
		displayText(id, "kills"..i, 2 + k, p.kills, 400, 180 + i * 20, 1, pColor);
		displayText(id, "deaths"..i, 3 + k, p.deaths, 450, 180 + i * 20, 1, pColor);
		displayText(id, "kpd"..i, 4 + k, p.kpd, 500, 180 + i * 20, 1, pColor);

		k = k + 4;
	end
	
	changeMenu(id, "main", true, false);
end

