-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- file utama yang dijalankan pertama kali
-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"

-- siapkan data,
-- dengan menambahkan tabel pada composer, maka transaksi data
-- antar scene/file akan lebih mudah
composer.data = {}
composer.data.level = 1

-- langsung menuju scene splash
composer.gotoScene( "splash")