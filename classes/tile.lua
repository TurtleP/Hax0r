tile = class("tile")

function tile:init(x, y, id, background)
	self.x = x
	self.y = y

	self.width = 16
	self.height = 16

	self.speedx = 0
	self.speedy = 0

	gameBatch:add(tilequads[id][love.math.random(4)], self.x * scale, self.y * scale, 0, scale, scale)

	self.passive = false

	if background then
		gameBatch:add(tilequads[id][love.math.random(5, 8)], self.x * scale, self.y * scale, 0, scale, scale)
		self.passive = true
	end
end