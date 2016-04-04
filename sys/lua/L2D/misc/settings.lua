---
-- Settings functions
-- @author: x[N]ir
-- @release: 04/04/16

--- Common settings
-- @field table generalSettings
generalSettings = 
{
	["mp_antispeeder"] = 0,
	["mp_autoteambalance"] = 0,
	["mp_idlekick"] = 0,
	["mp_infammo"] = 0,
	["mp_pinglimit"] = 0,
	["mp_postspawn"] = 0,
	["mp_shotweakening"] = 30,
	["sv_password"] = "match",
	["sv_usgnonly"] = 1,
	["stats_rank"] = 0,
	["transfer_speed"] = 250,
	["mp_maxrconfails"] = 5,
	["mp_mapvoteratio"] = 0,
	["mp_maxclientsip"] = 5, --> 2
	["mp_kickpercent"] = 0,
	["mp_smokeblock"] = 1,
	["sv_friendlyfire"] = 0,
	["sv_name"] = "[2DLeague] | Server"
}

--- Match settings base on ICC v7
-- @field table matchSettings
matchSettings = 
{
	["mp_buytime"] = 0.25,
	["mp_freezetime"] = 7,
	["mp_grenaderebuy"] = 0,
	["mp_roundtime"] = 2,
	["mp_startmoney"] = 800,
	["mp_unbuyable"] =
	{
		"Tactical Shield","AWP","Aug","SG552","SG550","G3SG1"
	},
	["sv_fow"] = 1,
	["sv_specmode"] = 2,
};

--- Public settings
-- @field table publicSettings
publicSettings = 
{
	["mp_buytime"] = 4,
	["mp_freezetime"] = 0,
	["mp_grenaderebuy"] = 0,
	["mp_roundtime"] = 2,
	["mp_startmoney"] = 16000,
	["mp_unbuyable"] =
	{
		"Tactical Shield","AWP","Aug","SG552","SG550","G3SG1"
	},
	["sv_fow"] = 0,
	["sv_specmode"] = 1,		
};

--- Knife settings
-- @field table knifeSettings
knifeSettings = 
{
	["mp_buytime"] = 0,
	["mp_freezetime"] = 2,
	["mp_grenaderebuy"] = 0,
	["mp_roundtime"] = 100,
	["mp_startmoney"] = 0,
	["mp_unbuyable"] = 
	{
		"Tactical Shield","AWP","Aug","SG552","SG550","G3SG1",
		"Scout","USP","Glock","Deagle","P228","Elite","Five-Seven","M3","XM1014",
		"MP5","TMP","P90","MAC10","UMP45","AK-47","M4A1","Galil","Famas","M249",
		"HE","Flashbang","Smoke Grenade","Flare", "Kevlar", "Kevlar+Helm", 
		"Night Vision", "Primary Ammo", "Secondary Ammo"
	},
	["sv_fow"] = 1,
	["sv_specmode"] = 2,
}

---
-- Applies the specified settings
--
-- @tparam table tab a settings table
--
function applySettings(tab)
	for command, value in pairs(tab) do
		if(type(value) ~= "table") then
			parse(command..' '..value);
		else
			local cmdString = command..' "'

			for _, args in pairs(value) do
				cmdString = cmdString..args..','
			end

			cmdString = cmdString ..'"'
			parse(cmdString);
		end
	end
end