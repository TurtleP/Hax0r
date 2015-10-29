tile = class("tile")

function tile:init(x, y, id)
	self.x = x
	self.y = y

	self.width = 16
	self.height = 16

	self.speedx = 0
	self.speedy = 0

	self.passive = false

	self.timer = 0
	self.quadi = 1

	if id then
		self.id = id

		self.graphic = _G[id .. "img"]
	end
end

function tile:update(dt)
	if self.id then
		if self.id == "water" then
			self.timer = self.timer + 8 * dt
			self.quadi = math.floor(self.timer % 6) + 1
		end
	end
end

function tile:draw()
	if not self.id then
		love.graphics.draw(tileimg, self.x, self.y)
	else
		if type(self.graphic) == "table" then
			love.graphics.draw(self.graphic[self.quadi], self.x, self.y)
		else
			love.graphics.draw(self.graphic, self.x, self.y)
		end
	end
end