--- 
-- Menu class
--
-- @classmod Menu
-- @author x[N]ir
-- @release 30/03/16
--
Menu               = {};
Menu.meta          = {__index = Menu};

--- Menu's title
-- @tfield string title
Menu.title         = "Menu";

--- Buttons table
Menu.buttons       = {};

--- Whether or not the menu is currently opened
-- @tfield bool isOpen
Menu.isOpen        = false;

--- Total number of pages
-- @tfield int numberOfPages
Menu.numberOfPages = 1;

--- Current page position
-- @tfield int currentPage
Menu.currentPage   = 1;

---
-- Menu Constructor
--
-- @tparam[opt='Menu'] string title menu's title
-- @tparam[opt={}] table buttons buttons array
-- @treturn Menu a new Menu
-- 
function Menu.new(title, buttons)
	local m   = {};
	setmetatable(m, Menu.meta);

	m.title         = title or "Menu";
	m.buttons       = buttons or {};
	m.isOpen        = false;
	m.numberOfPages = 1;
	m.currentPage   = 1;

	return m;
end

---
-- Updates and fixes internal menu states
--
function Menu:update()
	local ceil = math.ceil;

	-- Update status
	self.numberOfPages = ceil(#self.buttons / 7);

	-- Fixing bounds issue
	if(self.currentPage < 1) then 
		self.currentPage = 1; 
	end

	if(self.currentPage > self.numberOfPages) then
		self.currentPage = self.numberOfPages; 
	end
end

---
-- Displays this menu to the specified player
--
-- @tparam int id player ID
-- 
function Menu:display(id)
	self:update();
	self.isOpen = true;

	--> Preparing menu command
	local menuString = self.title;
	local button     = nil;

	--> Getting 7 buttons from the current page
	for i = self.currentPage * 7 - 6, self.currentPage * 7 do
		button = self.buttons[i];

		if (button) then
			menuString = menuString .. "," .. button.content;
		else
			menuString = menuString .. ",";
		end
	end

	--> Link buttons
	if (self.currentPage > 1) then
		menuString = menuString .. ",Previous,"
	else
		menuString = menuString ..",,"
	end

	if (self.currentPage < self.numberOfPages) then
		menuString = menuString .. "Next"
	end

	menu(id, menuString);
end
