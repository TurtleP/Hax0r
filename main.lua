
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

require 'states/game'
require 'states/title'
require 'states/win'
require 'states/credits'

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

	playerimg = {}
	for k = 1, 3 do
		playerimg[k] = love.graphics.newImage("graphics/player" .. k .. ".png")
	end

	firewallimg = {}
	for k = 1, 2 do
		firewallimg[k] = love.graphics.newImage("graphics/firewall" .. k .. ".png")
	end

	waterimg = {}
	for k = 1, 6 do
		waterimg[k] = love.graphics.newImage("graphics/sea/" .. k .. ".png")
	end

	waterbaseimg = love.graphics.newImage("graphics/sea/7.png")

	--other
	backgroundFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 16)
	consoleFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 16)

	--maps
	maps = {}
	maps[1] = require "maps/1"
	maps[2] = require "maps/2"
	maps[3] = require "maps/3"

--	maps[4] = require "maps/save"

	gameFunctions.changeState("title")
end

function love.update(dt)
	if dt > 0 then
		dt = math.min(1/60, dt)

		if _G[state .. "_update"] then
			_G[state .. "_update"](dt)
		end
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