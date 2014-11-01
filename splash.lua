-----------------------------------------------------------------------------------------
-- splash.lua
-----------------------------------------------------------------------------------------
local composer = require( "composer" )
local scene = composer.newScene()
local _W = display.contentWidth
local _H = display.contentHeight

-----------------------------------------------------------------------------------------
--Forward Declaration
-----------------------------------------------------------------------------------------
local bg
local myRectangle 
local timerStash

-- Called when the scene's view does not exist:
function scene:create( event )
	local group = self.view
	timerStash = {}
	
	myRectangle = display.newRect(0, 0, 856, 480)
	myRectangle:setFillColor(255, 255, 255)
	bg = display.newImage("assets/image/fasilkom.png")
	bg.x = _W/2
	bg.y = _H/2
	myRectangle.x = _W/2
	myRectangle.y = _H/2
	
	group:insert(myRectangle)
	group:insert(bg)
end

-- Called immediately after scene has moved onscreen:
function scene:show( event )
	local group = self.view
	
	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	-- Setelah jeda waktu 1000 ms, scene ini digantikan oleh scen Main Menu dengan effect fade
	--composer.gotoScene("menu", "fade", 1000)
	timerStash.waitingTime = timer.performWithDelay(100, function() composer.gotoScene("menu", "fade", 1000) end)
end

-- Called when scene is about to move offscreen:
function scene:hide( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	for k,v in pairs(timerStash) do
		timer.cancel(v)
		timer.k = nil
	end
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroy( event )
	local group = self.view
	
	bg:removeSelf()
	bg = nil
	
	myRectangle:removeSelf()
	myRectangle = nil
	
	timerStash = nil
end

-----------------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
-----------------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene