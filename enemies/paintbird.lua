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

	self.graphic = 
	{
		["left"] = {love.graphics.newImage("enemies/imageFile.png"), love.graphics.newImage("enemies/imageFile2.png")},
		["right"] = {love.graphics.newImage("enemies/imageFileFlip.png"), love.graphics.newImage("enemies/imageFileFlip2.png")}
	}

	self.quads = {}

	for k = 1, 3 do
		self.quads[k] = love.graphics.newQuad((k - 1) * 19, 0, 18, 13, self.graphic["left"][1]:getWidth(), self.graphic["left"][1]:getHeight())
	end

	self.quadi = 1

	self.timer = 0
	self.maxTimer = 3

	self.hopTimer = 0
	self.animationTimer = 0

	self.direction = "left"

	self.dropTimer = math.random(6)

	self.color = {}
end

function paintbird:update(dt)
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
		table.insert(objects["paintdrop"], paintdrop:new(self.x + (self.width) - 2, self.y + self.height, self, 0, 0, true))
		self.dropTimer = math.random(6)
	end

	self.hopTimer = self.hopTimer + 2 * dt

	self.animationTimer = self.animationTimer + 8 * dt
	self.quadi = math.floor(self.animationTimer % 3) + 1

	self.color = colorfade(self.timer, self.maxTimer, self.currentColor, self.toColor)
end

function paintbird:draw()
	love.graphics.setColor(unpack(self.color))
	love.graphics.draw(self.graphic[self.direction][1], self.quads[self.quadi], self.x, self.y + math.sin(self.hopTimer) * 4)

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.graphic[self.direction][2], self.quads[self.quadi], self.x, self.y + math.sin(self.hopTimer) * 4)
end

function paintbird:leftCollide(name, data)
	if name == "tile" then
		self.speedx = math.random(60, 100)
		self.direction = "right"
		return false
	end
end

function paintbird:rightCollide(name, data)
	if name == "tile" then
		self.speedx = -math.random(60, 100)
		self.direction = "left"
		return false
	end
end

paintdrop = class("paintdrop")

function paintdrop:init(x, y, parent, speedx, speedy, spawnachild)
	self.x = x 
	self.y = y

	self.width = 4
	self.height = 4

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

	self.parent = parent
end

function paintdrop:draw()
	love.graphics.setColor(unpack(self.parent.color))
	love.graphics.rectangle("fill", self.x, self.y, 4, 4)
end

function paintdrop:downCollide(name, data)
	if self.spawnachild then
		table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, self.parent, -60, -60, false))

		table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, self.parent, 60, -60, false))
	end

	self.remove = true
end