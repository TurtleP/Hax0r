document = class("document")

function document:init(x, y)
	self.x = x
	self.y = y

	self.width = 15
	self.height = 16

	self.mask =
	{
		["tile"] = true
	}

	self.active = true

	self.gravity = 300
	self.speedx = 0
	self.speedy = 0

	self.quadi = 1
	self.timer = 0
end

function document:update(dt)
	self.timer = self.timer + 2 * dt
	self.quadi = math.floor(self.timer % 2) + 1
end

function document:draw()
	love.graphics.draw(documentimg, documentquads[self.quadi], self.x, self.y)
end

function document:passiveCollide(name, data)
	if name == "player" then
		if not data.dodging then
			data:takeDamage(-1)
		end
	end
end