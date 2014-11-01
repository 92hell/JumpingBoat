-----------------------------------------------------------------------------------------
-- dataManager.lua
-- Modul yang mengatur save-load data pada format table ke json dan sebaliknya.
--
-- (c) Adhani Airsy (2012)
-----------------------------------------------------------------------------------------

local M = {}
local json = require("json")
 
-- Simpan objek table t pada file bernama filename dengan format json
local function saveTable(t, filename)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(t)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end

-- Load objek table pada file bernama filename. Jika file tidak ada, kembalikan objek table t.
local function loadTable(filename, t)
    local path = system.pathForFile( filename, system.DocumentsDirectory)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        myTable = json.decode(contents);
        io.close( file )
        return myTable
    end
	
	if M.saveTable(t, filename) then
		return t
	else
		return nil
	end
end

M.saveTable = saveTable
M.loadTable = loadTable

return M