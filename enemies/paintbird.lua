paintbird = class("paintbird")

function paintbird:init(x, y)
	self.x = x
	self.y = y

	self.width = 18
	self.height = 13

	self.speedx = -math.random(60, 100)
	self.speedy = 0

	self.currentColor = {math.random(255), math.random(255), math.random(255)}
	self.toColor = {math.random(255), math.random(255), math.random(255)}

	self.active = true
	self.gravity = 0

	self.mask =
	{
		["tile"] = true,
		["player"] = true
	}

	self.graphic = paintbirdimg

	self.quads = paintbirdquads
	

	self.quadi = 1

	self.timer = 0
	self.maxTimer = 3

	self.hopTimer = 0
	self.animationTimer = 0

	self.direction = "left"

	self.dropTimer = math.random(6)

	self.color = {255, 255, 255}

	self.extensions = {t = "image", ext = {".png", ".bmp", ".jpg", ".gif", ".tif", ".tga"}}
end

function paintbird:update(dt)
	if not self.stomped then
		if self.timer < self.maxTimer then
			self.timer = self.timer + dt
		else
			self.currentColor = self.toColor
			self.toColor = {math.random(255), math.random(255), math.random(255)}
			self.timer = 0
		end

		if self.dropTimer > 0 then
			self.dropTimer = self.dropTimer - dt
		else
			table.insert(objects["paintdrop"], paintdrop:new(self.x + (self.width) - 2, self.y + self.height, self, 0, 0, true, nil, nil, true))
			self.dropTimer = math.random(6)
		end

		self.hopTimer = self.hopTimer + 2 * dt

		self.animationTimer = self.animationTimer + 8 * dt
		self.quadi = math.floor(self.animationTimer % 3) + 1

		self.color = colorfade(self.timer, self.maxTimer, self.currentColor, self.toColor)
	end
end

function paintbird:draw()
	love.graphics.setColor(unpack(self.color))
	love.graphics.draw(self.graphic[self.direction][1], self.quads[self.quadi], self.x, self.y + math.sin(self.hopTimer) * 4)

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.graphic[self.direction][2], self.quads[self.quadi], self.x, self.y + math.sin(self.hopTimer) * 4)
end

function paintbird:stomp()
	self.active = true
	self.gravity = 300
end

function paintbird:leftCollide(name, data)
	if name == "tile" then
		self.speedx = math.random(60, 100)
		self.direction = "right"
		return false
	end

	if name == "player" then
		if not data.dodging then
			data:takeDamage(-1)
		end
		return false
	end
end

function paintbird:rightCollide(name, data)
	if name == "tile" then
		self.speedx = -math.random(60, 100)
		self.direction = "left"
		return false
	end

	if name == "player" then
		if not data.dodging then
			data:takeDamage(-1)
		end
		return false
	end
end

function paintbird:downCollide(name, data)
	if name == "tile" then
		self.remove = true
		game_Explode(self, nil, self.color)
	end

	if name == "player" then
		if not data.dodging then
			data:takeDamage(-1)
		end
		return false
	end
end

function paintbird:upCollide(name, data)
	if name == "player" then
		return false
	end
end

function paintbird:passiveCollide(name, data)
	if name == "tile" then
		if data.passive then
			self.remove = true
			game_Explode(self, nil, self.color)
		end
	end
end

paintdrop = class("paintdrop")

function paintdrop:init(x, y, parent, speedx, speedy, spawnachild, width, height, color, doDamage)
	self.x = x 
	self.y = y

	self.width = width or 4
	self.height = height or 4

	self.active = true

	self.speedx = speedx or 0
	self.speedy = speedy or 0

	self.gravity = 300

	self.mask =
	{
		["tile"] = true,
		["player"] = true
	}

	self.spawnachild = spawnachild

	self.color = color or {255, 255, 255}
	self.parent = parent

	local damage = -1
	if not doDamage and not parent then
		damage = 0
	end
	self.damage = damage
end

function paintdrop:draw()
	local color = {255, 255, 255}
	if self.parent then
		color = self.parent.color
	else
		color = self.color
	end

	love.graphics.setColor(unpack(color))
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255)
end

function paintdrop:downCollide(name, data)
	if self.spawnachild then
		table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, self.parent, -60, -60, false))

		table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, self.parent, 60, -60, false))
	end

	if name == "player" then
		if not data.dodging then
			data:takeDamage(self.damage)
		end
		return false
	end

	self.remove = true
end

function paintdrop:rightCollide(name, data)
	if name == "player" then
		if not data.dodging then
			data:takeDamage(self.damage)
			self.remove = true
		end
		return false
	end
end

function paintdrop:upCollide(name, data)
	if name == "player" then
		if not data.dodging then
			data:takeDamage(self.damage)
			self.remove = true
		end
		return false
	end
end

function paintdrop:leftCollide(name, data)
	if name == "player" then
		if not data.dodging then
			data:takeDamage(self.damage)
			self.remove = true
		end
		return false
	end
end