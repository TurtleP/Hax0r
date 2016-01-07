--Function hooks/Callbacks
local analogFade = 0
local oldupdate = love.update
function love.update(dt)
	if analogStick then
		if not analogStick:isHeld() then
			analogFade = math.max(analogFade - 0.6 * dt, 0)

			love.keyreleased(controls["up"])
			love.keyreleased(controls["down"])
			love.keyreleased(controls["right"])
			love.keyreleased(controls["left"])
		else
			analogFade = 1
		end

		analogStick.areaColor = {255, 255, 255, 150 * analogFade}
		analogStick.stickColor = {42, 42, 42, 240 * analogFade}
	end

	oldupdate(dt)
	
	touchControls:update(dt)
end

function love.touchpressed(id, x, y, pressure)
	touchControls:touchpressed(id, x, y, pressure)
end

function love.touchreleased(id, x, y, pressure)
	touchControls:touchreleased(id, x, y, pressure)
end

function love.touchmoved(id, x, y, pressure)
	if analogStick:isHeld() then
		analogFade = 1
	end

	analogStick:touchMoved(id, x, y, pressure)
end

touchcontrol = class("touchcontrol")

function touchcontrol:init()
	require 'android/analog'
	require 'android/virtualbutton'

	analogStick = newAnalog(52 * scale, (gameFunctions.getHeight() - 60) * scale, 36 * scale, 12 * scale, 0.5)

	self.buttons =
	{
		virtualbutton:new(gameFunctions.getWidth() - 100, gameFunctions.getHeight() - 60, 20 , "A", controls["jump"], nil, true, true),
		virtualbutton:new(gameFunctions.getWidth() - 40, gameFunctions.getHeight() - 60, 20, "B", controls["dodge"][1], nil, true)
	}
end

function touchcontrol:touchpressed(id, x, y, pressure)
	if state ~= "game" then
		return
	end

	if aabb(gameFunctions.getWidth() - 18, 0, 18, 18, x / scale, y / scale, 8, 8) then
		return
	end

	for k, v in ipairs(self.buttons) do
		v:touchPressed(id, x, y, pressure)

		if aabb(v.boundsX, v.boundsY, v.width, v.height, x / scale, y / scale, 8, 8) then
			return
		end
	end

	if not analogStick:isHeld() then
		analogStick.cx, analogStick.cy = x, y
	else
		analogFade = 1
	end

	analogStick:touchPressed(id, x, y, pressure)
end

function touchcontrol:update(dt)
	if state ~= "game" then
		return
	end

	analogStick:update(dt)

	if not analogStick:isHeld() then
		analogFade = math.max(analogFade - 0.6 * dt, 0)

		love.keyreleased(controls["up"])
		love.keyreleased(controls["down"])
		love.keyreleased(controls["right"])
		love.keyreleased(controls["left"])
	else
		analogFade = 1

		if state == "game" and not paused then
			if analogStick:getX() > 0.5 then
				love.keypressed(controls["right"])
				love.keyreleased(controls["left"])
			end

			if (analogStick:getX() >= 0 and analogStick:getX() <= 0.5) or (analogStick:getX() >= -0.5 and analogStick:getX() <= 0) then
				love.keyreleased(controls["right"])
				love.keyreleased(controls["left"])
			end

			if analogStick:getX() < -0.5 then
				love.keypressed(controls["left"])
				love.keyreleased(controls["right"])
			end

			if (analogStick:getY() >= 0 and analogStick:getY() <= 0.5) or (analogStick:getY() >= -0.5 and analogStick:getY() <= 0) then
				love.keyreleased(controls["up"])
				love.keyreleased(controls["down"])
			end

			if analogStick:getY() > 0.5 then
				love.keypressed(controls["down"])
				love.keyreleased(controls["up"])
			end

			if analogStick:getY() < -0.5 then
				love.keypressed(controls["up"])
				love.keyreleased(controls["down"])
			end

		end
	end
end

function touchcontrol:touchreleased(id, x, y, pressure)
	analogStick:touchReleased(id, x, y, pressure)

	for k, v in ipairs(self.buttons) do
		v:touchReleased(id, x, y, pressure)
	end
end