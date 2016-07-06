class = require 'libraries/middleclass'

require 'data'

require 'classes/console'
require 'classes/player'
require 'classes/tile'
require 'classes/firewall'
require 'classes/map'
require 'classes/roomsign'
require 'classes/healthitem'
require 'classes/barrier'
require 'classes/bullet'

require 'libraries/event'
require 'libraries/physics'
require 'libraries/gamefunctions'

require 'states/game'
require 'states/title'
require 'states/win'
require 'states/credits'
require 'states/intro'
require 'states/gameover'

require 'enemies/music'
require 'enemies/paintbird'
require 'enemies/executioner'
require 'enemies/sudo'
require 'enemies/webexplore'
require 'enemies/document'
require 'enemies/cmd'
require 'enemies/core'

--[[
	So as long as you stick to the lisence I will not try to hunt you down. That means you CAN modify the game but CANNOT reditribute the game as profit.
	Furthermore, you must give me credit (TurtleP aka Jeremy Postelnek) for any modifications you make of said game. Not sure why you'd be in this file,
	but who knows since you probably want to look at this code. It's not the best, trust me on that.

	Obligatory hidden webm's from Jeviny:
	https://u.pomf.io/fpqedd.webm
	https://u.pomf.io/arwmbp.webm

	You're welcome Jeviny.
--]]

