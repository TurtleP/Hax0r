function title_init()
	titleUI =
	{
		newButton(gameFunctions.getWidth() / 2 - 82, 70, "New user session", function() gameFunctions.changeState("game") end),
		newButton(gameFunctions.getWidth() / 2 - 82, 112, "View credits", function() gameFunctions.changeState("credits") end),
		newButton(gameFunctions.getWidth() / 2 - 82, 154, "Exit terminal", function() love.event.quit() end)
	}

	for k, v in ipairs(titleUI) do
		v:centerX()
	end

	titleNums = 
	{
		["top"] = {},
		["bottom"] = {}
	}

	makeTitleNums()
end

function title_update(dt)
	for k, j in pairs(titleNums) do
		for i, v in ipairs(j) do
			v[3] = v[3] + v[4] * dt

			if v[3] * 16 > gameFunctions.getHeight() then
				v[3] = 0
			end
		end
	end
end

function title_draw()
	love.graphics.setScreen("top")

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(titleimg, gameFunctions.getWidth() / 2 - 76, gameFunctions.getHeight() / 2 - 18)

	love.graphics.setFont(backgroundFont)
	for k, v in ipairs(titleNums["top"]) do
		love.graphics.setScreen("top")
		love.graphics.setColor(0, 128, 0)
		love.graphics.print(v[1], 5 + (v[2] - 1) * 16, 1 + (v[3] - 1) * 16)
	end

	for k, v in ipairs(titleNums["bottom"]) do
		love.graphics.setScreen("bottom")
		love.graphics.setColor(0, 128, 0)
		love.graphics.print(v[1], 5 + (v[2] - 1) * 16, 1 + (v[3] - 1) * 16)
	end

	love.graphics.setScreen("bottom")

	for k, v in ipairs(titleUI) do
		v:draw()
	end
end

function title_mousepressed(x, y, button)
	for k, v in pairs(titleUI) do
		v:doClick(x, y, button)
	end
end

function makeTitleNums()
	local ops = {"0", "1"}

	for y = 1, 15 do
		for x = 1, 25 do
			table.insert(titleNums["top"], {ops[math.random(1, 2)], x, y, math.random(60)})
		end
	end

	for y = 1, 15 do
		for x = 1, 20 do
			table.insert(titleNums["bottom"], {ops[math.random(1, 2)], x, y, math.random(60)})
		end
	end
end

function newButton(x, y, text, func)
	local button = {}

	button.x = x
	button.y = y
	button.width = buttonFont:getWidth(text) + 8
	button.height = buttonFont:getHeight(text) + 8
	button.text = text
	button.func = func

	function button:draw()
		love.graphics.setFont(buttonFont)

		love.graphics.setColor(255, 255, 255, 235)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

		love.graphics.setColor(54, 54, 54, 235)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

		love.graphics.setColor(255, 255, 255)
		love.graphics.print(self.text, self.x + (self.width / 2) - buttonFont:getWidth(self.text) / 2, self.y + (self.height / 2) - buttonFont:getHeight(self.text) / 2)
	end

	function button:centerX()
		self.x = gameFunctions.getWidth() / 2 - self.width / 2
	end

	function button:inside(x, y)
		return (x > self.x) and (x < self.x + self.width) and (y > self.y) and (y < self.y + self.height)
	end

	function button:doClick(x, y, button)
		if self:inside(x, y) then
			if button == "l" then
				self.func()
			end
		end
	end

	return button
end