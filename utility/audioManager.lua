-----------------------------------------------------------------------------------------
-- audioManager.lua
-- Modul yang mengatur penggunaan audio
-- Dengan menggunakan modul ini, programmer dapat memainkan audio berdasarkan konfigurasi
-- suara yang sedang di mute ataupun tidak secara transparan.
--
-- (c) Adhani Airsy (2012) & Abka (2013), edited Habib (2014)
-----------------------------------------------------------------------------------------

local dm = require("utility.dataManager")
local filename = "audioSetting.json"
local a = {}
a.bmHandle = nil
local currentVolume

-- Nilai default dari sound adalah ON saat pertama kali bermain
local setting = dm.loadTable(filename , {isOn = true})

local function playSFX(sfxHandle)
	if(setting.isOn) then
		audio.play(sfxHandle)
	end
end

local function playBM(bmHandle, options)
	a.bmHandle = audio.play(bmHandle,options)
	if(not setting.isOn) then
		audio.pause(a.bmHandle)
	end
end

local function stopBM()
	audio.stop(a.bmHandle)
end


local function setSoundStatus(newStatus)
	setting.isOn = newStatus
	if newStatus then
		audio.resume(a.bmHandle)
	else
		audio.pause(a.bmHandle)
	end
	dm.saveTable(setting, filename)
end

local function getSoundStatus()
	return setting.isOn
end

a.playSFX = playSFX
a.playBM = playBM
a.stopBM = stopBM
a.setSoundStatus = setSoundStatus
a.getSoundStatus = getSoundStatus

return a