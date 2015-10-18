tile = class("tile")

function tile:init(x, y, id, background)
	self.x = x
	self.y = y

	self.width = 16
	self.height = 16

	self.speedx = 0
	self.speedy = 0

	self.passive = false
end

function tile:draw()
	love.graphics.draw(tileimg, self.x, self.y)
end