function love.load()
	controls = {}

	love.graphics.setDefaultFilter("nearest", "nearest")

	math.random = love.math.random

	--require 'libraries/3ds'

	controls["right"] = "d"
	controls["left"] = "a"
	controls["up"] = "w"
	controls["down"] = "s"

	controls["jump"] = "space"
	controls["pause"] = "return"
	controls["dodge"] = {"q", "e"}

	consoleFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 16)
	introFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 32)
	gameOverFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 16)

	titleimg = love.graphics.newImage("graphics/title.png")

	tileimg = love.graphics.newImage("graphics/base.png")

	UIIcons =
	{
		["battery"] = love.graphics.newImage("graphics/interface/battery.png"),
		["health"] = {["img"] = love.graphics.newImage("graphics/interface/health.png"), ["quads"] = {}},
		["power"] = love.graphics.newImage("graphics/interface/power.png")
	}

	for k = 1, 4 do
		UIIcons["health"]["quads"][k] = love.graphics.newQuad((k - 1) * 18, 0, 16, 16, UIIcons["health"]["img"]:getWidth(), 16)
	end

	batteryquads = {}
	for k = 1, 3 do
		batteryquads[k] = love.graphics.newQuad((k - 1) * 24, 0, 23, 14, UIIcons["battery"]:getWidth(), UIIcons["battery"]:getHeight())
	end

	playerimg = love.graphics.newImage("graphics/player-new.png")
	playerquads = {}
	for k = 1, 3 do
		playerquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, playerimg:getWidth(), playerimg:getHeight())
	end

	firewallimg = love.graphics.newImage("graphics/firewall.png")
	firewallquads = {}
	for k = 1, 2 do
		firewallquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, firewallimg:getWidth(), firewallimg:getHeight())
	end

	waterimg = love.graphics.newImage("graphics/digitalsea.png")
	waterquads = {}
	for k = 1, 6 do
		waterquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, waterimg:getWidth(), waterimg:getHeight())
	end

	deathimg = love.graphics.newImage("graphics/death.png")
	deathquads = {}
	for k = 1, 13 do
		deathquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, deathimg:getWidth(), deathimg:getHeight())
	end

	waterbaseimg = love.graphics.newImage("graphics/seatile.png")

	executionerimg = {love.graphics.newImage("enemies/executioner.png"), love.graphics.newImage("enemies/executionerFlip.png")}
	executionerquads = {}
	for k = 1, 5 do
		executionerquads[k] = love.graphics.newQuad((k - 1) * 22, 0, 21, 29, executionerimg[1]:getWidth(), executionerimg[1]:getHeight())
	end

	musicimg = love.graphics.newImage("enemies/musicFile.png")
	musicquads = {}
	for k = 1, 3 do
		musicquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 13, musicimg:getWidth(), musicimg:getHeight())
	end

	noteimg = love.graphics.newImage("enemies/notes.png")
	notequads = {}
	for k = 1, 2 do
		notequads[k] = love.graphics.newQuad((k - 1) * 7, 0, 6, 8, noteimg:getWidth(), noteimg:getHeight())
	end

	paintbirdimg =
	{
		["left"] = {love.graphics.newImage("enemies/imageFile.png"), love.graphics.newImage("enemies/imageFile2.png")},
		["right"] = {love.graphics.newImage("enemies/imageFileFlip.png"), love.graphics.newImage("enemies/imageFileFlip2.png")}
	}
	paintbirdquads = {}
	for k = 1, 3 do
		paintbirdquads[k] = love.graphics.newQuad((k - 1) * 19, 0, 18, 13, paintbirdimg["left"][1]:getWidth(), paintbirdimg["left"][1]:getHeight())
	end

	background = {}
	for k = 1, 8 do
		background[k] = love.graphics.newImage("graphics/background/" .. k .. ".png")
	end

	sudoimg = love.graphics.newImage("enemies/sudo.png")
	sudoquads = {}
	for k = 1, 8 do
		sudoquads[k] = love.graphics.newQuad((k - 1) * 15, 0, 14, 14, sudoimg:getWidth(), sudoimg:getHeight())
	end

	smokeimg = love.graphics.newImage("enemies/smoke.png")
	smokequads = {}
	for k = 1, 3 do
		smokequads[k] = love.graphics.newQuad((k - 1) * 10, 0, 9, 9, smokeimg:getWidth(), smokeimg:getHeight())
	end

	exploreimg = love.graphics.newImage("enemies/ie.png")
	explorequads = {}
	for x = 1, 2 do
		explorequads[x] = {}
		for y = 1, 2 do
			explorequads[x][y] = love.graphics.newQuad((x - 1) * 17, (y - 1) * 17, 16, 16, exploreimg:getWidth(), exploreimg:getHeight())
		end
	end

	documentimg = love.graphics.newImage("enemies/document.png")
	documentquads = {}
	for k = 1, 4 do
		documentquads[k] = love.graphics.newQuad((k - 1) * 16, 0, 15, 16, documentimg:getWidth(), documentimg:getHeight())
	end

	computerimg = love.graphics.newImage("graphics/computericon.png")
	quitimg = love.graphics.newImage("graphics/quit.png")

	bannerimg = love.graphics.newImage("graphics/lovepotionbanner.png")

	gameoverimg = love.graphics.newImage("graphics/gameover.png")
	introimg = love.graphics.newImage("graphics/intro.png")

	hax0r = love.graphics.newImage("graphics/hax0r.png")

	cmdimg = love.graphics.newImage("enemies/powercmd.png")
	cmdquads = {}
	for k = 1, 5 do
		cmdquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, cmdimg:getWidth(), cmdimg:getHeight())
	end
	coreimg = love.graphics.newImage("enemies/system32.png")
	corestart = love.graphics.newImage("enemies/powercmdrise.png")

	hitpointimg = love.graphics.newImage("graphics/hitpoint.png")

	local mobileDevices =
	{
		["Android"] = true,
		["Windows App"] = true,
		["iOS"] = true
	}
	
	missingX, missingY = 0, 0
	--2560 x 1440 
	if love.system.getOS() ~= "Android" then
		changeScale(1)
	else
		desktopWidth, desktopHeight = love.graphics.getDimensions( )

		mobileMode = true

		scale = math.floor(math.max(desktopWidth / 400, desktopHeight / 240))

		missingY = ( (desktopHeight) / 2 - ( 240 * scale) / 2 )
		missingX = ( (desktopWidth) / 2 - (400 * scale) / 2 )

		--error("Width: " .. desktopWidth .. " Height: " .. desktopHeight .. " Scale: " .. scale .. ": " .. (400 * scale) .. "x" .. (240 * scale))
		require 'android/touchcontrol'
		
		touchControls = touchcontrol:new()
	end

	--maps
	mapScripts = {}
	for k = 1, 9 do
		local f = love.filesystem.read("maps/scripts/" .. k .. ".txt")
		mapScripts[k] = f
	end

	if not mobileMode then
		mapScripts[1] = love.filesystem.read("maps/scripts/1PC.txt")
	end

	--audio
	titlemusic = love.audio.newSource("audio/title.ogg", "stream")

	consolesound = love.audio.newSource("audio/console.ogg")
	jumpsound = love.audio.newSource("audio/jump.ogg")

	playerspawn = love.audio.newSource("audio/playerspawn.ogg")

	gameoversnd = love.audio.newSource("audio/gameover.ogg")

	deathsnd = love.audio.newSource("audio/death.ogg")
	shootsnd = love.audio.newSource("audio/shoot.ogg")

	bossspawnsnd = love.audio.newSource("audio/bossspawn.ogg")

	lifesnd = love.audio.newSource("audio/addlife.ogg")
	pausesnd = love.audio.newSource("audio/pause.ogg")
	lasersnd = love.audio.newSource("audio/laser.ogg")
	bossdiesnd = love.audio.newSource("audio/bossdie.ogg")

	rebootsnd = love.audio.newSource("audio/reboot.ogg")
	errorsnd = love.audio.newSource("audio/error.ogg")

	collectSnd = {}
	for k = 1, 3 do
		collectSnd[k] = love.audio.newSource("audio/infect" .. k .. ".ogg")
	end

	hurtsnd = {}
	for k = 1, 3 do
		hurtsnd[k] = love.audio.newSource("audio/hurt" .. k .. ".ogg")
	end

	gameFunctions.changeState("intro")
