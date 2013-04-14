-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local storyboard = require "storyboard"
local physics = require( "physics" )
physics.start()

-- Hide the status bar
display.setStatusBar( display.HiddenStatusBar )

--------------------
-- Spells and Costs
--------------------
_G.fireBallManaCost = 20
_G.iceBoltManaCost = 20

-- Go to the title sequence
storyboard.gotoScene("StaticTitle")