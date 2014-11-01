-- gamefunctions.lua

---------------------------------------------------------------------
-- Modul yang berisi common functions yang ada dalam game
---------------------------------------------------------------------

-- table untuk menyimpan local function, akan dipass ketika library ini di-load
local gamefunctions = {}

-- menyimpan ukuran layar
local _W = display.contentWidth
local _H = display.contentHeight

-- library physics untuk dimanfaatkan pada charater, point, ground dan obstacle
-- library physics akan memberikan simulasi kinematika pada game
local physics = require "physics"
local composer = require "composer"

-- data diinisialisasi pada main.lua
-- berisi data level
local data = composer.data

local boatcrash = audio.loadStream( "assets/audio/Game_Over.wav")
local jumpSound = audio.loadSound( "assets/audio/Jumping.wav")
local diveSound = audio.loadSound("assets/audio/Boat_Submerged.mp3")
local engineSound = audio.loadSound("assets/audio/Engine_Sound.mp3")

local liquidYPos
local liquidHeight
local newSinkingFrame

-- fungsi yang mendeteksi collision antara player dan obstacle
-- hanya untuk diassign sebagai collision listener pada player
local function playerObjectCollision(self, event)
	-- slef adalah objek player
	if event.phase == "began" then
		-- player bertabrakan dengan obstacles
		if event.other.isObstacle then
			self.isJumping = false
			self.health = self.health - event.other.damage
			self.UIControl:updatePlayerHealth()
			
			-- boat tenggelam
			if self.health <= 0 and not self.isSinking then
				self:die()
				self.velocity = 0 
				self.isSinking = true
				newSinkingFrame(self.UIControl:getScore(), self.UIControl:getCurrentTime(), self.UIControl:getDistance())
				audio.stop()
				audio.play( boatcrash, {loops = -0,} )
				
			-- kurangi kecepatan boat jika tabrakan (mengenai obstacles)
			else
				self.velocity = self.minVelocity
				self.isCrashing = true
			end
		
		-- player berkolisi dengan utilitas 'menyelam'
		elseif event.other.name == "diveutil" then
			event.other:removeSelf()
			self.UIControl:addDiveButton()
			self.boat:setSequence("closing")
			self.boat:play()
		end
		
	elseif event.phase == "ended" then
		if event.other.isObstacle then
			self.isCrashing = false
		end
	end
end 

