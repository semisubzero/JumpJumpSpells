----------------------------------------------------------------------------------
--
-- Game.lua
--
----------------------------------------------------------------------------------

-- Required api's
local storyboard = require( "storyboard" )
local rdm = math.random
local scene = storyboard.newScene()
local sprite = require("sprite")
storyboard.removeScene("Menu")	

-- rectangle based collision
local function hasCollided(obj1, obj2)
    if obj1 == nil then
        return false
    end
    if obj2 == nil then
        return false
    end
    local left = obj1.contentBounds.xMin <= obj2.contentBounds.xMin and obj1.contentBounds.xMax >= obj2.contentBounds.xMin
    local right = obj1.contentBounds.xMin >= obj2.contentBounds.xMin and obj1.contentBounds.xMin <= obj2.contentBounds.xMax
    local up = obj1.contentBounds.yMin <= obj2.contentBounds.yMin and obj1.contentBounds.yMax >= obj2.contentBounds.yMin
    local down = obj1.contentBounds.yMin >= obj2.contentBounds.yMin and obj1.contentBounds.yMin <= obj2.contentBounds.yMax
    return (left or right) and (up or down)
end
-- circle based collision
local function hasCollidedCircle(obj1, obj2)
    if obj1 == nil then
        return false
    end
    if obj2 == nil then
        return false
    end
    local sqrt = math.sqrt
    local dx =  obj1.x - obj2.x;
    local dy =  obj1.y - obj2.y;
    local distance = sqrt(dx*dx + dy*dy);
    local objectSize = (obj2.contentWidth/2) + (obj1.contentWidth/2)
    if distance < objectSize then
        return true
    end
    return false
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
	local group = self.view
	
-----------------
-- Player table
-----------------
	
	Player = {
		spriteSheet = sprite.newSpriteSheet("Sprites/PlayerSprite.png",39,80),
		PlayerSet = sprite.newSpriteSet(spriteSheet,1,8),
		sprite.add(PlayerSet,"running",1,8,600,0),
		sprite.add(PlayerSet,"jumping",3,1,600,1),
		sprite.add(PlayerSet,"casting",9,8,600,1),
		sprite = sprite.newSprite(PlayerSet),
		Casting = false,
		Grounded = false,
		Alive = true,
		Mana = 100
	}
	
--------------------
-- End player table 
--------------------

---------------
-- Game Stats
---------------

	GameStat = {	
		SpellCast = false,
		ScreenMove = true,
		ScrollSpeed = 5,
		Tiles = 30
	}
	
------------------
-- End Game Stats
------------------

-----------------
-- load sound FX
-----------------

	FireballSound = audio.loadSound("Sound FX/Fireball.mp3")
	IceboltSound = audio.loadSound("Sound FX/Icebolt.mp3")
	FreezingSound = audio.loadSound("Sound FX/Frozen Over.mp3")

----------------------
-- end load stound FX
----------------------


--------------------
-- Loading Images
--------------------

	Tiles = {}
	
	for i = 0,allTiles do
		if(i == 15)then
			Tiles[i] = display.newImage("OverlayCaveToGrass.png",display.contentWidth*i,0)
		elseif(i < 15)then
			Tiles[i] = display.newImage("OverlayCave.png",display.contentWidth*i,0) 
		elseif(i == 30)then
			Tiles[i] = display.newImage("OverlayGrassToCave.png",display.contentWidth*i,0)
		elseif(i < 30 and 15 < i)then
			Tiles[i] = display.newImage("OverlayGrass.png",display.contentWidth*i,0)
		end
	end
	

-------------------------
-- Temp hardcoded level
-------------------------
	-- Backgrounds
	Backgrounds = {}
	
	for i = 0,allTiles do
		if(i == 15)then
			Backgrounds[i] = display.newImage("BackgroundCaveToGrass.png",display.contentWidth*i,0)
		elseif(i < 15)then
			Backgrounds[i] = display.newImage("BackgroundCave.png",display.contentWidth*i,0)
		elseif(i == 30)then
			Backgrounds[i] = display.newImage("BackgroundGrassToCave.png",display.contentWidth*i,0)
		elseif(i < 30 and 15 < i)then
			Backgrounds[i] = display.newImage("BackgroundSky.png",display.contentWidth*i,0)
		end
	end
	
	Rock = {}
	Rock[0] = display.newImage("Rocks/Rock0.png",400,190)
	physics.addBody(Rock[0],{density = 1.0,friction = 0.3})
	Rock[1] = display.newImage("Rocks/Rock1.png",400,6000)
	physics.addBody(Rock[1],{density = 1.0,friction = 0.3})
	
	spiderSheet = sprite.newSpriteSheet("Enemies/SpiderSprite.png",200,70)
	spiderSet = sprite.newSpriteSet(spiderSheet,1,9)
	sprite.add(spiderSet,"standing",1,1,100,1)
	sprite.add(spiderSet,"stabbing",1,4,600,1)
	sprite.add(spiderSet,"death",5,4,800,1)
	sprite.add(spiderSet,"frozen",9,1,300,1)
	Spider = {}
	Spider[0] = sprite.newSprite(spiderSet)
	Spider[0].x = 2000
	Spider[0].y = 150
	Spider[0]:prepare("stabbing")
	
	Spider[1] = sprite.newSprite(spiderSet)
	Spider[1].x = 4000
	Spider[1].y = 150
	Spider[1]:prepare("stabbing")
	
