healthitem = class("healthitem")

function healthitem:init(x, y)
	self.x = x + 4
	self.y = y
	self.r = 3
	self.seg = 64

	self.active = true

	self.mask =
	{
		["tile"] = true
	}

	self.width = self.r
	self.height = self.r

	self.gravity = 400

	self.speedy = 0
	self.speedx = 0

	self.factor = 0.6

	self.timer = 0

	self.sinr = self.r

	self.currentColor = {0, math.random(100, 255), 0}
	self.nextColor = {0, math.random(100, 255), 0}
	self.timer = 0
end

function healthitem:update(dt)
	if self.timer < 2 then
		self.timer = self.timer + dt
	else
		self.currentColor = self.nextColor
		self.nextColor =  {0, math.random(100, 255), 0}
		self.timer = 0
	end
end

function healthitem:draw()
	love.graphics.setColor(unpack(colorfade(self.timer, 2, self.currentColor, self.nextColor)))
	love.graphics.circle("fill", self.x, self.y, self.r, self.seg)
	love.graphics.circle("line", self.x, self.y, self.r, self.seg)
	love.graphics.setColor(255, 255, 255)
end

function healthitem:downCollide(name, data)
	if name == "tile" then
		if math.floor(self.speedy) > 0 then
			self.speedy = -math.floor(self.speedy * self.factor)
			return false
		end
	end
end

function healthitem:passiveCollide(name, data)
	if name == "player" then
		data:takeDamage(1)
		self.remove = true
	end
end