--[[
	POST LUDUM DARE THOUGHTS

	EntranceJew:
	a major bonus that you could get for free is just some basic exploration and having the player "stumble" into rooms with these sorts of things going on in them (navigating a network / file system for example).
	even a varied map with scrolling and objectives and things to accomplish while whatever else is going on would help a lot.
	'cause when you can see all of your boundaries at once y'can't help but feel caged (and I imagine you don't want that unless a special encounter is happening).

	Based on Windows 95:
	8MB of RAM
	4GB HDD

	ROOM TYPES:
	System Root
	Fonts 
	Backup 
	Restore
	Documents
	Music
	Photos
	Videos
	Minidumps
	Drivers
	Help
	Passwords

	--- --- ---
	Save Point
	--- --- ---
	http://i.imgur.com/6URpZVz.png
	BOSSES
	UpdateOS.exe
	Command Shell
	Task Manager

	FINAL BOSS
	System32
--]]

function love.load()
	--image filter
	love.graphics.setDefaultFilter("nearest", "nearest")

	--auto require cause lazy
	local luaFiles = love.filesystem.getDirectoryItems("")

	for k = 1, #luaFiles do
		if love.filesystem.isFile(luaFiles[k]) then
			if luaFiles[k]:sub(-4) == ".lua" then
				if luaFiles[k] ~= "main.lua" and luaFiles[k] ~= "conf.lua" and luaFiles[k] ~= "mobile.lua" then
					require(luaFiles[k]:gsub(".lua", ""))
				end
			end
		end
	end

	--images
	floorTile = love.graphics.newImage("graphics/tile.png")
	floorTileData = love.image.newImageData("graphics/tile.png")
	floorQuads = {}

	for y = 1, floorTile:getHeight() / 17 do
		for x = 1, floorTile:getWidth() / 17 do
			table.insert(floorQuads, love.graphics.newQuad((x - 1) * 17, (y - 1) * 17, 16, 16, floorTile:getWidth(), floorTile:getHeight()))
		end 
	end

	playerimg = love.graphics.newImage("graphics/player.png")

	gameBatch = love.graphics.newSpriteBatch(floorTile, 100)

	antivirusrocket = love.graphics.newImage("graphics/antivirus.png")
	antivirusquads = {}
	for k = 1, 10 do
		antivirusquads[k] = love.graphics.newQuad((k - 1) * 10, 0, 9, 9, antivirusrocket:getWidth(), antivirusrocket:getHeight())
	end
	gameoverimg = love.graphics.newImage("graphics/gameover.png")

	proxyintro = love.graphics.newImage("graphics/proxy_intro.png")
	proxyintroquads = {}
	for k = 1, 9 do
		proxyintroquads[k] = love.graphics.newQuad((k - 1) * 10, 0, 9, 9, proxyintro:getWidth(), proxyintro:getHeight())
	end

	proxyimg = love.graphics.newImage("graphics/proxy.png")
	proxyquads = {}
	for k = 1, 2 do
		proxyquads[k] = love.graphics.newQuad((k - 1) * 10, 0, 9, 7, proxyimg:getWidth(), proxyimg:getHeight())
	end

	firewallimg = love.graphics.newImage("graphics/firewall.png")
	firewallquads = {}
	for k = 1, 8 do
		firewallquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, firewallimg:getWidth(), firewallimg:getHeight())
	end

	controls = 
	{
		["left"] = "a",
		["right"] = "d",
		["jump"] = " ",
		["up"] = "w",
		["down"] = "s",
		["pause"] = "escape"
	}

	--check System
	mobileMode = false
	if love.system.getOS() == "Android" or love.system.getOS() == "iOS" then
		mobileMode = true

		require 'mobile'
	end

	homebrewMode = false
	if love.system.getOS() == "3ds" then
		homebrewMode = true

		controls["left"] = "cpadleft"
		controls["right"] = "cpadright"
		controls["jump"] = "b"
	end

	if not homebrewMode then
		gameFunctions.loadAudio()
	end
	--other
	scale = 2

	currentmap = 1

	love.window.setTitle("Hax0r?")
	love.window.setIcon(love.image.newImageData("graphics/icon.png"))

	fullscreen = false
	gameFunctions.fullScreen(true)

	gameFunctions.changeState("title")

	gameMap = { "!", "@", "#", "$", "%", "&" }
