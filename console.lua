function newConsole(string, color, func)
	local console = {}

	console.x = 2
	console.y = 2
	console.width = gameFunctions.getWidth() - 4
	console.height = 16

	console.delay = 0.04
	console.i = 0
	console.timer = 0
	console.index = 1
	console.string = "user@LudumDare33: " .. string or "user@LudumDare33: "
	console.fade = 1
	console.drawstring = ""

	console.endTimer = 0
	console.stringColor = color or {255, 255, 255}
	
	if func then
		func()
	end

	function console:update(dt)
		if self.i < #self.string then
			if self.timer < self.delay then
				self.timer = self.timer + dt
			else
				hitproxysnd:play()

				local s = self.string
				self.i = self.i + 1
				self.drawstring = self.drawstring .. s:sub(self.i, self.i)

				self.timer = 0
			end
		else
			self.endTimer = self.endTimer + 2 * dt
			self.fade = math.floor(self.endTimer%2)

			if self.endTimer > 4 then
				self.remove = true
			end
		end
	end

	function console:draw()
		love.graphics.setFont(consoleFont)

		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle("fill", self.x * scale, self.y * scale, self.width * scale, self.height * scale)
		love.graphics.setColor(self.stringColor)
	
		love.graphics.print("> " .. self.drawstring, (self.x + 2) * scale, (self.y + self.height / 2) * scale - consoleFont:getHeight(self.drawstring) / 2)

		if self.i == #self.string then
			love.graphics.setColor(self.stringColor[1], self.stringColor[2], self.stringColor[3], 255 * self.fade)
			love.graphics.print("_", (self.x + 2) * scale + consoleFont:getWidth("> " .. self.string), (self.y + self.height / 2) * scale - consoleFont:getHeight(self.string) / 2)
		end

		love.graphics.setFont(backgroundFont)
	end

	return console
end