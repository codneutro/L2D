---
-- Match class
-- 
-- @classmod Match 
-- @author x[N]ir
-- @release 04/04/16
Match                 = {};
Match.meta            = {__index = Match};

--- Match had a problem
-- @tfield int MATCH_CANCELED
MATCH_CANCELED           = -1;  

--- Match creating process
-- @tfield int MATCH_PREPARING
MATCH_PREPARING          = 0;

--- Server has just changed the map
-- @tfield int MATCH_MAP_CHANGE
MATCH_MAP_CHANGE         = 1;

--- Server is waiting for players to join the match
-- @tfield int MATCH_WAITING
MATCH_WAITING            = 2;

--- Knife round for choosing team side
-- @tfield int MATCH_KNIFE_ROUND
MATCH_KNIFE_ROUND        = 3;

--- Tactic time for the first half
-- @tfield int MATCH_PRE_FIRST_HALF
MATCH_PRE_FIRST_HALF     = 4;

--- First half
-- @tfield int MATCH_FIRST_HALF
MATCH_FIRST_HALF         = 5;

--- Phase during players swaps teams
-- @tfield int MATCH_SWITCHING
MATCH_SWITCHING          = 6;

--- Tactic time for the second half
-- @tfield int MATCH_PRE_SECOND_HALF
MATCH_PRE_SECOND_HALF    = 7;

--- Second half
-- @tfield int MATCH_SECOND_HALF
MATCH_SECOND_HALF        = 8;

--- Match is finished
-- @tfield int MATCH_TERMINATED
MATCH_TERMINATED         = 9;

--- Number of the match
-- @tfield int id
Match.id              = 0;

--- Creator's USGN
-- @tfield int creator
Match.creator         = 0;

--- Map name
-- @tfield string map
Match.map             = "de_dust";

--- Total number of rounds
-- @tfield int matchRounds
Match.matchRounds     = 30;

--- Number of rounds for one side
-- @tfield int halfRounds
Match.halfRounds      = 15;

--- Total number of players
-- @tfield int nbPlayers
Match.nbPlayers       = 10;

--- Number of players per team
-- @tfield int playersPerTeam
Match.playersPerTeam  = 5;

--- Number of the match <br /><br />
-- layout: <br />
-- &nbsp;&nbsp; { [playerID] = {nick = "Player", kills = 0, deaths = 0, firstHalfKills = 0, 
-- firstHalfDeaths = 0, secondHalfKills = 0, secondHalfDeaths = 0, kpd = 0, mvp = 0, team = "A"}} <br>
Match.players         = {};

--- 0: (FH: teamA[CT] vs teamB[TT]) (SH: teamA[TT] vs teamB[CT])<br/>
--- 1: (FH: teamA[TT] vs teamB[CT]) (SH: teamA[CT] vs teamB[TT])
-- @tfield int order
Match.order           = 0;

--- Current round flag
-- @tfield int currentRound
Match.currentRound    = 0;

--- Match status
-- @tfield int status
Match.status          = MATCH_PREPARING;

--- Internal timer used for verifications
-- @tfield int timer
Match.timer           = 0;

--- The team who won the knife round
Match.knifeRoundWinner = "";

--- Result array of the match<br /><br />
--- layout: <br />
-- &nbsp;&nbsp; { teamATT = 0, teamACT= 0, teamBTT = 0, teamBCT = 0, finalTeamA = 0,
-- finalTeamB = 0 }
Match.result          = {};

--- Final player array <br /><br />
-- layout: <br />
-- &nbsp;&nbsp; { [position] = {nick = "Player", kills = 0, deaths = 0, kpd = 0,
--- mvp = 0, team = "A"} }
Match.leaderboard     = {};

---
-- Sets up a new match
-- 
-- @tparam string map Match's map
-- @tparam int halfRounds Number of rounds per side
-- @tparam int playersPerTeam Number of players per team
-- @treturn Match a new match
--
function Match.new(map, halfRounds, playersPerTeam)
	local m       = {};
	setmetatable(m, Match.meta);

	m.id               = 0;
	m.creator          = 0;
	m.map              = map or "de_dust";
	m.halfRounds       = halfRounds or 15;
	m.matchRounds      = m.halfRounds * 2;
	m.playersPerTeam   = playersPerTeam or 5;
	m.nbPlayers        = m.playersPerTeam * 2;
	m.players          = {};
	m.order            = 0;
	m.currentRound     = 0;
	m.status           = MATCH_PREPARING;
	m.timer            = 0;
	m.knifeRoundWinner = "";
	m.result           = {};
	m.leaderboard      = {};

	return m;
end

