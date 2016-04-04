--- 
-- L2D Constants
-- 
-- You can play with values here
--
-- @author: x[N]ir
-- @release 04/04/16

--- Sets it to true to enable debug mode
-- @tfield int DEBUG_MODE
DEBUG_MODE       = true;

--- Your welcome message <br>
--  It MUST have one extra line at the beginning and at the end
-- @tfield string WELCOME_MESSAGE
WELCOME_MESSAGE =
[[

Welcome to the 2DLeague Server !
This mod is developped by x[N]ir !
Current version: dev
Have Fun !
Visit us at cs2d.net !

]]

--- Maximum attempts before open the menu again
-- @param int MENU_MAX_FAILS
MENU_MAX_FAILS = 2;

--- Maximum number of waiting matches in a row
-- @tfield int MATCH_QUEUE_LIMIT
MATCH_QUEUE_LIMIT          = 5;

--- Number of old matches loaded
-- @tfield int MATCH_LOADED
MATCH_LOADED               = 10;

--- Delay before the preparing match is removed from the queue
-- @tfield int MATCH_REMOVE_DELAY
MATCH_REMOVE_DELAY         = 10;

--- How much players vote needed for a performing an action
-- @tfield int MATCH_RESTART_FACTOR
MATCH_VOTE_FACTOR          = 0.7;

--- Player limit for cancel the match
-- @tfield int MATCH_LEAVE_FACTOR
MATCH_LEAVE_FACTOR         = 0.6;

--- Number of seconds to wait for player to join on map change. <br>
-- recommended (15 - 20) / test (2)
-- @tfield int MATCH_WAITING_PLAYER_DELAY
MATCH_WAITING_PLAYER_DELAY = 10;

--- Number of seconds to wait in order to collect available players ids
-- recommended (20) / test (8)
-- @tfield int MATCH_VOTE_DELAY
MATCH_VOTE_DELAY = 5; 

--- Number of seconds of the tactictime phase
-- recommended (15 - 20) / test (5) 
-- @tfield int MATCH_TACTICTIME_DELAY
MATCH_TACTICTIME_DELAY = 10; 