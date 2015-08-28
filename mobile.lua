mobile = 
{
	analogtimer = 0
}

analog = newAnalog(160, love.window.getHeight() - 180, 100, 50)
pause = newVirtualButton(love.window.getWidth() / gameFunctions.getFullScreenScale() - 30, 20, 16, "||", controls["pause"], nil, true)
mobileDelay = 1/60 --dt

local oldupdate = love.update
function love.update(dt)
	oldupdate(dt)

	if state == "game" then
		analog:update(dt)

		if analog:isHeld() then
			if analog:getX() > 0.5 then
				love.keypressed(controls["right"])
			end

			if analog:getX() >= 0 and analog:getX() <= 0.5 then
				love.keyreleased(controls["right"])
			end

			if analog:getX() < -0.5 then
				love.keypressed(controls["left"])
			end

			if analog:getX() >= -0.5 and analog:getX() <= 0 then
				love.keyreleased(controls["left"])
			end

			if analog:getY() > 0.5 then
				mobile.analogtimer = math.min(mobile.analogtimer + dt, dt)
			end
		else
			love.keyreleased(controls["right"])
			love.keyreleased(controls["left"])
		end
	else
		if not showCredits then
			if mobileDelay > 0 then
				mobileDelay = mobileDelay - dt
			end
		else
			mobileDelay = dt
		end
	end
end

local olddraw = love.draw
function love.draw()
	olddraw()

	if state == "game" then
		analog:draw()
	end

	pause:draw()
end

function love.touchmoved(id, x, y, pressure)
	local x, y = x*love.graphics.getWidth(), y*love.graphics.getHeight()

	if state == "game" then
		analog:touchMoved(id, x, y, pressure)
	end
end

function love.touchpressed(id, x, y, pressure)
	local x, y = x*love.graphics.getWidth(), y*love.graphics.getHeight()

	if state == "game" then
		analog:touchPressed(id, x, y, pressure)
	end

	pause:touchPressed(id, x, y, pressure)

	if pressure > 0.5 then
		if state == "game" then
			if not CheckCollision(pause.boundsX, pause.boundsY, pause.width, pause.height, x / scale, y / scale, 8, 8) and not CheckCollision(analog.cx - analog.size, analog.cy - analog.size, analog.size * 2, analog.size * 2, x / scale, y / scale, 8, 8) and analog.held ~= id then
				if not paused then
					love.keypressed(controls["jump"])
				end
			end

			if paused then
				local canPress = false
				for k = 1, #pauseMenu.items do
					local v = pauseMenu

					local x = (v.x + v.width / 2) - (pauseFont:getWidth(v.items[k]) / scale) / 2
					local y = ((v.y + 20) + (k - 1) * 14)

					

					if CheckCollision(x, y, pauseFont:getWidth(v.items[k]) / scale, pauseFont:getHeight(v.items[k]) / scale, x / scale, y / scale, 8, 8) then
						pauseMenu.itemi = k
					else
						if not CheckCollision(pauseMenu.x, pauseMenu.y, pauseMenu.width, pauseMenu.height, x / scale, y / scale, 8, 8) then
							canPress = true
						end
					end
				end

				if canPress then
					love.keypressed(controls["jump"])
				end
			end
		else
			local canPress = false
			for k = 1, #titleThings do
				local v = titleThings[k][1]

				if CheckCollision(1, (120 + (k - 1) * 14), backgroundFont:getWidth(v) / scale, backgroundFont:getHeight(v) / scale, x / scale, y / scale, 8, 8) then
					menui = k
				else
					if not CheckCollision(0, 120, backgroundFont:getWidth("> " .. titleThings[2][1]) / scale, 162, x / scale, y / scale, 8, 8) then
						canPress = true
					end
				end
			end

			if canPress then
				love.keypressed(controls["jump"])
			end
		end
	end
end

function love.touchreleased(id, x, y, pressure)
	local x, y = x*love.graphics.getWidth(), y*love.graphics.getHeight()

	pause:touchReleased(id, x, y, pressure)
	analog:touchReleased(id, x, y, pressure)
end