-- fungsi yang membuat DisplayObject player baru beserta atribut2nya
local function newPlayer ()
	local floatBody = display.newGroup()
	
	-- display bagian gambar boat
	local sheet = graphics.newImageSheet( "assets\\image\\boats.png", { width=210, height=79, numFrames=8 } )
	local sequenceData ={
		{name="cruising", start=1},
		{name="closing", start=2, count=6, time=1000, loopCount=1},
		{name="closedhood", start=7, count=1}
	}
	local boat = display.newSprite(sheet, sequenceData)
	boat:setSequence("cruisng")
	boat:play()
	boat.x = display.contentWidth / 10
	boat.anchorY = 0.75
	
	-- display bagian boat body
	local frontShape = {-25,-15,25,-10,-10,15,-25,15}
	local rearShape = {5,-15,25,-15,25,15,-25,15,-25,0,-5,0}
	local roofShape = {-30,10,16,-8,44,10}
	local front = display.newPolygon(floatBody, 215, 120, frontShape)
	local roof = display.newPolygon(floatBody, 142, 94, roofShape)
	local mid = display.newRect(floatBody, 140, 120, 100, 30)
	local rear = display.newPolygon(floatBody, 65, 120, rearShape)
	
	front.alpha = 0.6
	rear.alpha = 0.6
	mid.alpha = 0.6
	roof.alpha = 0.6
	
	front:setFillColor( 255,0,50)
	rear:setFillColor( 0,255,50 )
	roof:setFillColor( 255,50,0 )
	
	-- *** comment/delete bagian ini untuk melihat boat's bodies *** --
	front.isVisible = false
	rear.isVisible = false
	mid.isVisible = false
	roof.isVisible = false
	-------------------------------------------------------------------
	
	-- tambahkan body pada simulasi fisis
	physics.addBody( front, { density=0.65, friction=0.1, shape = frontShape} )
	physics.addBody( rear, { density=0.6, friction=0, shape = rearShape} )
	physics.addBody( mid, { density=0.6, friction=0} )
	physics.addBody( roof, { density=0.2, friction=0, shape = roofShape} )
	physics.addBody( boat, { density=0.1, friction=0, isSensor = true} )
	
	-- penggabungan boat's body
	physics.newJoint("weld",rear,mid,0,0)
	physics.newJoint("weld",mid,front,0,0)
	physics.newJoint("weld",mid,roof,0,0)
	
	-- hitung luasan masing-masing boat's body
	for i=1, floatBody.numChildren do
		local obj = floatBody[i]
		obj.area = obj.height * obj.width
	end

	--print(front.area)
	--print(mid.area)
	--print(rear.area)
	
	-- objek player
	local player = {}
	player.isJumping = false
	player.floatBody = floatBody
	player.boat = boat
	player.front = front
	player.maxVelocity = 700
	player.minVelocity = 400
	player.velocity = 400
	player.health = 100
	player.position = 0
	player.isCrashing = false
	player.isSinking = false
	player.isWinsAll = false
	player.collision = playerObjectCollision
	player.UIControl = {} --ui control, untuk memperbarui health UI pada saat playing
	
	-- tambahkan listener pada gambar boat, yang akan mendeteksi
	-- collision dengan benda2 lain
	boat:addEventListener("collision", player)
	
	-- event handler yang dieksekusi saat player diperintahkan untuk meloncat
	function player:jump (touchTime)
		if mid.isInWater and not player.isSinking and not player.isWinsAll then
			audio.play( engineSound, {loops = -1,} )
			local addImpulse = touchTime / 20
			if addImpulse > 30 then
				addImpulse = 30
			end
			
			addImpulse = addImpulse/1.3
			-- aplikasikan impulse pada setiap boat's body
			front:applyLinearImpulse(0, -35 - addImpulse, front.x, front.y)
			mid:applyLinearImpulse(0, -30 - addImpulse, mid.x, mid.y)
			rear:applyLinearImpulse(0, -25 - addImpulse, rear.x, rear.x)
		end
	end
	
	-- silahkan aplikasikan fungsi dive disini
	function player:dive ()
		if not player.isSinking and not player.isWinsAll then
			local addImpulse = 20	
			-- aplikasikan impulse pada setiap boat's body
			front:applyLinearImpulse(0, addImpulse, front.x, front.y)
			mid:applyLinearImpulse(0, addImpulse, mid.x, mid.y)
			rear:applyLinearImpulse(0, addImpulse, rear.x, rear.x)
			audio.play( diveSound, {loops = 0,} )
		end
	end
	
	-- boat tenggelam, area body diperkecil agar setiap body tenggelam
	-- velocity diset 0
	function player:die ()
		player.velocity = 0
		player.maxVelocity = 0
		front.area = 150
		mid.area = 700
		rear.area = 500
	end
	
	-- fungsi agar sprite gambar boat mengikuti body rear
	function player:moveImage()	
		boat.x = (front.x+rear.x)/2 - 1
		boat.y = (front.y+rear.y)/2 
		boat.rotation = front.rotation
	end
	
	-- perbarui kecepatan boat
	function player:updateVelocity()
		if not player.isSinking then
			local xv1, yv1 = front:getLinearVelocity()
			local xv2, yv2 = rear:getLinearVelocity()
			if not player.isCrashing and player.velocity < player.maxVelocity then
				player.velocity = player.velocity + 2
			end
			front:setLinearVelocity(player.velocity, yv1)
		end
	end
	return player
end
gamefunctions.newPlayer = newPlayer