-------------------------
-- End hardcoded level
-------------------------
	
	-- Fireball
	fireballSheet = sprite.newSpriteSheet("Spells/FireballSprite.png",75,40)
	fireSet = sprite.newSpriteSet(fireballSheet,1,6)
	sprite.add(fireSet,"flying",1,6,200,1)
	Fireball = sprite.newSprite(fireSet)
	Fireball.x = Player.x
	Fireball.y = Player.y + 10
	Fireball.isVisible = false
	
	-- IceBolt
	iceboltSheet = sprite.newSpriteSheet("Spells/IceballSprite.png",75,40)
	iceSet = sprite.newSpriteSet(iceboltSheet,1,6)
	sprite.add(iceSet,"flying",1,6,200,1)
	Icebolt = sprite.newSprite(iceSet)
	Icebolt.x = Player.x
	Icebolt.y = Player.y + 10
	Icebolt.isVisible = false
	
	-- Mana bar
	manaSheet = sprite.newSpriteSheet("UI/ManaSprite.png",380,11)
	manaSet = sprite.newSpriteSet(manaSheet,1,5)
	sprite.add(manaSet,"moving",1,5,1000,0)
	ManaBar = sprite.newSprite(manaSet)
	ManaBar.x = display.contentWidth/2
	ManaBar.y = 20
	ManaBar.alpha = 0.75
	ManaBar:prepare("moving")
	ManaBar:play()
	
	-- Hidden Floor Object
	Floor = display.newRect(0,225,display.contentWidth,250)
	physics.addBody(Floor,"static",{friction = 0.5})
	Floor.alpha = 0
	-- Buttons
	 -- FireButton
	FireButtonImage = display.newImage("UI/FireButton.png",400,40)
	 -- JumpButton
	JumpButtonImage = display.newImage("UI/JumpButton.png",400,120)
	 -- IceButton
	IceButtonImage = display.newImage("UI/IceButton.png",400,200)
	
-------------------
-- Done Loading
-------------------

-------------------
-- Image Heirarchy
-------------------
	
	for i = 0,allTiles do
		group:insert(Backgrounds[i])
	end

	-- Rocks
	for i = 0,Rocks-1 do
		group:insert(Rock[i])
	end
	group:insert(Player)
	
	for i = 0,allTiles do
		group:insert(Tiles[i])
	end
	
	group:insert(Fireball)
	group:insert(Icebolt)
	for i = 0,allTiles do
		group:insert(Tiles[i])
	end
	group:insert(Spider[0])
	group:insert(Spider[1])
	
	-- Forground
	group:insert(Floor)
	
	-- UI
	group:insert(FireButtonImage)
	group:insert(IceButtonImage)
	group:insert(JumpButtonImage)
	group:insert(ManaBar)

------------------------
-- End Image Heirarchy
------------------------

	-- Button Functions

	-- Fire Button
	local function FireButton()
		if(casting == false and Fireball.isVisible == false and Icebolt.isVisible == false and playerMana >= fireBallManaCost)then
			Player:prepare("casting")
			Player:play()
			casting = true
			Fireball.isVisible = true
			Fireball:prepare("flying")
			Fireball:play()
			spellmoving = true
			playerMana = playerMana - fireBallManaCost
			audio.play(FireballSound)
		end
	end
	FireButtonImage:addEventListener("tap",FireButton)
	
	-- Jump Button
	local function JumpButton()
	
		-- If player is on the ground
		if(Player.y >= 184)then
			-- State he is in the air
			landed = false
			-- Play jumping animation
			Player:prepare("jumping")
			Player:play()
			-- Apply positive vector to y axis
			Player:applyLinearImpulse(0, -18, Player.x, Player.y)
		end
	end
	JumpButtonImage:addEventListener("tap",JumpButton)

	-- Ice Button
	local function IceButton()
		if(casting == false and Fireball.isVisible == false and Icebolt.isVisible == false and playerMana >= iceBoltManaCost)then
			Player:prepare("casting")
			Player:play()
			casting = true
			Icebolt.isVisible = true
			Icebolt:prepare("flying")
			Icebolt:play()
			spellmoving = true
			playerMana = playerMana - iceBoltManaCost
			audio.play(IceboltSound)
		end
	end
	IceButtonImage:addEventListener("tap",IceButton)
	
	-- Updates player/mana
	function UpdatePlayer()
		print(Player.x)
		-- If player lands after jumping
		if(Player.y >= 184 and landed == false)then
			-- Play running animation
			Player:prepare("running")
			Player:play()
			-- Set landed to true
			landed = true
		end
		
		-- Scale the mana based on player mana
		if(playerMana >= 0)then
			ManaBar.xScale = playerMana/100
		end
		-- Make manabar dissapear if <= 0
		if(playerMana <= 0)then
			ManaBar.isVisible = false
		else
			ManaBar.isVisible = true
		end
		
		-- Regenerate Mana
		if(playerMana < 100)then
			playerMana = playerMana + .1
		end
	end
	
	-- Updates spell animations and whatnot
	function UpdateSpells()
		-- If spells are moving
		if(spellmoving == true)then
			-- Move the spells
			if(Fireball.isVisible == true)then
				Fireball.x = Fireball.x + 10
			elseif(Icebolt.isVisible == true)then
				Icebolt.x = Icebolt.x + 10
			end
		end
		-- If it leaves the screen
		if(Fireball.x >= display.contentWidth)then
			spellmoving = false
			casting = false
			Fireball.isVisible = false
		end
		if(Icebolt.x >= display.contentWidth)then
			spellmoving = false
			casting = false
			Icebolt.isVisible = false
		end
		-- If spells are invisible, keep them with the player
		if(Fireball.isVisible == false and Icebolt.isVisible == false)then
			Fireball.x = Player.x
			Fireball.y = Player.y
			Icebolt.x = Player.x
			Icebolt.y = Player.y
		end
		
		for i = 0,Spiders - 1 do
			if(hasCollided(Fireball,Spider[0]) and spiderdead == false)then
				Spider[0]:prepare("death")
				Spider[0]:play()
				Fireball.isVisible = false
				physics.removeBody(Spider[0])
				spiderdead = true
			end
			if(hasCollided(Icebolt,Spider[0]) and spiderdead == false)then
				Spider[0]:prepare("frozen")
				Spider[0]:play()
				Icebolt.isVisible = false
				physics.removeBody(Spider[0])
				spiderdead = true
				audio.play(FreezingSound)
			end
		end
	end
	
	-- Sprite event listener
	function PlayerListener(event)
		-- If the casting animation ends
		if(event.sprite.sequence == "casting" and event.phase == "end")then
			-- Set player to running again
			Player:prepare("running")
			Player:play()
			-- Set casting bool to false
			casting = false
			
		-- If player is running then casting is obviously false
		elseif(event.sprite.sequence == "running")then
			casting = false
		end
	end
	Player:addEventListener("sprite",PlayerListener)
	
	function UpdateWorld()
		Rock[0].x = Rock[0].x - ScrollSpeed
		Rock[1].x = Rock[1].x - ScrollSpeed
		for i = 0,Spiders - 1 do
			Spider[i].x = Spider[i].x - ScrollSpeed
		
			if(Spider[i].x <= display.contentWidth and spidercameonscreen == false)then
				physics.addBody(Spider[i],{density = 0.1, friction = 0.3})
				Spider[i]:prepare("stabbing")
				Spider[i]:play()
				spidercameonscreen = true
			end
		end
	end
end

local function UpdateScenery()	
	
	-- Move forgrounds left
	for i = 0,allTiles do
		Tiles[i].x = Tiles[i].x - ScrollSpeed
	end
	
	-- Move Backgrounds left
	for i = 0,30 do
		Backgrounds[i].x = Backgrounds[i].x - ScrollSpeed
	end
	
end

local function Update(event)
	if(screenmoving == true)then
		UpdateScenery()
		UpdateWorld()
	end
	UpdatePlayer()
	UpdateSpells()
end
Runtime:addEventListener("enterFrame",Update)


local function tapping(event)
	--print("xcoords"..event.x)
	--print("ycoords"..event.y)
end
Runtime:addEventListener("tap",tapping)

-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	
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