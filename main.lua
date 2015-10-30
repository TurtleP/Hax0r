class = require 'libraries/middleclass'

require 'classes/console'
require 'classes/pausemenu'
require 'classes/player'
require 'classes/tile'
require 'classes/antivirus'
require 'classes/bitenemy'
require 'classes/firewall'
require 'classes/proxy'

require 'libraries/event'
require 'libraries/physics'
require 'libraries/gamefunctions'

require 'states/game'
require 'states/title'
require 'states/win'
require 'states/credits'


require 'enemies/music'
require 'enemies/paintbird'

function love.load()

	love.window.setMode(400, 240)
	controls = {}

	controls["right"] = "cpadright"
	controls["left"] = "cpadleft"
	controls["jump"] = "a"
	controls["pause"] = "start"

	homebrewMode = true

	if love.system.getOS() ~= "3ds" then
		--image filter
		love.graphics.setDefaultFilter("nearest", "nearest")
		love.window.setTitle("Hax0r?")
		love.window.setIcon(love.image.newImageData("graphics/icon.png"))

		function love.graphics.setScreen(s) 

		end

		controls["right"] = "d"
		controls["left"] = "a"
		controls["jump"] = " "
		controls["pause"] = "escape"

		homebrewMode = false
	end

	math.randomseed(os.time())


	titleimg = love.graphics.newImage("graphics/title.png")

	tileimg = love.graphics.newImage("graphics/base.png")

	UIIcons =
	{
		["linux"] = love.graphics.newImage("graphics/interface/bottomlogo.png"),
		["battery"] = {love.graphics.newImage("graphics/3ds/battery.png"), love.graphics.newImage("graphics/3ds/charging.png")},
		["health"] = {},
		["background"] = love.graphics.newImage("graphics/interface/background.png"),
		["power"] = love.graphics.newImage("graphics/interface/power.png")
	}

	for k = 1, 5 do
		UIIcons["health"][k] = love.graphics.newImage("graphics/interface/health" .. k .. ".png")
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
	for k = 1, 9 do
		deathquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, deathimg:getWidth(), deathimg:getHeight())
	end

	waterbaseimg = love.graphics.newImage("graphics/seatile.png")

	--other
	backgroundFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 16)
	consoleFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 16)

	--maps
	maps = {}
	maps[1] = require "maps/1"
	maps[2] = require "maps/2"
	maps[3] = require "maps/3"
	maps[4] = require "maps/4"

	maps[2].offsetX = (25 * 16)

--	maps[4] = require "maps/save"

	--audio
	titlemusic = love.audio.newSource("audio/title.wav")

	consolesound = love.audio.newSource("audio/console.wav")
	jumpsound = love.audio.newSource("audio/jump.wav")
	playerspawn = love.audio.newSource("audio/playerspawn.wav")

	bgmstart = love.audio.newSource("audio/bgm-start.wav")
	bgm = love.audio.newSource("audio/bgm.wav")

	gameoversnd = love.audio.newSource("audio/gameover.wav")

	gameFunctions.changeState("title")
end

function love.update(dt)
	--if dt > 0 then
		dt = math.min(1/60, dt)

		if _G[state .. "_update"] then
			_G[state .. "_update"](dt)
		end
--	end
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
	if _G[state .. "_mousepressed"] then
		_G[state .. "_mousepressed"](x, y, button)
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
	return love.graphics.getWidth()
end

function gameFunctions.getHeight()
	return love.graphics.getHeight()
end

function love.focus(f)
	if not f and not gameover then
		paused = true
	end
end