function newBit(x, y)
	local bit = {}

	bit.x = math.random(x - 10, x + 20)
	bit.y = y - 4
	bit.width = 4
	bit.height = 4

	local spd = {-60, 60}

	bit.speedx = 60
	bit.speedy = 0
	bit.gravity = 100

	bit.aiTimer = 0
	bit.aiTimerMax = math.random(0.1, 0.3)
	bit.speed = bit.speedx

	bit.mask = 
	{
		["tile"] = true,
		["player"] = true
	}

	bit.turnAround = {false, false}

	bit.active = true

	function bit:update(dt)
		if self.aiTimer < self.aiTimerMax then
			self.aiTimer = self.aiTimer + dt
		else
			local doSomething = {"jump", "changespeed"}

			local aiThing = doSomething[math.random(#doSomething)]

			if aiThing == "jump" then
				if not self.jumping then
					self.speedy = -50
					self.jumping = true
				else
					self.speedy = 160
				end
			end

			self.aiTimer = 0
			self.aiTimerMax = math.random(1, 2)
		end

		if self.turnAround[1] or self.turnAround[2] then
			if self.turnAround[1] then
				self.speedx = -self.speed
				self.turnAround[1] = false
			else
				self.speedx = self.speed
				self.turnAround[2] = false
			end
		end

		if self.y > gameFunctions.getHeight() then
			self:die()
		end

		self.speedy = self.speedy + self.gravity * dt
		self.x = self.x + self.speedx * dt
		self.y = self.y + self.speedy * dt

		if self.y + self.speedy * dt > 220 then
			self.y = 220
			self.jumping = false
			self.speedy = 0
		end

		if self.x - self.speedx * dt < 0 then
			self.turnAround[2] = true
		elseif self.x + self.width + self.speedx * dt > 320 then
			self.turnAround[1] = true
		end
	end

	function bit:leftCollide(name, data)
		if name == "tile" then
			self.turnAround[2] = true
		end

		if name == "player" then
			return false
		end
	end

	function bit:rightCollide(name, data)
		if name == "tile" then
			self.turnAround[1] = true
		end

		if name == "player" then
			return false
		end
	end

	function bit:downCollide(name, data)
		self.jumping = false

		if name == "player" then
			return false
		end
	end

	function bit:upCollide(name, data)
		if name == "player" then
			return false
		end
	end

	function bit:draw()
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("fill", self.x , self.y , self.width , self.height )
	end

	return bit
end

function newBitBlood(x, y)
	local bitblood = {}

	bitblood.x = x
	bitblood.y = y
	bitblood.width = 2
	bitblood.height = 2
	bitblood.active  = true
	bitblood.gravity = 20

	bitblood.speedx = 0
	bitblood.speedy = 0

	bit.passive = true
	bitblood.mask = {}

	bitsnd[math.random(#bitsnd)]:play()

	local filetypes = {".png", ".zip", ".dll", ".doc", ".txt", ".gif", ".flac", ".exe", ".sys"}

	local s = {}
	for k = 1, 4 do
		s[k] = {x = x, y = y, max = false}
	end

	bitblood.t = filetypes[math.random(#filetypes)]
	bitblood.fade = 1

	function bitblood:update(dt)
		for k = 1, #s do
			if s[k].y > self.y - 20 then
				if not s[k].max then
					s[k].y = s[k].y - 30 * dt
				end
			else
				s[k].max = true
				s[k].y = s[k].y + 30 * dt

				if s[k].y > gameFunctions.getHeight() then
					self.remove = true
				end
			end

			if k < 2 then
				s[k].x = s[k].x - 10 * dt
			else
				s[k].x = s[k].x + 10 * dt
			end
		end

		self.fade = math.max(0, self.fade - dt)
	end

	function bitblood:draw()
		for k = 1, #s do
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle("fill", s[k].x , s[k].y , 2 , 2 )
		end

		love.graphics.setFont(consoleFont)
		love.graphics.setColor(255, 255, 255, 255 * self.fade)
		love.graphics.print(self.t, (self.x + self.width / 2)  - consoleFont:getWidth(self.t) / 2, (self.y + self.height / 2)  - consoleFont:getHeight(self.t) / 2)
	end

	function bitblood:die()
		-- body
	end

	return bitblood
end