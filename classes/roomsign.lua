roomsign = class("roomsign")

function roomsign:init(text)
	self.width = consoleFont:getWidth(text) + 4
	self.height = consoleFont:getHeight(text)

	self.x = 200 - self.width / 2
	self.y = gameFunctions.getHeight()

	

	self.fade = 1

	self.doFade = false
	self.lifeTime = 0
	self.text = text
end

function roomsign:update(dt)
	if self.y > gameFunctions.getHeight() - self.height then
		self.y = self.y - 30 * (dt / 0.4)
	else
		if not self.doFade then
			if self.lifeTime < 2 then
				self.lifeTime = self.lifeTime + dt
			else
				self.doFade = true
				self.lifeTime = 0
			end
		else
			self.fade = math.max(self.fade - dt / 0.8, 0)
		end
	end
end

function roomsign:draw()
	love.graphics.setColor(32, 32, 32, 255 * self.fade)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255, 255 * self.fade)

	love.graphics.print(self.text, self.x + self.width / 2 - consoleFont:getWidth(self.text) / 2, self.y + (self.height / 2) - consoleFont:getHeight(self.text) / 2 - 2)

	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

	love.graphics.setColor(255, 255, 255, 255)
end