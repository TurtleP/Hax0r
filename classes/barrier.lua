barrier = class("barrier")

function barrier:init(x, y, w, h)
	self.x = x
	self.y = y
	self.width = w
	self.height = h

	self.speedx = 0
	self.speedy = 0
end

function barrier:draw()
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end