local d = {}

local function loadImage(source, x, y, width, height, referencePoint)
	local newDisplayObject = display.newImageRect( source, width, height)
	newDisplayObject:setReferencePoint( referencePoint )
	newDisplayObject.x, newDisplayObject.y = x, y
	return newDisplayObject
end

local function loadSprite(imageSheet, sequenceData, x, y, referencePoint)
	local newDisplayObject = display.newSprite( imageSheet, sequenceData)
	newDisplayObject:setReferencePoint( referencePoint )
	newDisplayObject.x, newDisplayObject.y = x, y
	return newDisplayObject
end

local function loadButton(source, x, y, width, height, referencePoint, onRelease)
	local newDisplayObject = loadImage(source, x, y, width, height, referencePoint)
	function newDisplayObject:touch(event )
		if event.phase == "began" then
			event.target.xScale, event.target.yScale = 1.05, 1.05
			display.getCurrentStage():setFocus(event.target)
			event.target.isFocus = true
		elseif event.target.isFocus and event.phase == "moved" then
		else
			event.target.xScale, event.target.yScale = 1, 1
			event.target.isFocus = nil
			display.getCurrentStage():setFocus(nil)
			if(onRelease) then onRelease() end
		end
		return true
	end
	return newDisplayObject
end

local function loadButtonSet(imageSheet, sequenceData, x, y, referencePoint, onRelease)
	local buttonSet = loadSprite(imageSheet, sequenceData, x, y, referencePoint)
	function buttonSet:touch(event )
		if event.phase == "began" then
			event.target.xScale, event.target.yScale = 1.05, 1.05
			display.getCurrentStage():setFocus(event.target)
			event.target.isFocus = true
		elseif event.target.isFocus and event.phase == "moved" then
		else
			event.target.xScale, event.target.yScale = 1, 1
			event.target.isFocus = nil
			display.getCurrentStage():setFocus(nil)
			if(onRelease) then onRelease() end
		end
		return true
	end
	return buttonSet
end



d.loadImage = loadImage
d.loadButton = loadButton
d.loadSprite = loadSprite
d.loadButtonSet = loadButtonSet

return d