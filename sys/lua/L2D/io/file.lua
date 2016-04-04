--- 
-- Used for Input/Ouput operations
--
-- @author x[N]ir
-- @release 04/04/16
File = {};

--- Loaded lines
File.buffer      = {};

---
-- Current buffer index position
-- @tfield int line
File.line        = 0;

--- 
-- Returns whether the path exists or not
--
-- @tparam string path the file path to be tested
-- @treturn bool whether the path exits
--
function File.isFile(path)
	local f = io.open(path, 'r');

	if (f) then
		f:close();
		return true;
	end

	return false;
end

--- 
-- Loads the specified file into memory
--
-- @tparam string path the file path to be tested
--
function File.loadFile(path)
	local f = io.open(path, 'r');

	if (f) then
		File.buffer = {};
		File.line   = 0;

		for line in f:lines() do
			File.buffer[#File.buffer + 1] = line;
		end

		f:close();
	end
end

---
-- Returns the next line from the loaded file or nil on EOF
--
-- @usage 
-- local line;
-- while line ~= nil do
-- 	-- your stuff here
-- 	line = File.getLine()
--
-- @usage
-- local line;
-- for line in File.getLine do
-- 	-- your stuff here
-- end
-- @treturn string the current next line
--
function File.getLine()
	File.line = File.line + 1;
	return File.buffer[File.line];
end

---
-- Writes the lines into the specified file
-- 
-- @tparam string path a file path
-- @tparam table lines to be written
--
function File.writeLines(path, lines)
	local f = io.open(path, 'w')

	if (f) then
		for i = 1, #lines do
			f:write(lines[i]..'\n');
		end

		f:close();
	end
end

---
-- Appends the lines into the specified file
-- 
-- @tparam string path a file path
-- @tparam table lines to be written
--
function File.appendLines(path, lines)
	local f = io.open(path, 'a')

	if (f) then
		for i = 1, #lines do
			f:write(lines[i]..'\n');
		end

		f:close();
	end
end

---
-- Erases the content of the specified file
-- 
-- @tparam string path a file path
--
function File.eraseFile(path)
	local f = io.open(path, 'w');
	if(f) then f:close(); end
end
