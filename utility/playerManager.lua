-----------------------------------------------------------------------------------------
-- playerManager.lua
-- Modul yang mengatur data: uang dan skill
-- Digunakan secara intensif pada upgrade.lua
-----------------------------------------------------------------------------------------

local dm = require("utility.dataManager")
local filename = "playerSetting.json"

local p = {}

-- Nilai default uang dan skill saat pertama kali bermain
-- Bukan struktur penyimpanan yang baik. Data statis seperti description dan cost tidak
-- perlu di save-load. Cukup level saja yang disimpan.
local default = {
		money = 10000,
		bonus = {
			[1] = {
				description = "Bonus score x2",
				cost = 1000
			},
			[2] = {
				description = "Bonus score x3. Yay!",
				cost = 2000
			},
			[3] = {
				description = "Bonus score x4. Suppa!",
				cost = 3000
			},
			level = 0,
			maxLevel = 3
		},
		jump = {
			[1] = {
				description = "Skill double jump",
				cost = 5000
			},
			level = 0,
			maxLevel = 1
		},
	}
--Load data dari filename (jika ada). Jika tidak, gunakan default.
local playerData = dm.loadTable(filename, default)


local function getMoney()
	return playerData.money
end

local function getSkill(skillName)
	return playerData[skillName]
end

local function getSkillCostNextLevel(skillName)
	local currentLevel = playerData[skillName].level
	return playerData[skillName][tostring(currentLevel+1)].cost
end

local function isMaxLevel(skillName)
	return playerData[skillName].level >= playerData[skillName].maxLevel
end

local function getSkillDescriptionNextLevel(skillName)
	if isMaxLevel(skillName) then
		return "Max"
	else
		local nextLevel = playerData[skillName].level + 1
		return playerData[skillName][tostring(nextLevel)].description
	end
end


local function canBuy(skillName)
	if isMaxLevel(skillName) then 
		return false 
	else
		return getSkillCostNextLevel(skillName) <= playerData.money 
	end
end

local function upgrade(skillName)
	playerData.money = playerData.money - getSkillCostNextLevel(skillName)
	playerData[skillName].level = playerData[skillName].level + 1 
	dm.saveTable(playerData, filename)
end

local function setMoney(amount)
	playerData.money = amount
	dm.saveTable(playerData, filename)
end

p.getMoney = getMoney
p.getSkill = getSkill
p.getSkillCostNextLevel = getSkillCostNextLevel
p.isMaxLevel = isMaxLevel
p.getSkillDescriptionNextLevel = getSkillDescriptionNextLevel
p.canBuy = canBuy
p.upgrade = upgrade
p.setMoney = setMoney

return p