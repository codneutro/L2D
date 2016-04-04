---
-- Menu hooks
-- @author: x[N]ir
-- @release: 31/03/16

---
-- Process numeric keys events
--
-- @tparam int id player id
-- @tparam int action numeric key
--
function hookServerAction(id, action)
	if (action == 1) then -- F2
		removeGUI(id);
		if (pMenus[id]) then
			if (pMenus[id].isOpen) then
				if (pFails[id]) then
					inc(pFails, id);

					if (pFails[id] > MAX_FAILS) then
						pFails[id] = nil;
						pMenus[id]:display(id);
						serverMessage(id, 
							"Next time avoid closing menus with Escape please !");
					else
						errorMessage(id, "Your menu is already opened !");
					end
				else
					pFails[id] = 1;
					errorMessage(id, "Your menu is already opened !");
				end
			else
				pMenus[id]:display(id);
			end
		else
			changeMenu(id, "main", true, true);
		end
	elseif (action == 2) then -- F3 MENU
		if (currentMatch) then
			if (currentMatch:isParticipating(id)) then
				changeMenu(id, "ingame", true, true);
			else
				errorMessage(id, "You can't access this menu at the moment !");
			end
		else
			errorMessage(id, "You can't access this menu at the moment !");
		end
	end
end

---
-- Process user input on menu's buttons
--
-- @tparam int id player id
-- @tparam string title menu's title
-- @tparam int button button's number
--
function hookMenu(id, title, button)
	if (button == 0) then					--/* Close or Zero button */--
		changeMenu(id, "main", true, false);
		pMenus[id].isOpen = false;
	elseif (button == 8) then				--/* Previous button */--
		dec(pMenus[id], "currentPage");
		pMenus[id]:display(id);
	elseif (button == 9) then               --/* Next button */--
		inc(pMenus[id], "currentPage");
		pMenus[id]:display(id);
	else
		local buttonIndex = (pMenus[id].currentPage - 1) * 7 + button
		local menuButton  = pMenus[id].buttons[buttonIndex];

		menuButton:onClick(id);
	end
end
