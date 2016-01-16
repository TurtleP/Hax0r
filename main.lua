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

	print("sup")

	controls["right"] = "cpadright"
	controls["left"] = "cpadleft"
	controls["up"] = "cpadup"
	controls["down"] = "cpaddown"

	controls["jump"] = "a"
	controls["pause"] = "start"
	controls["dodge"] = {"lbutton", "rbutton"}

	homebrewMode = true

	if love.system.getOS() ~= "3ds" then
		--image filter
		love.graphics.setDefaultFilter("nearest", "nearest")

		homebrewMode = false
		math.random = love.math.random

		require 'libraries/3ds'

		controls["right"] = "d"
		controls["left"] = "a"
		controls["up"] = "w"
		controls["down"] = "s"

		controls["jump"] = "space"
		controls["pause"] = "return"
		controls["dodge"] = {"q", "e"}

		require 'libraries/joystick'

		local oldAdd = love.joystickadded
		love.joystickadded = function(joyStick)
			oldAdd(joyStick)

			getJoystick(1).doAxis = function(self, axis, value)
				if axis == "leftx" then
					if value > 0.5 then
						love.keypressed(controls["right"])
						love.keyreleased(controls["left"])
					elseif value < -0.5 then
						love.keypressed(controls["left"])
						love.keyreleased(controls["right"])
					elseif value >= -0.5 or value <= 0.5 then
						love.keyreleased(controls["right"])
						love.keyreleased(controls["left"])
					end
				elseif axis == "lefty" then
					if value > 0.5 then
						love.keypressed(controls["down"])
						love.keyreleased(controls["up"])
					elseif value < -0.5 then
						love.keypressed(controls["up"])
						love.keyreleased(controls["down"])
					elseif value >= -0.5 or value <= 0.5 then
						love.keyreleased(controls["up"])
						love.keyreleased(controls["down"])
					end
				end
			end

			getJoystick(1).doPressed = function(self, button)
				if button == "a" then
					love.keypressed(controls["jump"])
				end

				if button == "leftshoulder" or button == "rightshoulder" then
					love.keypressed(controls["dodge"][1])
				end

				if button == "start" then
					love.keypressed(controls["pause"])
				end

				if button == "x" then
					love.keypressed("x")
				end
			end
		end
	else
		math.randomseed(os.time())
	end

	consoleFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 16)
	introFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 32)

	titleimg = love.graphics.newImage("graphics/title.png")

	tileimg = love.graphics.newImage("graphics/base.png")

	UIIcons =
	{
		["battery"] = {love.graphics.newImage("graphics/3ds/battery.png"), love.graphics.newImage("graphics/3ds/charging.png")},
		["health"] = {["img"] = love.graphics.newImage("graphics/interface/health.png"), ["quads"] = {}},
		["power"] = love.graphics.newImage("graphics/interface/power.png")
	}

	for k = 1, 4 do
		UIIcons["health"]["quads"][k] = love.graphics.newQuad((k - 1) * 18, 0, 18, 18, UIIcons["health"]["img"]:getWidth(), 18)
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

	appsicon = love.graphics.newImage("graphics/ds.png")

	bannerimg = love.graphics.newImage("graphics/lovepotionbanner.png")

	gameoverimg = love.graphics.newImage("graphics/gameover.png")
	introimg = love.graphics.newImage("graphics/intro.png")

	saveimg = love.graphics.newImage("graphics/savebar.png")

	hax0r = love.graphics.newImage("graphics/hax0r.png")

	bufferimg = love.graphics.newImage("graphics/buffer.png")
	bufferquads = {}
	for y = 1, 2 do
		for x = 1, 12 do
			table.insert(bufferquads, love.graphics.newQuad((x - 1) * 40, (y - 1) * 40, 40, 40, bufferimg:getWidth(), bufferimg:getHeight()))
		end
	end

	cmdimg = love.graphics.newImage("enemies/powercmd.png")
	cmdquads = {}
	for k = 1, 5 do
		cmdquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, cmdimg:getWidth(), cmdimg:getHeight())
	end
	coreimg = love.graphics.newImage("enemies/system32.png")
	corestart = love.graphics.newImage("enemies/powercmdrise.png")

	hitpointimg = love.graphics.newImage("graphics/hitpoint.png")

	--maps
	local myDirectory = "maps/scripts"
	local open = io.open
	if not homebrewMode then
		open = love.filesystem.read
	end

	mapScripts = {}
	for k = 1, 9 do
		local f = open(myDirectory .. "/" .. k .. ".txt")

		if type(f) ~= "string" and f then
			mapScripts[k] = f:read("*a")

			if io.read() == nil then
				f:close()
			end
		else
			mapScripts[k] = f
		end
	end

	--audio
	titlemusic = love.audio.newSource("audio/title.wav", "stream")

	consolesound = love.audio.newSource("audio/console.wav")
	jumpsound = love.audio.newSource("audio/jump.wav")

	playerspawn = love.audio.newSource("audio/playerspawn.wav")

	gameoversnd = love.audio.newSource("audio/gameover.wav")

	deathsnd = love.audio.newSource("audio/death.wav")
	shootsnd = love.audio.newSource("audio/shoot.wav")

	bossspawnsnd = love.audio.newSource("audio/bossspawn.wav")

	lifesnd = love.audio.newSource("audio/addlife.wav")
	pausesnd = love.audio.newSource("audio/pause.wav")
	lasersnd = love.audio.newSource("audio/laser.wav")
	bossdiesnd = love.audio.newSource("audio/bossdie.wav")

	rebootsnd = love.audio.newSource("audio/reboot.wav")
	errorsnd = love.audio.newSource("audio/error.wav")

	collectSnd = {}
	for k = 1, 3 do
		collectSnd[k] = love.audio.newSource("audio/infect" .. k .. ".wav")
	end

	hurtsnd = {}
	for k = 1, 3 do
		hurtsnd[k] = love.audio.newSource("audio/hurt" .. k .. ".wav")
	end

	gameFunctions.changeState("intro")
end

function love.update(dt)
	dt = math.min(1/60, dt)
	if _G[state .. "_update"] then
		_G[state .. "_update"](dt)
	end
end

function love.draw()
	if _G[state .. "_draw"] then
		_G[state .. "_draw"]()
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
		_G[state .. "_mousepressed"](x, y, button)
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		button = "l"
	end

	if _G[state .. "_mousereleased"] then
		_G[state .. "_mousereleased"](x, y, button)
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
	local g = love.graphics.getWidth()

	if tile then
		return g / 16
	end
	return g
end

function gameFunctions.getHeight(tile)
	local g = love.graphics.getHeight()

	if tile then
		return g / 16
	end
	return g
end

function love.focus(f)
	if not f and not gameover then
		--paused = true
	end
end
