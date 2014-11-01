-- highscore.lua

---------------------------------------------------------------------
-- Scene untuk menampilkan highscore
---------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local widget = require "widget"
local highScore 
local _W = display.contentWidth
local _H = display.contentHeight

local bestScore
local bestMileage
local bestLevel

-- fungsi yang dieksesuki saat tombol kembali dilepas
local function back()
	composer.gotoScene( "menu", "fade", 500 )
	return true	-- indicates successful touch
end

-- fungsi untuk mengubah tulisan konten highscore
local function setText()
	local dm = require( "utility\\dataManager" )
	local filename = "highscore.json"
	local default = {
		bestscore = 0,
		bestmileage = 0,
		bestlevel = 1,
	}
	
	-- load data dari filename (jika ada). Jika tidak, gunakan default.
	local highscore = dm.loadTable(filename, default)
	
	-- set masing-masing text
	bestScore.text = highscore.bestscore
	bestMileage.text = highscore.bestmileage
	bestLevel.text = highscore.bestlevel
end

-- fungsi yang dipanggil saat scene dibuat
function scene:create( event )
	local sceneGroup = self.view

	highScore = display.newGroup()
	highScore.x = _W/2
	highScore.y = _H/2
	
	local frame = display.newImage(highScore, "assets/image/highscore.png")
	frame:scale(1.1,1.1)
	bestScore = display.newText(highScore, "", 140, -80, native.defaultFontBold, 40 )
	bestMileage = display.newText(highScore, "", 140, 0, native.defaultFontBold, 40 )
	bestLevel = display.newText(highScore, "", 140, 80, native.defaultFontBold, 40 )
	
	backBtn = widget.newButton{
		label="< back",
		labelColor = { default={255}, over={128} },
		width=110, height=50,
		fontSize = 30,
		emboss = true,
		shape = "rect",
		fillColor = { default={ 220/255, 140/255, 48/255, 1 }, over={ 220/255, 140/255, 48/255, 0.7} },
		strokeColor = { default={ 1, 1, 1 }, over={ 1, 1, 1, 0.5} },
		strokeWidth = 5,
		onRelease = back	-- event listener function
	}
	backBtn.x = _W/1.4
	backBtn.y = _H/1.25
	
	sceneGroup:insert( highScore )
	sceneGroup:insert( backBtn )
end

-- fungsi yang dipanggil saat scene ditampilkan
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- update score text
		setText()
		
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		
	end	
end

-- fungsi yang dipanggil saat scene di hide
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

-- fungsi yang dipanggil saat scene di destroy
function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	
	if highScore then
		highScore:removeSelf()	-- widgets must be manually removed
		highScore = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene