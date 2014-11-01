-- levelutil.lua

---------------------------------------------------------------------
-- Berisikan fungsi2 untuk membangun level 
---------------------------------------------------------------------

levelutil = {}
local _W = display.contentWidth
local _H = display.contentHeight
local physics = require("physics")

-- fungsi untuk memperoleh jumlah level berdasarkan ketersediaan file level
-- file level harus berurut 1 .. 100 dengan penamaan: level[No].lua
local function getNumLevel()
	local base = base or system.ResourceDirectory
	local numLevel = 0
	for i=1, 100 do
		local filename = "level\\level" .. i .. ".lua"
		local filePath = system.pathForFile( filename, base )

		if filePath then
			numLevel = numLevel + 1
		else
			break
		end
	end
	return numLevel
end
levelutil.getNumLevel = getNumLevel

-- fungsi untuk menambahkan level
local function addLevel(levelNumber, offset)
	-- load data level
	local level = require("level\\level" .. levelNumber)
	
	local levelObj = {}
	
	-- benda2/obstacles yang mengambang dimasukkan ke group floatObs
	local floatObs = display.newGroup()
	
	-- kotak kayu
	for i=1, table.getn(level.box) do
		local obj = display.newImage(floatObs, "assets\\image\\box.png", level.box[i] + offset, _H*0.3)
        obj.area = obj.height * obj.width
		obj.rotation = math.random(0,180)
		obj.isObstacle = true
		obj.damage = 10 -- nilai damage yang akan mengurangi health pada saat terjadi collision dengan pemain
        physics.addBody( obj, { bounce=0.5, density=0.8, friction=0.5} )
		obj.name = "box"
	end
	
	-- sampah2
	for i=1, table.getn(level.trash) do
		local obj = display.newImage(floatObs, "assets\\image\\trash.png", level.trash[i] + offset, _H*0.3)
        obj.area = obj.height * obj.width
		obj.rotation = math.random(0,180)
		obj.isObstacle = true
		obj.damage = 5 -- nilai damage yang akan mengurangi health pada saat terjadi collision dengan pemain
        physics.addBody( obj, { bounce=0.5, density=0.7, friction=0.5} )
		obj.name = "trash"
	end
	
	--ranjau
	for i=1, table.getn(level.seaMine) do
		local obj = display.newImage(floatObs, "assets\\image\\Sea_Mine.png", level.seaMine[i] + offset, _H*0.3)
        obj.area = obj.height * obj.width
		obj.rotation = 0
		obj.isObstacle = true
		--damage instant kill
		obj.damage = 100 -- nilai damage yang akan mengurangi health pada saat terjadi collision dengan pemain 
        physics.addBody( obj, { bounce=1.0, density=1.5, friction=0.8} )
		obj.name = "seaMine"
	end

	local islandshape = {-140,0,-35, -180, -35, -260, 95, -260, 95, -200, 140, 0 }
	local islands = display.newGroup()
	for i=1, table.getn(level.island) do
		local obj = display.newImage(islands, "assets\\image\\island.png", level.island[i] + offset, _H)
        obj.area = obj.height * obj.width
		obj.isObstacle = true
		obj.damage = 0
        physics.addBody( obj, "static", {friction=0.5, shape = islandshape} )
		obj.anchorY = 1
		obj.name = "island"
	end
	
	-- notifikasi saat memasuki level
	local levelNotif = display.newText( "Level " .. levelNumber, _W/2, _H/1.35, native.defaultFontBold, 50 )
	levelNotif.alpha = 0
	transition.fadeIn(levelNotif, {time=2000})
	
	-- fungsi untuk menghilangkan notifikasi dengan fading
	local function notifOut( event )
		transition.fadeOut(levelNotif)
	end
	timer.performWithDelay( 3000, notifOut )
	
	levelObj.floatObs = floatObs
	levelObj.islands = islands
	levelObj.length = level.length
	return levelObj
end
levelutil.addLevel = addLevel

-- fungsi untuk menghapus level pada scene
-- level yang telah lalu akan dihapus saat perpindahan level
local function removeLevel(levelObj)
	levelObj.floatObs:removeSelf()
	levelObj.islands:removeSelf()
	levelObj.floatObs = nil
	levelObj.islands = nil
end
levelutil.removeLevel = removeLevel

-- fungsi untuk menambahkan utilitas, seperti utilitas menyelam
function addUtility()
	local utilities = display.newGroup()
	local diveUtil = display.newImage(utilities, "assets\\image\\dive-icon.png", 24900, _H/4)
	physics.addBody( diveUtil, "static", {isSensor = true, box={halfWidth = 36, halfHeight = 26}} )
	diveUtil.name = "diveutil"
	local diveUtil2 = display.newImage(utilities, "assets\\image\\dive-icon.png", 1000, _H/4)
	physics.addBody( diveUtil2, "static", {isSensor = true, box={halfWidth = 36, halfHeight = 26}} )
	diveUtil2.name = "diveutil"
	return utilities
end
levelutil.addUtility = addUtility

return levelutil