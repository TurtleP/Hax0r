function title_init()
	_PLAYERLIVES = 3
	
	titleStrings = 
	{
		function() gameFunctions.changeState("game") end,
		function() gameFunctions.changeState("credits") end, 
		--{"Quit", love.event.quit}, 
		function() end
	}
	
	love.graphics.setBackgroundColor(0, 128, 128)

	titleselectioni = 1
	tapCount = 0
	
	startButton = createStart()
	
	icons = 
	{
		createIcon(16, 16, "Web 95", "web", titleStrings[1]),
		createIcon(16, 88, "My PC", "computer", titleStrings[2]),
	}

	if noData then
		table.remove(icons, 3)
	end

	spawnPlayer = false
	waitTimer = 0

	spawnTimer = math.random(3)
	bitEnemies = {}

	titleMouseX, titleMouseY = nil, nil

	backgroundi = 1
	backgroundtimer =0
end

function title_update(dt)
	if not titlemusic:isPlaying() then
		titlemusic:play()
	end

	backgroundtimer = backgroundtimer + 12 * dt
	backgroundi = math.floor(backgroundtimer % 8) + 1
end

function title_draw()
	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.setScreen("top")
	love.graphics.draw(background[backgroundi], 0, 0)

	love.graphics.setColor(0, 0, 0)
	love.graphics.draw(titleimg, gameFunctions.getWidth() / 2 - titleimg:getWidth() / 2 - 2, gameFunctions.getHeight() / 2 - titleimg:getHeight() / 2 - 2)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(titleimg, gameFunctions.getWidth() / 2 - titleimg:getWidth() / 2, gameFunctions.getHeight() / 2 - titleimg:getHeight() / 2)

	love.graphics.setScreen("bottom")
	
	love.graphics.setColor(168, 168, 168)
	love.graphics.rectangle("line", 0, gameFunctions.getHeight() - 16, gameFunctions.getWidth(), 16)
	
	love.graphics.setColor(192, 192, 192)
	love.graphics.rectangle("fill", 64, gameFunctions.getHeight() - 15, gameFunctions.getWidth() - 64, 15)
	
	love.graphics.setFont(consoleFont)
	
	love.graphics.setColor(145, 145, 145)
	love.graphics.rectangle("line", 64, gameFunctions.getHeight() - 12, 0.5, 10)
	
	startButton:draw()
	
	for k, v in ipairs(icons) do
		v:draw()
	end
end

function title_mousepressed(x, y, button)
	for k, v in pairs(icons) do
		v:click(x, y)
	end

	titleMouseX, titleMouseY = love.mouse.getX(), love.mouse.getY()
end

function title_mousereleased()
	if titleMouseX and titleMouseY then
		for k, v in pairs(icons) do
			v:unclick(titleMouseX, titleMouseY)
		end
	end
end

function title_keypressed(key)
	if key == "b" then
		love.event.quit()
	end
end

function createStart()
	local start = {}
	start.x = 0
	start.y = gameFunctions.getHeight() - 15
	start.width = 64
	start.height = 16
	
	start.open = false
	
	function start:draw()
		local color = {192, 192, 192}
		if self.open then
			
		end
		
		love.graphics.setColor(unpack(color))
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
		
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(sudoimg, sudoquads[3], self.x + 2, (self.y + self.height) - 15)
		
		love.graphics.setColor(0, 0, 0)
		love.graphics.print("start", 22, gameFunctions.getHeight() - consoleFont:getHeight("start") - 2)
		love.graphics.setColor(255, 255, 255)
	end
	
	return start
end

function createIcon(x, y, text, i, func)
	local icon = {}
	
	icon.x = x
	icon.y = y
	icon.width = 32
	icon.height = 32
	
	if i == "web" then
		icon.graphic = love.graphics.newImage("graphics/ieicon.png")
	elseif i == "computer" then
		icon.graphic = computerimg
	else
		icon.graphic = love.graphics.newImage("graphics/documenticon.png")
	end
	
	icon.text = text or ""
	
	icon.i = i

	icon.height = 36
	icon.clickCount = 0
	icon.func = func
	
	function icon:update(dt)
	
	end
	
	function icon:draw()
		local color = {255, 255, 255}
		if self.clickCount > 0 then
			color = {0, 0, 255}
		end
		love.graphics.setColor(unpack(color))
		love.graphics.draw(self.graphic, self.x + self.width / 2 - self.graphic:getWidth() / 2, self.y)

		love.graphics.setColor(0, 0, 0)
		love.graphics.print(self.text, self.x + self.width / 2 - consoleFont:getWidth(self.text) / 2, self.y + self.height)
	end
	
	function icon:click(x, y)
		if x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height then
			self.clickCount = self.clickCount + 1
		end
		
		if self.clickCount > 2 then
			self.func()
		end
	end
	
	function icon:unclick(x, y)
		if self.clickCount > 0 then
			if x > self.x and x < self.x + self.width and y > self.y and y < self.y + self.height then
				self.clickCount = self.clickCount + 1
			else
				self.clickCount = 0
			end
		end
	end
	
	return icon
end