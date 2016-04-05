---
-- Misc functions
-- @author: x[N]ir
-- @release: 04/04/16
 
--- Maps names
maps = {};

---
-- Displays the specified message in game
--
-- @tparam string message a message to display
--
function messageDebug(message)
	if (DEBUG_MODE) then
		msg(string.char(169).."255255255[DEBUG]: "..message);
	end
end

---
-- Prints the specified message in the console
--
-- @tparam string message a message to print
--
function printDebug(message)
	if (DEBUG_MODE) then
		print(string.char(169).."000125255[DEBUG]: "..message);
	end
end

---
-- Displays the specified message as server to the specific player
--
-- @tparam int id player ID
-- @tparam string message a message to display
--
function serverMessage(id, message)
	msg2(id, string.char(169).."000255125".."[SERVER]: "..
		string.char(169).."255255255"..message);
end

---
-- Displays the message as error to the specific player
--
-- @tparam int id player ID
-- @tparam string message a message to display
--
function errorMessage(id, message)
	msg2(id, string.char(169).."255000000".."[ERROR]: "..
		string.char(169).."255255255"..message);
end

---
-- Displays the welcome message on player join
--
-- @tparam int id player ID
--
function welcomeMessage(id)
	for line in string.gmatch(WELCOME_MESSAGE,"%c+([^%c]+)") do
		serverMessage(id, line)
	end
end

---
-- Adds to the element stored in the table the specified value
-- 
-- @tparam table tab a table
-- @tparam string key the table key
-- @tparam object value a value 
--
function add(tab, key, value)
	tab[key] = tab[key] + value;
end

---
-- Increments the specified element
-- @tparam table tab a table
-- @tparam string key the table key
--
function inc(tab, key)
	add(tab, key, 1);
end

---
-- Decrements the specified element
-- 
-- @tparam table tab a table
-- @tparam string key the table key
--
function dec(tab, key)
	add(tab, key, -1);
end

---
-- Parse the console output to collect the maps in the server
-- 
-- @tparam string txt console output
--
function grabmaps(txt)
	if (txt ~= "----- Maps -----") then
		maps[#maps + 1] = txt;
	end
end

---
-- Loads the available maps on the server
--
function loadMaps()
	maps = {};
	addhook("log", "grabmaps");
	parse("maps");
	freehook("log", "grabmaps");
end

---
-- Sets knife as main weapon
--
-- @tparam int id player ID
--
function setKnife(id)
	parse("setweapon " .. id .. " 50");
end

---
-- Returns the current date formatted
-- 
-- @treturn string the current date formatted
--
function getCurrentDate()
	local t = os.date('*t', os.time());
	return t.day.."-"..t.month.."-"..t.year;
end

---
-- Returns the current date + exact hour formatted
-- 
-- @treturn string the current date formatted
--
function getCurrentFullDate()
	local t = os.date('*t', os.time());
	return t.day.."-"..t.month.."-"..t.year.." "..t.hour..":"..t.min..":"..t.sec;
end

---
-- Returns the specified number with f decimals place
--
-- @tparam int n a number
-- @tparam int f number of decimals place
-- @treturn string formatted number
--
function tofloat(n, f)
	return string.format("%."..f.."f", tonumber(n));
end

---
-- Returns whether the specified point is inside the rectangle
--
-- @tparam int pX point x coordinate
-- @tparam int pY point y coordinate
-- @tparam int rX rectangle x coordinate
-- @tparam int rY rectangle y coordinate
-- @tparam int rWidth rectangle's width in pixels
-- @tparam int rHeight rectangle's height in pixels
--
function isPointInRect(pX, pY, rX, rY, rWidth, rHeight)
	return (pX >= rX and pX <= rX + rWidth) and
				(pY >= rY and pY <= rY + rHeight);
end

---
-- Returns the number of element in the specified table
--
-- @tparam table tab a table
-- @treturn int the element count in the table
--
function tableCount(tab)
	local count = 0;

	for k, v in pairs(tab) do
		count = count + 1;
	end

	return count;
end

---
-- Returns the number of the specified value in the table
--
-- @tparam table tab a table
-- @tparam object value a value
-- @treturn int the value count in the table
--
function tableCountValue(tab, value)
	local count = 0;

	for k, v in pairs(tab) do
		if (v == value) then
			count = count + 1;
		end
	end

	return count;
end

---
-- Returns whether the element is present in this table
--
-- @tparam table tab a table
-- @tparam object value a value
-- @treturn bool whether the element is present in this table
--
function tableContains(tab, value)
	for k, v in pairs(tab) do
		if(v == value) then
			return true;
		end
	end

	return false;
end

---
-- Returns true if all elements in tab2 are present in tab
--
-- @tparam table tab a base table
-- @tparam table tab2 a testing table
-- @treturn bool whether all elements in tab2 are present in tab
--
function tableContainsAll(tab, tab2)
	for k, v in pairs(tab2) do
		if (not tableContains(tab, v)) then
			return false;
		end
	end

	return true;
end