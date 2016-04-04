--- 
-- GUI Functions: <br />
-- Displaying image and texts
-- @author x[N]ir
-- @release 04/04/16

--- Contains players image ids
playersImages = {};

--- Contains players texts ids
playersTexts  = {};

---
-- Displays the specified image if the player isn't seeing it already
--
-- @tparam int id player ID
-- @tparam string key image's key
-- @tparam string imagePath full image path
-- @tparam int x image's abscissa in pixels
-- @tparam int y image's ordinate in pixels
-- @tparam int mode image's mode
-- @tparam[opt] int pl player ID
--
function displayImage(id, key, imagePath, x, y, mode, pl)
	if (not playersImages[id][key]) then
		playersImages[id][key] = image(imagePath, x, y, mode, pl);
	end
end	

---
-- Removes the specified image from a player
--
-- @tparam int id player ID
-- @tparam string key image's key
--
function removeImage(id, key)
	if (playersImages[id][key]) then
		freeimage(playersImages[id][key]);
		playersImages[id][key] = nil;
	end
end


---
-- Removes all images from player
--
-- @tparam int id player ID
--
function removeAllImages(id)
	if(playersImages[id]) then
		for key, imageID in pairs(playersImages[id]) do 
			freeimage(imageID);
			playersImages[id][key] = nil;
		end
	end
end

---
-- Displays the specified text on player screen
--
-- @tparam int playerId player ID
-- @tparam string key text's key
-- @tparam int textId the text id
-- @tparam string text a text to display
-- @tparam int x text's abscissa 
-- @tparam int y text's ordinate
-- @tparam[opt=0] int align alignment
-- @tparam[opt] string color text's color
--
function displayText(playerId, key, textId, text, x, y, align, color)
	if (color) then
		text = string.char(169)..color..text;
	end

	if (not align) then
		align = 0;
	end

	parse('hudtxt2 ' .. playerId .. ' ' .. textId .. ' "' .. text .. '" ' .. 
		x .. ' ' .. y .. ' ' .. align);

	playersTexts[playerId][key] = textId;
end

---
-- Removes the specified text from a player
--
-- @tparam int id player ID
-- @tparam string key text's key
--
function removeText(id, key)
	if (playersTexts[id][key]) then
		parse('hudtxt2 ' .. id .. ' ' .. playersTexts[id][key]);
		playersTexts[id][key] = nil;
	end
end

---
-- Removes all texts from the specified player
--
-- @tparam int id player ID
--
function removeAllTexts(id)
	if (playersTexts[id]) then
		for key, textID in pairs(playersTexts[id]) do
			parse('hudtxt2 ' .. id .. ' ' .. textID);
			playersTexts[id][key] = nil;
		end
	end
end

---
-- Removes every graphical interface on player screen
--
-- @tparam int id player ID
--
function removeGUI(id)
	removeAllImages(id);
	removeAllTexts(id);
end