-- fungsi untuk menambahkan congratulation frame saat 
-- pemain berhasil menyelesaikan semua level
local function newCongratulationFrame(scoreValue, timeValue)
	local group = display.newGroup()
	local frame = display.newImage(group, "assets/image/congratulation.png")
	local scoreText = display.newText(group,  scoreValue, 60, 10, native.defaultFontBold, 30 )
	scoreText:setFillColor(147/255,86/255,0)
	local timeText = display.newText(group,  timeValue, 60, 54, native.defaultFontBold, 30 )
	timeText:setFillColor(147/255,86/255,0)
	local menuButton = display.newImage(group, "assets/image/menu_button.png")
	menuButton.x, menuButton.y, menuButton.oriY = 90, _H/1.7, 120
	group.x = _W/2
	group.y = _H/2 + 30
	menuButton.touch = function (self, event) 
		if event.phase == "began" then
			group:destroy()
			composer.removeScene("play")
			composer.gotoScene("menu", "fade", 500 )
		end
	end
	transition.to(menuButton, {time = 500, delay = 1000, y = menuButton.oriY, transition=easing.inExpo})
	menuButton:addEventListener("touch", menuButton)
	
	function group:destroy()
		frame:removeSelf()
		scoreText:removeSelf()
		timeText:removeSelf()
		menuButton:removeSelf()
		menuButton:removeEventListener("touch", menuButton)
		group:removeSelf()
		
		frame = nil
		scoreText = nil
		timeText = nil
		menuButton = nil
		group = nil
	end
	return group
end
gamefunctions.newCongratulationFrame = newCongratulationFrame

-- fungsi untuk menampilkan frame saat boat tenggelam
newSinkingFrame = function(scoreValue, timeValue, distance)
	local group = display.newGroup()
	local frame = display.newImage(group, "assets/image/sinking.png")
	local scoreText = display.newText(group, scoreValue, -35, 14, native.defaultFontBold, 30 )
	local timeText = display.newText(group, timeValue, -35, 60, native.defaultFontBold, 30 )
	local distanceText = display.newText(group, distance, 130, 50, native.defaultFontBold, 30 )
	local menuButton = display.newImage(group, "assets/image/menu_button.png")
	menuButton.x, menuButton.y, menuButton.oriY = 150, _H/1.5, 110
	group.x = _W/2
	group.y = _H/2.5
	
	menuButton.touch = function (self, event) 
		if event.phase == "began" then
			group:destroy()
			composer.removeScene("play")
			composer.gotoScene("menu", "fade", 500 )
		end
	end
	
	transition.to(menuButton, {time = 500, delay = 1000, y = menuButton.oriY, transition=easing.inExpo})
	menuButton:addEventListener("touch", menuButton)
	
	function group:destroy()
		frame:removeSelf()
		scoreText:removeSelf()
		timeText:removeSelf()
		menuButton:removeSelf()
		menuButton:removeEventListener("touch", menuButton)
		group:removeSelf()
		
		frame = nil
		scoreText = nil
		timeText = nil
		menuButton = nil
		group = nil
	end
	return group
end

--fungsi untuk memasang ui elements seperti hud dan tombol
local function newUIElements (player, startTime)
	local uiGroup =  display.newGroup()
	local boatCond = display.newGroup() -- tampilan health condition of boat 
	local boatCondBack = display.newGroup()
	local mileage = display.newText(uiGroup, "0 m", 60, 31, native.defaultFontBold, 25 )
	local speed = display.newText(uiGroup, "0 km/h", 200, 31, native.defaultFontBold, 25 )
	local timer = display.newText(uiGroup, "00:00.00", 345, 31, native.defaultFontBold, 25)
	
	-- boat 10 buah bar sebagai indikator health
	for i=1, 10 do
		local box = display.newRect(boatCond, 10 + i*14 , 70, 8, 20)
		local back = display.newRect(boatCondBack, 10 + i*14 , 70, 10, 22)
		back.alpha = 0.3
		box:setFillColor(0,1,0)
	end
	
	uiGroup:insert ( boatCondBack )
	uiGroup:insert ( boatCond )
	
	-- tampilan "jarum merah' pada button kanan
	local pressure = display.newRoundedRect(uiGroup, _W*0.95 - 50, _H*0.95 - 50, 80, 10, 5)
	pressure.anchorX = 0.95
	pressure.anchorY = 0.5
	pressure.alpha = 0.4
	pressure:setFillColor(1,0,0)
	
	-- button kiri dan kanan
	-- silahkan gunakan/implementasikan button kiri untuk fungsi menyelam
	local rightBtn = display.newImage(uiGroup, "assets\\image\\button.png", _W*0.95, _H*0.95)
	local leftBtn = display.newImage(uiGroup, "assets\\image\\button.png", _W*0.05, _H*0.95)
	rightBtn.anchorX = 1
	rightBtn.anchorY = 1
	leftBtn.anchorX = 0
	leftBtn.anchorY = 1
	rightBtn.alpha = 0.4
	leftBtn.alpha = 0.4
	leftBtn.isVisible = false
	rightBtn.isDown = false
	leftBtn.isDown = false
	
	-- fungsi yang di eksekusi jika button kanan di tekan dan tahan
	local timePressed = 0
	function rightBtn:touch(event)
		if event.phase == "began" then
			self.alpha = 0.6
			timePressed = system.getTimer()
			self.isDown = true
			
		end
		if event.phase == "ended" then
			self.alpha = 0.4
			player:jump(system.getTimer() - timePressed)
			timePressed = 0
			self.isDown = false
			audio.play( jumpSound, {loops = -0,} )
		end
	end
	rightBtn:addEventListener("touch", rightBtn)
	

	function leftBtn:touch(event)
		if event.phase == "began" then
			player:dive()
		end
	end
	leftBtn:addEventListener("touch", leftBtn)

	-- fungsi yang dieksekusi untuk mengupdate player health
	-- dipanggil oleh player saat terjadi collision dengan obstacles
	function uiGroup:updatePlayerHealth()
		health = player.health
		for i=1, boatCond.numChildren do
			local box = boatCond[i]
			local index = math.ceil(health/10)
			if i > index then
				box.alpha = 0
			else
				local color = (math.ceil(health / 10)/10)
				box:setFillColor(1 - color,color,0)
			end
		end	
	end
	
	local pressRotation = 0
	local currentTime = ""
	local distance = ""
	local meter = 0
	
	-- update UI
	function uiGroup:update()
		-- update mileage
		meter = -1*math.floor((player.position-1)/33.7) --44.9
		if meter< 1000 then
			distance = meter.. " m" 
		else
			local km = math.floor(meter/1000)
			local hm = math.floor((meter%1000)/100)
			local dam = math.floor((meter%100) /10)
			distance =  km .. "." .. hm .. dam .. " km"
		end
		mileage.text = distance
		
		-- update tampilan speed
		speed.text = math.floor(player.velocity/15) .. " km/h" --20
		
		-- update waktu
		local duration = system.getTimer() - startTime
		local minute = math.floor(duration / 60000)
		local second = math.floor((duration % 60000) / 1000)
		local ms = math.floor((duration % 1000) / 100)
		local sec = "0"
		
		if (second < 10) then
			sec = "0" .. second
		else
			sec = second
		end
	
		currentTime = minute .. ":" .. sec .. "." .. ms
		timer.text = currentTime
		
		-- rotasikan jarum merah saat button kanan ditekan
		if rightBtn.isDown then
			if pressure.rotation < 90 then
				local rot = 5
				pressRotation = pressRotation + rot
				pressure:rotate(rot)
			end
		else
			pressure:rotate(-1 * pressRotation)
			pressRotation = 0
		end
	end
	
	-- set dive button menjadi true ketika player mendapatkan utilitas menyelam
	function uiGroup:addDiveButton()
		leftBtn.isVisible = true
		-- do anything
	end

	function uiGroup:getDistance()
		return distance
	end
	
	function uiGroup:getCurrentTime()
		return currentTime
	end
	
	-- fungsi untuk menghitung score
	function uiGroup:getScore()
		local score = data.level* 1000 + player.health * 100 - math.floor((startTime - system.getTimer())/100)
		if score < 10 then
			score = 10
		end
		return score
	end
	
	function uiGroup:getMileage()
		return meter
	end
	
	function uiGroup:destroy()
		uiGroup:removeSelf()
		uiGroup = nil
	end
	
	return uiGroup
end
gamefunctions.newUIElements = newUIElements

--fungsi untuk menambahkan ground/laut pada layar
local function addGround()
	local grounds = display.newGroup()
	
	-- buat laut
	local ground = display.newRect(0,0,_W*1000000,20)
	ground.x = _W * 0.5; ground.y = _H + (ground.height * 0.5)
	physics.addBody(ground, "static", {friction = 0})
	
	-- tampilan dasar laut
	-- tampilan terdapat dua buah, yang akan digeser dan ditampilkan bergantian
	-- ketika salah satu gambar laut sudah berada di luar layar, maka akan di reuse
	local seaBottom = display.newGroup()
	local seaBottom1 = display.newImage(seaBottom, "assets\\image\\seabottom.png",0,_H)
	local seaBottom2 = display.newImage(seaBottom, "assets\\image\\seabottom.png",seaBottom1.width,_H)
	seaBottom1.anchorX = 0
	seaBottom1.anchorY = 1
	seaBottom2.anchorX = 0
	seaBottom2.anchorY = 1
	
	-- tampilan air laut
	local liquid = display.newGroup()
	local liquid1 = display.newImage(liquid, "assets\\image\\alfa.png",0, _H)
	local liquid2 = display.newImage(liquid, "assets\\image\\alfa.png", liquid1.width, _H)
	liquid1.anchorX = 0
	liquid1.anchorY = 1
	liquid2.anchorX = 0
	liquid2.anchorY = 1
	liquid1.alpha = 0.7
	liquid2.alpha = 0.7
	
	grounds:insert(seaBottom)
	grounds:insert(liquid)
	
	--fungsi ini dieksekusi untuk memakai kembali ground yang sudah tak terlihat di layar
	--sebagai ground yang akan datang
	function grounds:reuse(newPos)
		if (seaBottom1.x + seaBottom1.width < - newPos) then
			seaBottom1:translate(seaBottom1.width * 2, 0)
		elseif (seaBottom2.x + seaBottom2.width < - newPos) then
			seaBottom2:translate(seaBottom1.width * 2, 0)
		end
		if (liquid1.x + liquid1.width < - newPos) then
			liquid1:translate(liquid1.width * 2, 0)
		elseif (liquid2.x + liquid2.width < - newPos) then
			liquid2:translate(liquid2.width * 2, 0)
		end
	end
	
	-- variabel local dari gamefunction yang akan digunakan pada fungsi float()
	liquidYPos = liquid1.y
	liquidHeight = liquid1.height
	
	return grounds
end
gamefunctions.addGround = addGround


