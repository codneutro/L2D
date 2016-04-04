-------------------------------------------------------------------
-- This file is where your Lua server scripts go!                --
-- As an alternative you can also put them into the folder       --
-- sys/lua/autorun                                               --
--                                                               --
-- There are some sample scripts availabe! Just remove the       --
-- comments ("--") in front of the dofile-lines to activate them!--
-- All samples are stored in subtables of the Lua table "sample" --
-- Do not use the "sample" table when writing own scripts!       --
-- Well... unless they are just samples. ;)                      --
--                                                               --
-- You can find&upload additional scripts at UnrealSoftware.de:  --
-- EN: http://www.unrealsoftware.de/files_cat.php?cat=15&lan=2   --
--                                                               --
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --
-- !!!Read sys/lua/info.txt for a CS2D Lua command reference!!!! --
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --
--                                                               --
-- Enjoy! :D                                                     --
-------------------------------------------------------------------

--dofile("sys/lua/samples/advertise.lua")			-- sample.ads [Just a welcome message + Advertising every minute] hooks: join, minute
--dofile("sys/lua/samples/badwords.lua")			-- sample.badwords [A very simple badwords filter. Kicks players who use bad words] hooks: say
--dofile("sys/lua/samples/sayfunctions.lua")		-- sample.sayfuncs [Additional say functions like date, time, idlers etc.] hooks: say
--dofile("sys/lua/samples/utsfx.lua")				-- sample.ut [Adds UT Sounds like Humiliation, Doublekill, Multikill, etc.] hooks: startround, kill
--dofile("sys/lua/samples/console.lua")				-- sample.console [Adds console commands "myserverinfo", "healthlist", "encage", "getentitylist", "getprojectilelist"] hooks: parser
--dofile("sys/lua/samples/regonly.lua")				-- sample.regonly [Only registered players are allowed to join a team] hooks: team
--dofile("sys/lua/samples/classes.lua")				-- sample.classes [Different player classes with different weapons] hooks: team,menu,spawn,buy,walkover,drop,die,serveraction
--dofile("sys/lua/samples/fastplayers.lua")			-- sample.fast [Make all players faster] hooks: spawn
--dofile("sys/lua/samples/gungame.lua")				-- sample.gg [Simple Gun Game Mod] hooks: startround,join,spawn,kill,buy,walkover,drop,die
--dofile("sys/lua/samples/glowingplayers.lua")		-- sample.glowing [Make all players glow using the Lua image commands] hooks: startround
--dofile("sys/lua/samples/undestroyable.lua")		-- sample.undestroyable [Makes all dynamic objects undestroyable] hooks: objectdamage
--dofile("sys/lua/samples/spawnequip.lua")			-- sample.spawnequip [Equip players with items on spawn] hooks: spawn
--dofile("sys/lua/samples/cursors.lua")				-- sample.cursors [Show flares at cursor positions of players] hooks: clientdata, startround
--dofile("sys/lua/samples/tween.lua")				-- sample.tween [Adds an image which follows player 1] hooks: second, startround
--dofile("sys/lua/samples/hudtxt.lua")				-- sample.hudtxt [Adds a custom text to the HUD] hooks: second
--dofile("sys/lua/samples/projectiles.lua")			-- sample.projectiles [Spawn 8 grenades at once when hitting F2 and other stuff with F3/F4] hooks: serveraction
--dofile("sys/lua/samples/hitzone.lua")				-- sample.hitzone [Creates an image with a hitzone] hooks: startround, serveraction, hitzone
--dofile("sys/lua/samples/tilemapper.lua")			-- sample.tilemapper [Edit and inspect tiles] hooks: startround, serveraction, clientdata
dofile("sys/lua/L2D/core.lua");
