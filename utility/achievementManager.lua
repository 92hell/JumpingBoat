-----------------------------------------------------------------------------------------
-- achievementManager.lua
-- Modul yang mengatur data dan kondisi achievement pemain
-- Digunakan secara intensif pada achievement.lua
-- Modul ini sangat bergantung pada data modul lain, seperti data uang pada playerManager.lua
-----------------------------------------------------------------------------------------

local dm = require("utility.dataManager")
local p = require("utility.playerManager")
local filename = "achievement.json"
local a = {}

-- Kondisi achievement pertama: bermain tengah malam
local function sampleCondition1()
	local date = os.date( "*t" )
	return date.hour>23
end

-- Kondisi achievement kedua: level semua skill maksimal
local function sampleCondition2()
	return p.isMaxLevel("bonus") and p.isMaxLevel("jump")
end

-- Kondisi achievement ketiga: uang pemain sangat banyak
local function sampleCondition3()
	return p.getMoney() > 1000000
end

-- Data tentang achievement yang bersifat statis (tidak perlu di save-load)
local achievementData = {
	[1] = {
		name = "Night Stalker",
		description = "Check this screen between 23:00-23:59",
		condition = sampleCondition1
	},
	[2] = {
		name = "Alpha Species",
		description = "Master all skills",
		condition = sampleCondition2
	},
	[3] = {
		name = "Millionaire",
		description = "Collect more than 1000000 gold",
		condition = sampleCondition3
	},
	[4] = {
		name = "Gift",
		description = "Smile & Cheer Up :)",
		condition = function() return true end
	}
}

-- Nilai default achievement saat pemain pertama kali bermain.
local default = {
	[1] = false,
	[2] = false,
	[3] = false,
	[4] = false
}
local unlockData = dm.loadTable(filename , default)

local function checkNewAchievement()
	for i = 1, #achievementData do
		if not unlockData[i] and achievementData[i].condition() then
			unlockData[i] = true;
		end
	end
	dm.saveTable(unlockData, filename)
end

local function isUnlocked(achievementIndex)
	return unlockData[achievementIndex]
end

local function getAchievementData(achievementIndex)
	return achievementData[achievementIndex]
end

local function getAchievementNumber()
	return #achievementData
end

a.checkNewAchievement = checkNewAchievement
a.isUnlocked = isUnlocked
a.getAchievementData = getAchievementData
a.getAchievementNumber = getAchievementNumber

return a