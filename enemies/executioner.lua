executioner = class("executioner")

function executioner:init(x, y)
	self.x = x
	self.y = y

	self.width = 16
	self.height = 21

	self.mask =
	{
		["tile"] = true,
	}

	self.active = true

	self.gravity = 300
	self.speedy = 0
	self.speedx = 0

	self.graphic = executionerimg
	self.quads = executionerquads

	self.quadi = 3
	self.timer = 0

	self.direction = 1

	self.shakeTimer = 0
	self.fade = 0

	self.checkTimer = 0

	self.attack = false
	self.extensions = {t = "executable", ext = {".exe", ".msi"}}
	self.timer = 0

	self.particles = {}

	self.particleTimer = 0
	self.finishTimer = 2
end

function executioner:update(dt)
	if self.attack then
		self.fade = math.min(self.fade + 0.6 * dt, 1)

		if self.fade == 1 then
			if self.quadi < 5 then
				self.timer = self.timer + 6 * dt
				self.quadi = 3 + math.floor(self.timer % 2) + 1
			else
				self.attack = false
			end
		end
	end

	if not self.attack and self.fade > 0 then
		if self.finishTimer > 0 then
			self.finishTimer = math.max(self.finishTimer - dt, 0)
		end

		if self.finishTimer == 0 then
			self.fade = math.max(self.fade - 0.6 * dt, 0)
			
			if self.fade == 0 then
				self.quadi = 3
				self.finishTimer = 2
			end
		end
	end

	if self.particleTimer < 0.1 then
		self.particleTimer = self.particleTimer + dt
	else
		if #self.particles < 10 then
			table.insert(self.particles, exeparticle:new(math.random(self.x, self.x + self.width), self.y + self.height))
		end
		self.particleTimer = 0
	end

	for k, v in pairs(self.particles) do
		if v.remove then
			table.remove(self.particles, k)
		end
		v:update(dt)
	end
end

function executioner:draw()
	love.graphics.push()

	love.graphics.translate(0, -8)

	love.graphics.setColor(255, 255, 255, 255 * self.fade)
	love.graphics.draw(self.graphic[self.direction], self.quads[self.quadi], self.x, self.y)
	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.pop()

	for k, v in pairs(self.particles) do
		v:draw()
	end
end

function executioner:passiveCollide(name, data)
	if name == "player" and not data.dodging then
		if data.x + data.width / 2 < self.x + self.width / 2 then
			self.direction = 1
		else
			self.direction = 2
		end
		self.attack = true

		if self.quadi == 5 then
			data:takeDamage(-2)
		end
	end
end

exeparticle = class("exeparticle")

function exeparticle:init(x, y)
	self.x = x 
	self.y = y

	self.width = 1
	self.height = 1

	local c = math.random(0, 64)
	self.color = {c, c, c}
	self.lifeTime = 0
end

function exeparticle:update(dt)
	if self.lifeTime < 1 then
		self.lifeTime = self.lifeTime + dt
		self.y = self.y - 6 * dt
	else
		self.remove = true
	end
end

function exeparticle:draw()
	love.graphics.setColor(unpack(self.color))
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255)
end