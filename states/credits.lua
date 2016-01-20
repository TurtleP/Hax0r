function credits_init()
	creditsy = {}
	for k = 1, #credits do
		creditsy[k] = {gameFunctions.getHeight() + (k - 1) * 24, "bottom"}
	end
end

function credits_update(dt)
	local speed = 40

	for k = 1, #creditsy do
		creditsy[k][1] = creditsy[k][1] - speed * dt
	end
end

function credits_draw()
	love.graphics.setColor(255, 255, 255, 128)
	love.graphics.draw(hax0r, gameFunctions.getWidth() / 2 - hax0r:getWidth() / 2, gameFunctions.getHeight() / 2 - hax0r:getHeight() / 2)

	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.setFont(consoleFont)
	for k = 1, #credits do
		love.graphics.print(credits[k], gameFunctions.getWidth() / 2 - consoleFont:getWidth(credits[k]) / 2, creditsy[k][1])
	end
end

function credits_mousepressed(x, y, button)
	gameFunctions.changeState("title")
end

function credits_keypressed(key)
	gameFunctions.changeState("title")
end