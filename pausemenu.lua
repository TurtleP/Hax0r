function newPauseMenu()
	local menu = {}

	menu.x = (gameFunctions.getWidth() / 2 - 55)
	menu.y = (gameFunctions.getHeight() / 2 - 30)
	menu.width = 110
	menu.height = 60

	menu.items = 
	{
		"Return to game",
		"Quit to menu",
		"Quit to desktop"
	}

	menu.itemi = 1

	function menu:draw()
		love.graphics.setColor(64, 64, 64)
		love.graphics.rectangle("fill", self.x * scale, self.y * scale, self.width * scale, self.height * scale)

		love.graphics.setColor(128, 128, 128)
		love.graphics.rectangle("line", self.x * scale, self.y * scale, self.width * scale, self.height * scale)

		love.graphics.setColor(255, 255, 255)

		love.graphics.setFont(pauseFont)
		love.graphics.print("Game Paused", (self.x + self.width / 2) * scale - pauseFont:getWidth("Game Paused") / 2, (self.y + 2) * scale)

		for k = 1, #self.items do
			love.graphics.print(self.items[k], (self.x + self.width / 2) * scale - pauseFont:getWidth(self.items[k]) / 2, ((self.y + 20) + (k - 1) * 14) * scale)
		end

		love.graphics.print("> ", (self.x + self.width / 2) * scale - pauseFont:getWidth(self.items[self.itemi]) / 2 - pauseFont:getWidth("> "), ((self.y + 20) + (self.itemi - 1) * 14) * scale)
		love.graphics.print(" <", (self.x + self.width / 2) * scale + pauseFont:getWidth(self.items[self.itemi]) / 2, ((self.y + 20) + (self.itemi - 1) * 14) * scale)
	end

	function menu:keypressed(key)
		if key == controls["down"] then
			self.itemi = math.min(self.itemi + 1, #self.items)
		end

		if key == controls["up"] then
			self.itemi = math.max(self.itemi - 1, 1)
		end

		if key == controls["jump"] then
			if self.itemi == 1 then
				paused = false
			elseif self.itemi == 2 then
				gameFunctions.changeState("title")
			else
				love.event.quit()
			end
		end
	end

	return menu
end