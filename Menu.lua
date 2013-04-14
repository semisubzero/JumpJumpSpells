----------------------------------------------------------------------------------
--
-- Game.lua
--
----------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local sprite = require("sprite")
storyboard.removeScene("StaticTitle")

----------------------------------------------------------------------------------
-- 
--	NOTE:
--	
--	Code outside of listener functions (below) will only be executed once,
--	unless storyboard.removeScene() is called.
-- 
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	number = 0
	ScaleNumber = 0
	Growing = true
	storyboard.gotoScene("Game")
	MonsterAppearSound = audio.loadSound("Sound FX/MonsterAppears.mp3")
	
	MenuSheet = sprite.newSpriteSheet("MenuSprite.png",106,110)
	MenuSet = sprite.newSpriteSet(MenuSheet,1,10)
	sprite.add(MenuSet,"playing",1,10,2000,0)
	MenuPlay = sprite.newSprite(MenuSet)
	MenuPlay.x = 273
	MenuPlay.y = 170
	
	Background = display.newImage("BackgroundStartCave.png")
	Forground = display.newImage("OverlayCave.png")
	
	group:insert(Background)
	group:insert(MenuPlay)
	Animation = {}
	for i = 0,9 do
		Animation[i] = display.newImage("Start Animation/Start"..i..".png")
		group:insert(Animation[i])
		Animation[i].isVisible = false
	end
	group:insert(Forground)
	
	PlayButton = display.newImage("PlayButton.png",109.5,240)
	PlayButtonPressed = display.newImage("PlayButtonPressed.png")
	PlayButtonPressed.x = PlayButton.x
	PlayButtonPressed.y = PlayButton.y
	
	group:insert(PlayButton)
	group:insert(PlayButtonPressed)
	PlayButtonPressed.isVisible = false
	
	function playbutton(event)
		if(event.phase == "began")then
			PlayButtonPressed.isVisible = true
			PlayButton.isVisible = false
			MenuPlay.isVisible = false
			Animation[0].isVisible = true
			timer.resume(delay)
		elseif(event.phase == "ended")then
			PlayButtonPressed.isVisible = false
		end
	end
	PlayButton:addEventListener("touch",playbutton)
	
	function animationTimer(event)
		number = number + 1
		if(number < 10)then
			Animation[number].isVisible = true
			Animation[number - 1].isVisible = false
			if(number == 8)then
				audio.play(MonsterAppearSound)
			end
		end
		if(number == 10)then
			storyboard.gotoScene("Game")
		end
	end
	delay = timer.performWithDelay(100,animationTimer,10)
	timer.pause(delay)
	
	MenuTitle = display.newImage("TitleName.png")
	group:insert(MenuTitle)
	
	
	MenuPlay:prepare("playing")
	MenuPlay:play()
	
	function titletimer(event)
		if(Growing == true)then
			ScaleNumber = ScaleNumber + 1
			MenuTitle:scale(1.01,1.01)
		else
			ScaleNumber = ScaleNumber - 1
			MenuTitle:scale(0.99,0.99)
		end
		
		if(ScaleNumber >= 6)then
			Growing = false
		elseif(ScaleNumber <= 0)then
			Growing = true
		end
	end
	TitleTimer = timer.performWithDelay(100,titletimer,0)
	
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
	--storyboard.gotoScene("Game")
	-----------------------------------------------------------------------------
		
	--	INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. stop timers, remove listeners, unload sounds, etc.)
	
	-----------------------------------------------------------------------------
	
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view
	
	-----------------------------------------------------------------------------
	
	--	INSERT code here (e.g. remove listeners, widgets, save state, etc.)
	
	-----------------------------------------------------------------------------
	
end


---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )
-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )
-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )
-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )
---------------------------------------------------------------------------------
return scene