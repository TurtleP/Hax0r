function intro_init()
	introTimer = 0
	introfade = 1
	love.graphics.setFont(introFont)
	introtext = "A game by TurtleP"
end

function intro_update(dt)
	if introTimer < 3 then
		introTimer = introTimer + dt
	end

	if introTimer > 1.8 then
		introfade = math.max(introfade - 0.8 * dt, 0)
	end

	if introfade == 0 then
		gameFunctions.changeState("title")
	end
end

function intro_draw()
	love.graphics.setColor(255, 255, 255, 255 * introfade)
	love.graphics.draw(introimg, gameFunctions.getWidth() / 2 - introimg:getWidth() / 2, gameFunctions.getHeight() / 2 - introimg:getHeight() / 2)
	love.graphics.print(introtext, gameFunctions.getWidth() / 2 - introFont:getWidth(introtext) / 2, gameFunctions.getHeight() * 0.75)
end

function intro_mousepressed(x, y, button)
	if introTimer > 0.4 then
		gameFunctions.changeState("title")
	end
end

function intro_keypressed(key)
	if introTimer > 0.4 then
		gameFunctions.changeState("title")
	end
end