---
-- Restarts the current half
--
function Match:restartHalf()
	self.currentRound = 0;

	--> Reset players
	if (self.status <= MATCH_FIRST_HALF) then
		for _, p in pairs(self.players) do
			p.firstHalfKills  = 0;
			p.firstHalfDeaths = 0;
		end
	else
		for _, p in pairs(self.players) do
			p.secondHalfKills  = 0;
			p.secondHalfDeaths = 0;
		end
	end

	--> Reset score
	if ((self.status == MATCH_FIRST_HALF and self.order == 0) or
		(self.status == MATCH_SECOND_HALF and self.order == 1)) then
		self.result.teamACT = 0;
		self.result.teamBTT = 0;
	else
		self.result.teamATT = 0;
		self.result.teamBCT = 0;
	end

	printDebug("Restarting Half [OK]");
end

---
-- Returns whether the specified player is allowed to play
--
-- @tparam int id player ID
-- @tparam int team wanted team id
-- @treturn int value used on team hook
--
function Match:isAllowedToChangeTeam(id, team)
	--> Depending on the match order
	if ((self.order == 0 and self.players[id].team == "A" and self.status <= MATCH_FIRST_HALF) or
		(self.order == 0 and self.players[id].team == "B" and self.status > MATCH_FIRST_HALF) or
		(self.order == 1 and self.players[id].team == "A" and self.status > MATCH_FIRST_HALF) or
		(self.order == 1 and self.players[id].team == "B" and self.status <= MATCH_FIRST_HALF)) then

		if (team == 2) then return 0; end

		errorMessage(id, "You can't go to this team at the moment !");
		return 1;
	else 
		if (team == 1) then return 0; end

		errorMessage(id, "You can't go to this team at the moment !");
		return 1;
	end
end

---
-- Returns how much players are in the specified team
--
-- @tparam string team A or B
-- @treturn int how much players are in the specified team
--
function Match:teamCount(team)
	local count = 0;

	for _, player in pairs(self.players) do
		if (player.team == team) then
			count = count + 1;
		end
	end

	return count;
end

---
-- Indicates whether if a team needs player(s)
--
-- @treturn bool true if this team needs player(s)
-- @treturn string the team which needs players
--
function Match:isTeamIncomplete()
	local count  = self:teamCount("A");
	if (count < self.playersPerTeam) then
		return true, "A";
	end

	count = self:teamCount("B");
	if (count < self.playersPerTeam) then
		return true, "B";
	end

	return false;
end

---
-- Sorts players by kpd
--
function Match:sortPlayers()
	local leaderboard = {};

	--> copy players
	local k = 1;
	for _, p in pairs(self.players) do
		--> update kpd
		if (p.deaths == 0) then
			p.kpd = p.kills
		else
			p.kpd = p.kills / p.deaths
		end

		leaderboard[k] = p;
		k = k + 1;
	end

	--> Sorting by kpd in descending order
	local tmp = nil;

	for i = 1, #leaderboard do
		for j = 1, #leaderboard do
			if (leaderboard[i].kpd > leaderboard[j].kpd) then
				tmp = leaderboard[i];
				leaderboard[i] = leaderboard[j];
				leaderboard[j] = tmp;
			end
		end
	end

	self.leaderboard = leaderboard;
end

---
-- Returns true if the match is finished (used for 2nd half)
--
-- @treturn bool whether the match is finished or not
--
function Match:isFinished()
	--> Calculations are based on teamA
	local finished = false;

	if (self.order == 0) then
		if ((self.result.teamATT > self.result.teamBTT) or
				(self.result.teamACT < self.result.teamBCT)) then
			finished = true;
		end
	else
		if ((self.result.teamACT > self.result.teamBCT) or
				(self.result.teamATT < self.result.teamBTT)) then
			finished = true;
		end
	end

	if (self.currentRound == self.halfRounds and
		(self.result.teamATT + self.result.teamACT ==
			self.result.teamBTT + self.result.teamBCT)) then
		finished = true;
	end

	if (finished) then
		self.result.finalTeamA = self.result.teamATT + self.result.teamACT;
		self.result.finalTeamB = self.result.teamBTT + self.result.teamBCT;
	end

	return finished;
end

---
-- Finishes this match
-- 
function Match:finishMatch()
	currentMatch.status = MATCH_TERMINATED;

	serverMessage(0, "Congraluations the match is finished !");

	--> ELO STUFF
	Elo.reset();

	for playerID, player in pairs(self.players) do
		if (player.team == "A") then
			Elo.addPlayerInTeam(playerID, "A");
		else
			Elo.addPlayerInTeam(playerID, "B");
		end
	end


	if (self.result.finalTeamA > self.result.finalTeamB) then
		serverMessage(0, "TEAM A WINS !");

		for playerID, player in pairs(self.players) do
			if (player.team == "A") then
				inc(players[playerID], "wins");
			else
				inc(players[playerID], "looses");
			end
		end

		Elo.updateElos(1);
	elseif (self.result.finalTeamA < self.result.finalTeamB) then
		serverMessage(0, "TEAM B WINS !");

		for playerID, player in pairs(self.players) do
			if (player.team == "A") then
				inc(players[playerID], "looses");
			else
				inc(players[playerID], "wins");
			end
		end

		Elo.updateElos(0);
	else
		serverMessage(0, "DRAW !");

		for playerID, player in pairs(self.players) do
			inc(players[playerID], "draws");
		end

		Elo.updateElos(0.5);
	end

	--> update player state
	for playerID, p in pairs(self.players) do
		p.kills  = p.firstHalfKills  +  p.secondHalfKills;
		p.deaths = p.firstHalfDeaths +  p.secondHalfDeaths;

		if (p.team == "A") then 
			add(players[playerID], "elo", Elo.teamA[playerID].elo);
		else
			add(players[playerID], "elo", Elo.teamB[playerID].elo);
		end

		savePlayer(playerID);
	end
