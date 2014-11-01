-----------------------------------------------------------------------------------------
-- levelManager.lua
-- Modul yang mengatur penyimpanan data level
-- Digunakan secara intensif pada levelSelection.lua
-----------------------------------------------------------------------------------------

local dm = require("utility.dataManager")
local filename = "levelSetting.json"

local l = {}

-- Nilai default data level saat pertama kali bermain.
-- Bukan struktur penyimpanan data yang baik. Data statis seperti sourceCode dan imagePath tidak
-- perlu di save-load. Cukup atribut unlocked, highscore, dan star saja yang disimpan.
local default = {
		{
			sourceCode = "level1",
			imagePath = "images/level1.png",
			unlocked = true,
			highscore = 0,
			star = 0
		},
		{
			sourceCode = "level2",
			imagePath = "images/level2.png",
			unlocked = false,
			highscore = 0,
			star = 0
		},
		{
			sourceCode="level3",
			imagePath = "images/level3.png",
			unlocked = false,
			highscore = 0,
			star = 0
		},
	}
dm.saveTable(default, filename)
local levelData = dm.loadTable(filename, default)

local function getLevelData(index)
	return levelData[index]
end

local function updateState(levelIndex, unlockState)
	levelData[levelIndex].unlocked = unlockState
	dm.saveTable(levelData, filename)
end

local function updateHighscore(levelIndex, highscore)
	levelData[levelIndex].highscore = highscore
	dm.saveTable(levelData, filename)
end

local function updateStar(levelIndex, stars)
	levelData[levelIndex].star = stars
	dm.saveTable(levelData, filename)
end

l.getLevelData = getLevelData
l.updateState  = updateState
l.updateHighscore = updateHighscore
l.updateStar = updateStar

return l