cmd = class("cmd")

function cmd:init(x, y)
	self.x = x
	self.y = y
	self.width = 16
	self.height = 16

	self.mask =
	{
		["tile"] = true,
		["player"] = true
	}

	self.active = true
	self.gravity = 0

	-- 1 or -1
	local dir = {1, -1}

	self.direction = dir[math.random(2)]

	self.speedx = 120 * self.direction
	self.speedy = 0

	self.animation = {1, 2, 3, 4, 5, 4, 3, 2}
	self.timer = 0
	self.quadi = 1

	titlemusic:stop()

	self.name = "PowerCMD"
	self.song = midbossmusic

	self.health = 4
	self.maxhealth = 4

	self.staticy = y

	self.lastSpeed = 0

	self.attackTimer = math.random()
	self.patternTimer = math.random(3, 4)

	self.falling = false

	self.attacks = {"rocket", "shoot"}

	self.extensions = {t = "core", ext = {".exe", ".dll"}}

	self.invincible = false
	self.draws = true
	self.invincibleTimer = 0
	self.fade = 1
	self.fadeout = false

	self.start = true
end

function cmd:update(dt)
	self.timer = self.timer + 8 * dt
	self.quadi = self.animation[math.floor(self.timer % #self.animation) + 1]

	if self.start then
		if self.y + self.height / 2 > gameFunctions.getHeight() * 0.40 then
			self.speedy = -120
		else
			self.staticy = self.y
			self.speedy = 0
			self.start = false
		end
		return
	end

	if not self.falling then
		self.y = self.staticy + math.sin(love.timer.getTime() * 8) * 4
	end

	if objects["player"][1] then
		if self.gravity == 0 then
			local v = objects["player"][1]
			if aabb(self.x, self.y, self.width, 240 - (self.y + self.height), v.x, v.y, v.width, v.height) then
				if self.attackTimer > 0 then
					self.attackTimer = self.attackTimer - dt
				else
					self.lastSpeed = self.speedx
					self.speedx = 0
					self.speedy = 800
					self.gravity = 400
					self.attackTimer = math.random()
					self.falling = true
				end
			else
				if self.patternTimer > 0 then
					self.patternTimer = self.patternTimer - dt
				else
					local pattern = self.attacks[math.random(#self.attacks)]

					if pattern == "rocket" then
						local temp = rocket:new(self.x + self.width / 2, self.y)
						table.insert(objects["rocket"], temp)
					elseif pattern == "shoot" then
						table.insert(objects["rocket"], bullet:new(self.x + self.width / 2, self.y + self.height / 2))
						self.patternTimer = math.random(1, 2)
					end

					self.patternTimer = math.random(3, 4)
				end
			end
		end
	end

	if self.invincible then
		self.invincibleTimer = self.invincibleTimer + 12 * dt

		if math.floor(self.invincibleTimer % 2) == 0 then
			self.draws = false
		else
			self.draws = true
		end

		if self.invincibleTimer > 36 then
			self.draws = true
			self.invincible = false
			self.invincibleTimer = 0
		end
	end

	if self.fadeout then
		self.fade = math.max(self.fade - 0.6 * dt, 0)

		if self.fade == 0 then
			self.y = self.staticy
			self.falling = false
			self.gravity = 0
			self.speedx = self.lastSpeed
			self.speedy = 0

			self.fadeout = false
		end
	else
		if self.fade == 1 then
			return
		end

		self.fade = math.min(self.fade + 0.6 * dt, 1)
	end
end

function cmd:takeDamage()
	if not self.invincible then
		self.health = math.max(self.health - 1, 0)
		self.invincible = true
	end

	if self.health == 0 then
		self:die()
	end
end

function cmd:draw()
	if not self.draws then
		return
	end

	love.graphics.setColor(0, 0, 0, 255 * self.fade)
	love.graphics.circle("fill", self.x + 8, self.y + 8, 8, 64)
	love.graphics.circle("line", self.x + 8, self.y + 8, 8, 64)

	love.graphics.setColor(255, 255, 255, 255 * self.fade)
	love.graphics.draw(cmdimg, cmdquads[self.quadi], self.x, self.y)

	love.graphics.setColor(255, 255, 255, 255)
end

function cmd:upCollide(name, data)
	if name == "player" then
		return false
	end
end

function cmd:downCollide(name, data)
	if name == "player" then
		if self.fade > 0.5 then
			data:takeDamage(-1)
		end
		return false
	end

	if name == "tile" then
		self.fadeout = true
	end
end

function cmd:leftCollide(name, data)
	if name == "player" then
		if self.fade > 0.5 then
			data:takeDamage(-1)
		end
	else
		self.speedx = - self.speedx
	end

	return false
end

function cmd:rightCollide(name, data)
	self.speedx = - self.speedx

	if name == "player" then
		if self.fade > 0.5 then
			data:takeDamage(-1)
		end
	end

	return false
end

function cmd:die()
	self.song:stop()
	self.remove = true
	midbossSong = nil
	endBossSong = love.audio.newSource("audio/boss.wav")
	game_Explode(self, nil, {0, 0, 0})
end