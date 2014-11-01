-- menu.lua

---------------------------------------------------------------------
-- Scene yang dijalankan untuk menampilkan daftar menu
---------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local am = require("utility.audioManager")
local widget = require "widget"

-- ukuran layar
local _W = display.contentWidth
local _H = display.contentHeight
--------------------------------------------

-- forward declarations and other locals
local bgmSource
local sfxClick

-- fungsi yang dijalankan pada saat playBtn dilepas
local function onPlayBtnRelease()
	audio.stop()
	composer.gotoScene( "play", "fade", 500 )
	--return true	-- indicates successful touch
end

-- fungsi yang dijalankan pada saat tombol highscore dilepas
local function onHighScoreBtnRelease()
	composer.gotoScene( "highscore", "fade", 500 )
	return true	-- indicates successful touch
end

-- fungsi untuk menambahkan button
local function addButton(lbl, onRls, x, y)
	btn = widget.newButton{
		label=lbl,
		labelColor = { default={255}, over={128} },
		width=180, height=50,
		fontSize = 30,
		emboss = true,
		shape = "roundedRect",
		fillColor = { default={ 255/255, 144/255, 0, 0.7 }, over={ 255/255, 144/255, 0, 0.7} },
		strokeColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5} },
		strokeWidth = 5,
		onRelease = onRls	-- event listener function
	}
	btn.x = x
	btn.y = y
	return btn
end

-- fungsi yang dieksekusi pada saat scene dibuat
function scene:create( event )
	local sceneGroup = self.view
	
	-- siapkan audio
	sfxClick = audio.loadSound("assets/audio/pop.mp3")
	bgmSource = audio.loadStream("assets/audio/intro.mp3")
	
	local background = display.newImageRect( "assets\\image\\openingBackground.jpg", display.contentWidth, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = 0, 0

	local splash = display.newImage( "assets/image/splash.png")
	splash.x = _W/2
	splash.y = _H
	splash.anchorY = 0.8
	--splash:scale(0.8,0.8)
	
	local titleLogo = display.newImage( "assets/image/logo.png")
	titleLogo.x = display.contentWidth * 0.5
	titleLogo.y = 100
	
	local playBtn = addButton("Play Now", onPlayBtnRelease, display.contentWidth*0.5, display.contentHeight/2 + 20)
	local highScoreBtn = addButton("High Score", onHighScoreBtnRelease, display.contentWidth*0.5, display.contentHeight/2 + 100)
	
	local sheet = graphics.newImageSheet( "assets\\image\\audio.png", { width=70, height=60, numFrames=2 } )
	local sequenceData ={
		{name="on", start=1},
		{name="off", start=2}
	}
	
	-- tombol audio
	local audioBtn = display.newSprite(sheet, sequenceData)
	if am.getSoundStatus() then
		audioBtn:setSequence("on")
	else
		audioBtn:setSequence("off")
	end
	audioBtn.x = _W - 60
	audioBtn.y = 50
	
	function audioBtn:touch(event)
		if event.phase == "ended" then
			if am.getSoundStatus() then
				audioBtn:setSequence("off")
				am.setSoundStatus(false)
			else
				audioBtn:setSequence("on")
				am.setSoundStatus(true)
				am.playSFX(sfxClick)
			end
		end
	end
	audioBtn:addEventListener("touch", audioBtn)
	
	-- masukkan semua display dalam scene group
	sceneGroup:insert( background )
	sceneGroup:insert( splash )	
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( highScoreBtn )
	sceneGroup:insert( playBtn )
	sceneGroup:insert( audioBtn )
end


-- fungsi yang dijalankan saat scene ditampilkan
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		bgm = am.playBM(bgmSource, {loops = -1})
	elseif phase == "did" then
		-- Called when the scene is now on screen
	end	
end

-- fungsi yang dijalankan pada saat berpindah ke scene lain (tanpa destroy)
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

-- hancurkan scene
function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
	sceneGroup:removeSelf()
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene