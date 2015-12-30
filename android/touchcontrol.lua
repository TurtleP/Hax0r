touchcontrol = class("touchcontrol")

function touchcontrol:init()
	require 'android/analog'

	analogStick = newAnalog(0, 0, 6, 6, 3)
end

function touchcontrol:touchpressed(x, y, id, pressure)
	analogStick:touchPressed(x, y, id, pressure)
end

function touchcontrol:touchReleased(x, y, id, pressure)
	analogStick:touchreleased(x, y, id, pressure)
end

function love.touchmoved(x, y, id, pressure)
	analogStick:touchMoved(x, y, id, pressure)
end

local analogFade = 0
local oldupdate = love.update
function love.update(dt)
	oldupdate(dt)
	analogStick:update(dt)

	if not analogStick:isHeld() then
		analogFade = math.max(analogFade - 0.6 * dt, 0)
	else
		analogFade = 1
	end
end

local oldDraw = love.draw
function love.draw()
	oldDraw()

	love.graphics.setColor(255, 255, 255, 255 * analogFade)
	analogStick:draw()
	love.graphics.setColor(255, 255, 255, 255)
end

local oldMousePressed = love.mousepressed
function love.mousepressed(x, y, button)
	oldMousePressed(x, y, button)

	analogStick.cx, analogStick.cy = x / scale, y / scale
end