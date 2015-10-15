function credits_init()
	creditsy = {}
	for k = 1, #credits do
		creditsy[k] = {gameFunctions.getHeight() + (k - 1) * 24, "bottom"}
	end

	backButton = newButton(5, 5, "Main Menu", function() gameFunctions.changeState("title") end)
end

function credits_update(dt)
	local speed = 40

	for k = 1, #creditsy do
		if creditsy[#creditsy][2] == "top" then
			if creditsy[#creditsy][1] < (gameFunctions.getHeight() / 2 - backgroundFont:getHeight(credits[#credits - 1]) / 2) + backgroundFont:getHeight(credits[#credits - 1]) / 2 then
				speed = 0
			end
		end

		creditsy[k][1] = creditsy[k][1] - speed * dt

		if creditsy[k][1] < -24 and creditsy[k][2] == "bottom" then
			creditsy[k][1] = gameFunctions.getHeight()
			creditsy[k][2] = "top"
		end
	end
end

--local virus = "    +     +  \n++\\+++/+\n++@+++@+\n+++++++++\n++++==+++\n+++++++++"

function credits_draw()
	--love.graphics.setScreen("bottom")

	--love.graphics.setColor(255, 255, 255, 128)
	--love.graphics.print(virus, 5, gameFunctions.getHeight() - 124)

	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.setFont(backgroundFont)
	for k = 1, #credits do
		love.graphics.setScreen(creditsy[k][2])
		love.graphics.print(credits[k], gameFunctions.getWidth() / 2 - backgroundFont:getWidth(credits[k]) / 2, creditsy[k][1])
	end

	love.graphics.setScreen("bottom")
	backButton:draw()
end

function credits_mousepressed(x, y, button)
	backButton:doClick(x, y, button)
end