end

---
-- Update team results from the match
-- 
function Match:updateResults()
	if ((self.status == MATCH_FIRST_HALF and self.order == 0) or
		(self.status == MATCH_SECOND_HALF and self.order == 1)) then
		self.result.teamACT = game("score_ct");
		self.result.teamBTT = game("score_t");
	else
		self.result.teamATT = game("score_t");
		self.result.teamBCT = game("score_ct");
	end
end

--- 
-- Adds the player into the specified team
--
-- @tparam int id player ID
-- @tparam string team player's team (A or B)
--
function Match:addPlayerInTeam(id, team)
	if (not self.players[id]) then
		self.players[id] = {nick = players[id].nick, kills = 0, deaths = 0,
			firstHalfKills = 0, firstHalfDeaths = 0, secondHalfKills = 0, 
			secondHalfDeaths = 0, kpd = 0, mvp = 0, ["team"] = team};
	end
end

---
-- Adds the player into the team A
--
-- @tparam int id player ID
--
function Match:addPlayerInTeamA(id)
	self:addPlayerInTeam(id, "A");
end

---
-- Adds the player into the team B
--
-- @tparam int id player ID
--
function Match:addPlayerInTeamB(id)
	self:addPlayerInTeam(id, "B");
end

---
-- Removes the specified player from the players array
--
-- @tparam int id player ID
--
function Match:removePlayer(id)
	for k, v in pairs(self.players) do
		if (k == id) then
			self.players[k] = nil;
			break;
		end
	end
end

---
-- Returns true if the specified player participates to this match
-- 
-- @tparam int id player ID
-- @treturn bool wether the player participates to this match
--
function Match:isParticipating(id)
	return self.players[id] ~= nil;
end

---
-- Returns true if the math has to cancel
--
function Match:mustCancel()
	local teamACount  = self:teamCount("A");
	local teamBCount  = self:teamCount("B");
	local globalCount = teamACount + teamBCount;

	if ((teamACount / self.playersPerTeam) <= MATCH_LEAVE_FACTOR or
		(teamBCount / self.playersPerTeam) <= MATCH_LEAVE_FACTOR or 
		(globalCount / self.nbPlayers) <= MATCH_LEAVE_FACTOR) then
			return true;
	end

	return false;
end

---
-- Displays the side menu for the winner team
--
-- @tparam string team A / B
--
function Match:displaySideMenu(team)
	for playerID, p in pairs(self.players) do
		if (p.team == team) then
			changeMenu(playerID, "side", true, true);
		end
	end
end

---
-- Returns the side of the specified team 
--
-- @tparam string team A or B
-- @treturn int the side of the specified team (1 TT / 2CT)
--
function Match:getSide(team)
	if ((self.order == 0 and team == "A" and self.status <= MATCH_FIRST_HALF) or
		(self.order == 0 and team == "B" and self.status > MATCH_FIRST_HALF) or
		(self.order == 1 and team == "B" and self.status <= MATCH_FIRST_HALF) or
		(self.order == 1 and team == "A" and self.status > MATCH_FIRST_HALF)) then
		return 2;
	else
		return 1;
	end
end


---
-- Saves this match if the match has the MATCH_TERMINATED status
-- @see MATCH_TERMINATED
--
function Match:save()
	local matchFile = MATCHS_FOLDER.."old/"..self.id..".dat";

	if (not File.isFile(matchFile) and 
			self.status == MATCH_TERMINATED) then
		self:sortPlayers();

		local lines  = {};
		local p      = nil;
		local k      = 7;

		lines[1] = self.id;
		lines[2] = self.creator;
		lines[3] = self.map;	
		lines[4] = self.matchRounds;
		lines[5] = self.result.finalTeamA
		lines[6] = self.result.finalTeamB;
		lines[7] = self.playersPerTeam;


		for i = 1, #self.leaderboard do
			p = self.leaderboard[i];
			lines[i + k] = i.." "..p.nick.." "..p.kills.." "..p.deaths..
				" "..tofloat(p.kpd, 2).." "..p.mvp.." "..p.team
		end

		File.writeLines(matchFile, lines);
		printDebug("Saving match #"..self.id.." [OK]");
	end
end
