---
-- Button class - Simple representation of a menu's button
--
-- @classmod Button
-- @author x[N]ir
-- @release 04/04/16
Button         = {};
Button.meta    = {__index = Button};

--- Button's text
--  @tfield string content 
Button.content = "Button";

--- Button event on click
--  @tfield function action 
Button.action   = nil;

--- Additional event arguments
Button.args    = {};

--- 
-- Button constructor
--
-- @tparam string content button's text
-- @tparam func action button's event function
-- @tparam table args button's additional arguments
-- @treturn Button a new Button
--
function Button.new(content, action, args)
	local b   = {};
	setmetatable(b, Button.meta);

	b.content = content or "Button";
	b.action  = action;
	b.args    = args or {};

	return b;
end

--- 
-- Performs the action function with it's arguments on the specified player 
--
-- @tparam int id player ID
--
function Button:onClick(id)
	if (self.action) then
		self.action(id, self.args)
	end
end
