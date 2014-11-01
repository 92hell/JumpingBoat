-- play.lua

---------------------------------------------------------------------
-- Scene yang dijalankan pada saat game dimainkan
---------------------------------------------------------------------

local composer = require "composer"
local dm = require( "utility\\dataManager" )
local am = require("utility.audioManager")
local data_filename = "highscore.json"
local data = composer.data
local scene = composer.newScene()
local physics
local gx
local gy
local levelutil = require("levelutil")
local gf = require("gamefunctions")
local _W = display.contentWidth
local _H = display.contentHeight
local allFinished = false
local levelOffset = 2000
local level = {}
local player
local grounds
local uiGroup
local numLevel = levelutil.getNumLevel()
local scenery
local foregroundObjects
local bgmSource
local engineSound = audio.loadSound("assets/audio/Engine_Sound.mp3")

-- fungsi untuk menambahkan elemen2 level (obstacles dll)
local function levelAdd(offset)
	if data.level > 1 then
		levelutil.removeLevel(level)
	end
	level = levelutil.addLevel(data.level, offset)
	foregroundObjects:insert(level.floatObs)
	foregroundObjects:insert(level.islands)
	player.maxVelocity = player.maxVelocity*1.1
end

-- fungsi untuk meload data highscore dari database
local function loadData()
	local default = {
		bestscore = 0,
		bestmileage = 0,
		bestlevel = 1,
	}
	
	-- load data dari filename (jika ada). Jika tidak, gunakan default.
	local highscore = dm.loadTable(data_filename, default)
	return highscore
end

-- fungsi yang dieksekusi setiap kali memasuki frame baru
-- pada fungsi ini dilakukan update posisi background dan pemain
local function enter()
	player:moveImage()
	local boatImage = player.boat
	local offset = _W/10
	
	-- update posisi backround berdasarkan posisi pemain
	if (boatImage.x > (display.contentWidth / 10) + offset) then
		local newPos = - (boatImage.x - (display.contentWidth / 10) - offset)
		foregroundObjects.x = newPos
		player.position = newPos
		grounds:reuse(newPos)
		scenery:parallaxMove(newPos)
		
		-- level done
		if newPos * -1 > (levelOffset + level.length) then
			-- prepare next level
			if data.level < numLevel then
				data.level = data.level + 1
				levelOffset = levelOffset + level.length + 3000
				levelAdd(levelOffset)
				
			--  congrats, finish all levels
			elseif not allFinished then
				audio.stop()
				gf.newCongratulationFrame(uiGroup:getScore() ,uiGroup:getCurrentTime())
				allFinished = true
				player.isWinsAll = true
			end
		end
	end
	
	-- lakukan update semua yang perlu di update
	player:updateVelocity()
	gf.float(level.floatObs, gy)
	gf.float(player.floatBody, gy)
	if not allFinished and not player.isSinking then
		uiGroup:update()
	end
end

-- fungsi yang dijalankan untuk membuat scene
function scene:create( event )
	physics = require("physics")
	physics.start()
	physics.pause()
	physics.setGravity( 0, 40 )
	gx, gy = physics.getGravity()
	local sceneGroup = self.view
	player = gf.newPlayer()
	grounds = gf.addGround()
	local utilities = levelutil.addUtility()
	local seaBottoms = grounds[1]
	local liquids = grounds[2]
	scenery = gf.addScenery()
	foregroundObjects = display.newGroup()
	foregroundObjects:insert(utilities)
	foregroundObjects:insert(seaBottoms)
	foregroundObjects:insert(player.boat)
	foregroundObjects:insert(player.floatBody)
	foregroundObjects:insert(liquids)
	uiGroup = gf.newUIElements(player, system.getTimer())
	player.UIControl = uiGroup
	bgmSource = audio.loadStream("assets/audio/pumped.mp3")
	
	levelAdd(levelOffset)
	sceneGroup:insert(scenery)
	sceneGroup:insert(foregroundObjects)
	sceneGroup:insert(uiGroup)
end

-- fungsi yang dijalankan ketika scene akan ditampilkan
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		physics.start()
		am.playBM(bgmSource,{loops = -1})
		audio.play( engineSound, {channel=2, loops = -1,} )
		Runtime:addEventListener( "enterFrame", enter )
	end	
end


-- fungsi yang dipanggil ketika berpindah scene tanpa mendestroy scene ini
function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

-- hancurkan!!!
function scene:destroy( event )
	local sceneGroup = self.view
	Runtime:removeEventListener( "enterFrame", enter )
	physics.stop()

	-- update data highscore sebelum pindah ke menu
	local highscore = loadData()
	local currentScore = uiGroup:getScore()
	local currentMileage = uiGroup:getMileage()
	
	if currentScore > highscore.bestscore then
		highscore.bestscore = currentScore
	end
	if currentMileage > highscore.bestmileage then
		highscore.bestmileage = currentMileage
	end
	if data.level > highscore.bestlevel then
		highscore.bestlevel = data.level
	end
	
	-- save highscore
	dm.saveTable(highscore, data_filename)
	
	-- reset level jadi 1
	data.level = 1
	
	-- hancurkan semua body dan objek!!!
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