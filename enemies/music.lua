audioblaster = class("audioblaster")

function audioblaster:init(x, y)
	self.x = x
	self.y = y

	self.width = 16
	self.height = 13

	self.active = true
	self.gravity = 300

	self.speedy = 0
	self.speedx = 0

	self.mask =
	{
		["player"] = true,
		["tile"] = true
	}

	self.graphic = love.graphics.newImage("enemies/musicFile.png")
	self.quads = {}

	for k = 1, 3 do
		self.quads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 13, self.graphic:getWidth(), self.graphic:getHeight())
	end

	self.timer = 0
	self.quadi = 1

	self.attacktimer = math.random(4)
	self.shakeValue = 0

	self.insertTimer = 0
end

function audioblaster:update(dt)
	self.timer = self.timer + 8 * dt
	self.quadi = math.floor(self.timer % 2) + 1

	if self.attacktimer > 0 then
		self.attacktimer = self.attacktimer - dt
	else
		if self.shakeValue < 2 then
			self.shakeValue = self.shakeValue + dt

			--ayy lmao
			if self.insertTimer < 0.5 then
				self.insertTimer = self.insertTimer + dt
			else
				table.insert(objects["notes"], musicnote:new(self.x + (self.width / 2) - 5, self.y, math.random(2), math.random(2)))
				self.insertTimer = 0
			end
		else
			self.attacktimer = math.random(4)
			self.shakeValue = 0
			self.insertTimer = 0
		end
	end
end

function audioblaster:draw()
	love.graphics.draw(self.graphic, self.quads[self.quadi], self.x + math.cos(self.shakeValue * 16), self.y)
end

musicnote = class("musicnote")

function musicnote:init(x, y, i, dir)
	self.x = x
	self.y = y

	self.quadi = i

	if i == 1 then
		self.width = 6
	else
		self.width = 4
	end

	self.height = 8

	self.active = true
	self.gravity = 300
	self.mask =
	{
		["player"] = true
	}

	self.speedy = -60

	if dir == 1 then
		self.speedx = -60
	else
		self.speedx = 60
	end

	self.graphic = love.graphics.newImage("enemies/notes.png")

	self.quads = {}
	for k = 1, 2 do
		self.quads[k] = love.graphics.newQuad((k - 1) * 7, 0, 6, 8, self.graphic:getWidth(), self.graphic:getHeight())
	end
end

function musicnote:update(dt)
	if self.y > love.graphics.getHeight() then
		self.remove = true
	end
end

function musicnote:upCollide(name, data)
	if name == "player" then
		self.remove = true
	end
end

function musicnote:downCollide(name, data)
	if name == "player" then
		self.remove = true
	end
end

function musicnote:rightCollide(name, data)
	if name == "player" then
		self.remove = true
	end
end

function musicnote:leftCollide(name, data)
	if name == "player" then
		self.remove = true
	end
end

function musicnote:draw()
	love.graphics.draw(self.graphic, self.quads[self.quadi], self.x, self.y)
end