-- fungsi untuk mengatur pemandangan dan sifat-sifatnya (parallax movement) dalam game
-- copyright Adhany Airsy (2012) dengan beberapa perubahan
local function addScenery()
	local baseline = _H/2
	local scenery = display.newGroup()
	local layer0 = display.newGroup()
	local layer1 = display.newGroup()
	local layer2 = display.newGroup()

	local sky = display.newImage("assets\\image\\scenery\\sky.png")
	--sky.anchorX = 0
	scenery:insert(sky)
	sky.x = _W/2
	sky.y = _H/4
	
	local cloud1 = display.newImage("assets\\image\\scenery\\cloud.png")
	--cloud1.anchorX = 0
	cloud1.x = 20
	cloud1.y = 120
	
	local cloud2 = display.newImage("assets\\image\\scenery\\cloud.png")
	--cloud2.anchorX = 0
	cloud2.x = 520
	cloud2.y = 160
	
	local cloud3 = display.newImage("assets\\image\\scenery\\cloud.png")
	cloud3.x = 1020
	cloud3.y = 50
	
	layer0:insert(cloud1)
	layer0:insert(cloud2)
	layer0:insert(cloud3)
	
	local airballon = display.newImage("assets\\image\\scenery\\air_ballon.png")
	airballon.x = 800
	airballon.y = baseline - 100
	
	layer1:insert(airballon)
	
	local landscape1 = display.newImage("assets\\image\\scenery\\scenery.png")
	landscape1.x = 750
	landscape1.y = baseline - 42
	
	local landscape2 = display.newImage("assets\\image\\scenery\\scenery.png")
	landscape2.x = 1550
	landscape2.y = baseline - 42
	
	layer2:insert(landscape1)
	layer2:insert(landscape2)
	
	scenery:insert(layer0)
	scenery:insert(layer1)
	scenery:insert(layer2)

	-- hapus air ballon yang sudah naik ke langit
	local function removeBallon( event )
		airballon:removeSelf()
		airballon = nil
	end
	timer.performWithDelay( 30000, removeBallon )
	
	--fungsi yang memberi efek pergerakan parallax, untuk di eksekusi tiap frame baru
	function scenery:parallaxMove(newPos)
		--tiap layer memiliki kecepatan pergerakan yang berbeda
		layer2.x = newPos / 4
		layer1.x = newPos / 6
		if airballon then
			airballon.y = airballon.y - 0.5
		end
		layer0.x = newPos / 8
		
		--reuse cloud
		if (cloud1.x + 200 < -newPos / 8) then
			cloud1:translate(1500, 0)
		elseif (cloud2.x + 200 < -newPos / 8) then
			cloud2:translate(1500, 0)			
		elseif (cloud3.x + 200 < -newPos / 8) then
			cloud3:translate(1500, 0)			
		end
		
		--reuse landscape
		if (landscape1.x + 300 < -newPos / 4) then
			landscape1:translate(3000, 0)
		elseif (landscape2.x + 300 < -newPos / 4) then
			landscape2:translate(3000, 0)			
		end

	end
	return scenery
end
gamefunctions.addScenery = addScenery

-- fungsi untuk membuat benda-benda ringan terapung
-- fungsi ini akan memberikan gaya ke atas pada benda-benda yang
-- memiliki densitas <= densitas air ( densitas air = 1.0 pada corona )
-- originally from INSERT.CODE - http://insertcode.co.uk
-- https://github.com/CoronaGeek/Corona-SDK-Water-Buoyancy-Example/blob/master/main.lua
-- edited by Habiburrahman
local function float(parentGroup, gy)
	for i=1, parentGroup.numChildren do
        local box = parentGroup[i]
		local offset = 20
        if box.isObstacle then
			offset = 30
		end
		
		-- jika box berada di dalam air (sebagian atau seluruhnya)
        if (box.y + (box.height * 0.5)) >= liquidYPos - liquidHeight + offset then
			local submergedPercent = math.floor (100 - (((liquidYPos - liquidHeight - box.y + (box.height * 0.5)) / box.height) * 100))
			if submergedPercent > 100 then
				submergedPercent = 100
			end
			
			-- jika >40% bagian berada dalam air
			-- gaya ke atas = besarnya massa dari air yang dipindahkan
			if submergedPercent > 40 then                        
				local buoyancyForce = (box.area * gy) * (submergedPercent / 100)
				
				box:applyForce( 0, buoyancyForce * -0.00111111112, box.x, box.y )
				box.linearDamping = 3
				box.angularDamping = 5
			else
				box.linearDamping = 0
				box.angularDamping = 0
			end
			box.isInWater = true
		
        elseif (box.y + (box.height * 0.7)) >= liquidYPos - liquidHeight + 20 then
				box.isInWater = true
		elseif (box.y + (box.height)) >= liquidYPos - liquidHeight + 20 then
			box.allInWater = true
		else
			box.isInWater = false
		end     
	end     
end
gamefunctions.float = float

return gamefunctions