end

function love.update(dt)
	dt = math.min(1/60, dt)

	if _G[state .. "_update"] then
		_G[state .. "_update"](dt)
	end
end

function love.draw()
	love.graphics.push()

	if missingX and missingY then
		love.graphics.translate(missingX, missingY)
	end

	if _G[state .. "_draw"] then
		_G[state .. "_draw"]()
	end

	love.graphics.pop()
end

function love.keypressed(key)
	if _G[state .. "_keypressed"] then
		_G[state .. "_keypressed"](key)
	end
end

function love.keyreleased(key)
	if _G[state .. "_keyreleased"] then
		_G[state .. "_keyreleased"](key)
	end
end

gameFunctions = {}
function gameFunctions.changeState(newState, ...)
	local arg = {...}

	state = newState

	if _G[state .. "_init"] then
		_G[state .. "_init"](unpack(arg))
	end
end

function gameFunctions.getWidth()
	return 17 * 16
end

function gameFunctions.getHeight()
	return 12 * 16
end

function gameFunctions.getFullScreenScale()
	local w, h = love.window.getDesktopDimensions()

	return math.min(w / gameFunctions.getWidth(), h / gameFunctions.getHeight())
end

function gameFunctions.fullScreen(load)
	local w, h = love.window.getDesktopDimensions()

	if not homebrewMode then
		if not load then
			love.filesystem.write("settings.txt", tostring(fullscreen))
		else
			if love.filesystem.exists("settings.txt") then
				local bool = love.filesystem.read("settings.txt")

				if bool == "true" then
					fullscreen = true
				else
					fullscreen = false
				end
			end
		end
	end

	scale = 2

	missingX, missingY = 0, 0
	if fullscreen or mobileMode then
		scale = math.min(w / gameFunctions.getWidth(), h / gameFunctions.getHeight())
		love.window.setMode(w, h, {fullscreen = true})

		missingX, missingY = (w - (gameFunctions.getWidth() * scale)) / 2, (h - (gameFunctions.getHeight() * scale)) / 2
	else
		love.window.setMode(17 * 16 * scale, 12 * 16 * scale)
	end

	backgroundFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 16 * scale)
	consoleFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 8 * scale)
	winFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 12 * scale)
	pauseFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 14 * scale)
	mainFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 32 * scale)
end

function gameFunctions.loadAudio()
	--music
	bgm = love.audio.newSource("audio/bgm.ogg")
	bgm:setLooping(true)
	--bgm:play()
	bgm_start = love.audio.newSource("audio/bgm-start.ogg")
	bgm_start:setLooping(true)

	titlemusic = love.audio.newSource("audio/title.ogg")
	titlemusic:setLooping(true)

	--sfx
	explosionsnd = love.audio.newSource("audio/explosion.ogg")
	jumpsnd = love.audio.newSource("audio/jump.ogg")
	blipsnd = love.audio.newSource("audio/blip.ogg")

	bitsnd = {love.audio.newSource("audio/bit.ogg"), love.audio.newSource("audio/bit2.ogg"), love.audio.newSource("audio/bit3.ogg")}

	gameoversnd = love.audio.newSource("audio/gameover.ogg")

	hitproxysnd = love.audio.newSource("audio/hitproxy.ogg")
	playerspawnsnd = love.audio.newSource("audio/playerspawn.ogg")
end

function love.focus(f)
	if not f and not gameover then
		paused = true
	end
end