end

function love.update(dt)
	dt = math.min(1 / 60, dt)
	if _G[state .. "_update"] then
		_G[state .. "_update"](dt)
	end
end

function love.draw()
	love.graphics.setColor(0, 0, 0)

	love.graphics.rectangle("fill", 0, 0, missingX, love.graphics.getHeight())
	love.graphics.rectangle("fill", love.graphics.getWidth() - missingX, 0, missingX, love.graphics.getHeight())
	love.graphics.rectangle("fill", 0, missingY, love.graphics.getWidth(), missingY)
	love.graphics.rectangle("fill", 0, love.graphics.getHeight() - missingY, love.graphics.getWidth(), missingY)
	
	love.graphics.setColor(255, 255, 255)

	love.graphics.setScissor(missingX, missingY, gameFunctions.getWidth() * scale, gameFunctions.getHeight() * scale)

	love.graphics.push()

	love.graphics.translate(missingX, missingY)
	
	love.graphics.scale(scale, scale)

	if _G[state .. "_draw"] then
		_G[state .. "_draw"]()
	end

	love.graphics.pop()

	love.graphics.setScissor()

	if analogStick then
		if state ~= "game" then
			return
		end

		analogStick:draw()

		love.graphics.setColor(255, 255, 255, 255)

		for k, v in ipairs(touchControls.buttons) do
			v:draw()
		end
	end
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

function love.mousepressed(x, y, button)
	if button == 1 then
		button = "l"
	end

	if _G[state .. "_mousepressed"] then
		_G[state .. "_mousepressed"](x - missingX, y - missingY, button)
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		button = "l"
	end

	if _G[state .. "_mousereleased"] then
		_G[state .. "_mousereleased"](x - missingX, y - missingY, button)
	end
end

gameFunctions = {}
function gameFunctions.changeState(newState, ...)
	local arg = {...}

	if _G[newState .. "_init"] then
		_G[newState .. "_init"](unpack(arg))
	end

	state = newState
end

function gameFunctions.getWidth(tile)
	local g = 400

	if tile then
		return g / 16
	end
	return g
end

function gameFunctions.getHeight(tile)
	local g = 240

	if tile then
		return g / 16
	end
	return g
end

function love.focus(f)
	if not f and not gameover then
		paused = true
	end
end
