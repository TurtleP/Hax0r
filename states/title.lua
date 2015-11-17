function title_init()
	titleStrings = 
	{
		{"New game", function() gameFunctions.changeState("game") end},
		{"View credits", function() gameFunctions.changeState("credits") end}, 
		{"Quit", love.event.quit}, 
		{"Delete save data", function() end}
	}

	if not io.open("sdmc:/3ds/Hax0r/save.txt") then
		noData = true
	else
		titleStrings[1] = "Continue game"
	end
	
	love.graphics.setBackgroundColor(63, 80, 87)

	titleselectioni = 1
	tapCount = 0
	
	myDock = createDock()
end

function title_update(dt)
	if not titlemusic:isPlaying() then
		titlemusic:play()
	end
end

function title_draw()
	love.graphics.setScreen("top")
	
	love.graphics.setColor(53, 68, 73)
	love.graphics.rectangle("fill", 0, 0, gameFunctions.getWidth(), 18)
	
	love.graphics.setColor(87, 111, 119)
	love.graphics.rectangle("fill", 20 + consoleFont:getWidth("Applications"), 0, 1, 18)
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(appsicon, 2, 2)
	love.graphics.print("Applications", 18, 0)
	
	love.graphics.print(os.date("%H : %M"), gameFunctions.getWidth() - consoleFont:getWidth(os.date("%H : %M")) - 2, 2)
	
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.draw(titleimg, gameFunctions.getWidth() / 2 - 76, gameFunctions.getHeight() / 2 - 18)
	
	love.graphics.setScreen("bottom")

	myDock:draw()
end

function title_mousepressed(x, y, button)
	myDock:click(x, y)
	
	--[[for k = 1, #titleStrings do
		if aabb(x, y, 2, 2, 10 + (k - 1) * 36, love.graphics.getHeight() - 32, 32, 32) then
			titleselectioni = k
			tapCount = 1
		else
			tapCount = 0
		end
	end
	
	if tapCount == 1 then
		if aabb(x, y, 2, 2, 10 + (titleselectioni - 1) * 36, love.graphics.getHeight() - 32, 32, 32) then
			titleStrings[titleselectioni][2]()
		end
	end]]
end

function title_keypressed(key)
	myDock:keypressed(key)
	
	if key == "b" then
		love.event.quit()
	end
end

function createDock()
	local dock = {}
	
	dock.x = 80
	dock.y = love.graphics.getHeight() - 32
	dock.width = 160
	dock.height = 32
	dock.buttons = {}
	
	for k = 1, 4 do
		dock.buttons[k] = createButton(dock.x + 10 + (k - 1) * 36, dock.y, k, titleStrings[k][1], titleStrings[k][2])
	end
	
	function dock:draw()
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.rectangle("fill", self.x, self.y, 8, self.height)

		love.graphics.setColor(32, 32, 32, 128)
		love.graphics.rectangle("fill", self.x + 8, self.y, self.width - 16, self.height)

		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.rectangle("fill", self.x + self.width - 8, self.y, 8, self.height)
		
		--icons
		love.graphics.setFont(consoleFont)

		for k = 1, 4 do
			self.buttons[k]:draw()
		end
	end
	
	function dock:click(x, y)
		for k, v in pairs(self.buttons) do
			v:click(x, y)
		end
	end
	
	function dock:keypressed(key)
		self.buttons[titleselectioni].selected = false
		if key == "cpadleft" or key == "dleft" then
			titleselectioni = titleselectioni - 1
			
			if noData then
				if titleselectioni < 1 then
					titleselectioni = 3
				end
			else
				if titleselectioni < 1 then
					titleselectioni = #titleStrings
				end
			end
		elseif key == "cpadright" or key == "dright" then
			self.buttons[titleselectioni].selected = false
			titleselectioni = titleselectioni + 1
			
			if noData then
				if titleselectioni > #titleStrings - 1 then
					titleselectioni = 1
				end
			else
				if titleselectioni > #titleStrings then
					titleselectioni = 1
				end
			end
		end

		self.buttons[titleselectioni].selected = true
		
		if key == "start" or key == "a" then
			self.buttons[titleselectioni].func()
		end
	end
	
	return dock
end

function createButton(x, y, i, t, f)
	local button = {}
	
	button.x = x
	button.y = y
	button.width = 32
	button.height = 32
	button.func = f
	button.selected = false
	button.i = i
	button.text = t 
	
	function button:draw()
		love.graphics.draw(dockimg, dockquads[self.i], self.x, self.y)
		
		local v = self.text
		if self.selected then
			love.graphics.setColor(64, 64, 64)
			love.graphics.rectangle("fill", self.x + (self.width / 2) - consoleFont:getWidth(v) / 2 - 2, self.y - 34, consoleFont:getWidth(v) + 4, 20)

			love.graphics.setColor(255, 255, 255)
			love.graphics.print(v, self.x + (self.width / 2) - consoleFont:getWidth(v) / 2, self.y - 32)

			love.graphics.draw(dockbottomimg, self.x + (self.width / 2) - dockbottomimg:getWidth() / 2, self.y - 14)
		end
	end
	
	function button:click(x, y)
		if aabb(x, y, 2, 2, self.x, self.y, self.width, self.height) then
			if noData and self.i == 4 then
				myDock.buttons[titleselectioni].selected = true
				return
			end
		
			titleselectioni = self.i
			self.selected = true
		else
			self.selected = false
		end
		
		if self.selected then
			self.func()
		end
	end
	
	return button
end