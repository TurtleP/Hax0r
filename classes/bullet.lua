bullet = class("bullet")

function bullet:init(x, y, ang)
	shootsnd:play()
	
	self.x = x
	self.y = y

	self.width = 2
	self.height = 2

	self.active = true
	self.gravity = 0

	local ply

	if objects["player"][1] then
		ply = objects["player"][1]
	else
		self.remove = true
		return
	end

	self.mask = {}
	
	local angle = ang or math.atan2((ply.y - self.y), (ply.x - self.x))
	self.speedx = math.cos(angle) * 200
	self.speedy = math.sin(angle) * 200
end

function bullet:update(dt)
	if self.y > gameFunctions.getHeight() or self.x + self.width < 0 or self.x > gameFunctions.getWidth() or self.y < 0 then
		self.remove = true
	end
end

function bullet:passiveCollide(name, data)
	if name == "player" then
		data:takeDamage(-1)
		self.remove = true
	end
end

function bullet:draw()
	love.graphics.setColor(255, 255, 0, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255, 255)
end