core = class("core")

function core:init(x, y)
	bossspawnsnd:play()
	
	self.x = x
	self.y = y
	self.staticY = y
	self.staticX = x

	self.width = 16
	self.height = 16

	self.active = true
	self.gravity = 0

	local dir = {1, -1}

	self.speed = 140 * dir[math.random(#dir)]
	self.speedx = 0
	self.speedy = 0

	self.mask =
	{
		["tile"] = true,
		["player"] = true
	}

	self.start = false

	self.graphic = cmdimg
	self.quadi = 1

	self.state = "rise"

	self.name = "PowerCore"
	self.health = 6
	self.maxhealth = self.health

	self.timer = 0

	self.fade = 1
	self.otherFade = 1

	self.animation = {1, 2, 3, 4, 5, 4, 3, 2}

	titlemusic:stop()

	endBossSong = love.audio.newSource("audio/boss.ogg")
	
	self.song = endBossSong

	self.attacks = {"dive", "shootcircle", "shoot", "pound", "none"}

	self.attacktimer = math.random(2, 4)
	self.doUpdate = true

	self.shootTime = 0
	self.shootDelay = 0.2
	self.shootMax = 2
	self.shootDuration = 0
	self.attack = "none"
	self.bulletPattern = 0
	self.fixHeight = false

	self.invincible = false
	self.draws = true
	self.invincibleTimer = 0

	self.healthTimer = 0
	self.healthRate = 6
end

function core:update(dt)
	if self.doUpdate then
		self.y = self.staticY + math.sin(love.timer.getTime() * 8) * 6
	end
	
	if not self.start then
		self.fade = math.max(self.fade - 0.6 * dt, 0)

		if self.fade == 0 then
			self.otherFade = math.max(self.otherFade - 0.4 * dt, 0)

			if self.otherFade == 0 then
				self.speedx = self.speed
				self.fade = 1
				self.start = true
			end
		end
		return
	else
		self.timer = self.timer + 8 * dt
		self.quadi = self.animation[math.floor(self.timer % #self.animation) + 1]
	end

	if objects["player"][1] then
		local v = objects["player"][1]
		if v.health > 0 and v.health < 3 then
			if #objects["health"] < 1 then
				if self.healthTimer < self.healthRate then
					self.healthTimer = self.healthTimer + dt
				else
					if math.random(100) <= 10 then
						table.insert(objects["health"], healthitem:new(math.random(2 * 16, 24 * 16), 11 * 16))
					end
					self.healthTimer = 0
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

	if not self.doUpdate then
		if self.fixHeight then
			if self.y > self.staticY then
				self.y = self.y - 160 * dt
			else
				self.speedx = self.speed
				self.fixHeight = false
				self.doUpdate = true
			end
		end
		return
	end
		
	if self.attacktimer > 0 then
		self.attacktimer = self.attacktimer - dt
	else
		if self.attack == "none" then
			self.attack = self.attacks[math.random(#self.attacks)]
		end
		
		local v = objects["player"][1]
		if self.attack == "shootcircle" then
			self:shootCircle()
		elseif self.attack == "shoot" then
			self:shootAtPlayer(dt, v)
		elseif self.attack == "dive" then
			self:dive(dt, v)
		elseif self.attack == "pound" then
			self:pound(dt)
		end
	end
end

function core:takeDamage()
	if not self.invincible then
		self.health = math.max(self.health - 1, 0)
		self.invincible = true
	end

	if self.health == 0 then
		self:die()
	end
end

function core:passiveCollide(name, data)
	if name == "tile" then
		if self.y + self.height > data.y then
			if data.id == "water" then
				self:downCollide(name, data)
			end
		end
	end
end

--CORE'S AI
function core:shootCircle()
	local radial = 
	{
		0, 
		(math.pi * 7) / 4,  
		(math.pi * 5) / 4, 
		(math.pi * 3) / 4,
		(math.pi) / 4,
		(math.pi), 
		(math.pi) / 2,
		(math.pi * 3) / 2,
		(math.pi * 2) / 3,
		(math.pi * 5) / 6,
		(math.pi * 7) / 6,
		(math.pi * 4) / 3,
		(math.pi * 5) / 3,
		(math.pi * 11) / 6,
		(math.pi / 6),
		(math.pi / 3),
		
	}

	for k = 1, #radial do
		table.insert(objects["bullet"], bullet:new(self.x + self.width / 2 - 1, self.y + self.height / 2 - 1, radial[k]))
	end
	
	self.attacktimer = math.random(2, 4)
	self.attack = "none"
end

function core:shootAtPlayer(dt, v)
	self.speedx = 0
	if self.shootDuration < self.shootMax then
		self.shootDuration = self.shootDuration + dt
		if self.shootTime < self.shootDelay then
			self.shootTime = self.shootTime + dt
		else
			table.insert(objects["bullet"], bullet:new(self.x + self.width / 2 - 1, self.y + self.height / 2 - 1))
						
			self.shootTime = 0
		end
	else
		self.shootTime = 0
		self.shootDuration = 0
		
		self.attack = "none"
		self.attacktimer = math.random(2, 4)
		self.speedx = self.speed
	end
end

function core:pound(dt)
	self.speedx = 0
	self.gravity = 600
	self.doUpdate = false
end

function core:dive(dt, v)

	if v.y < self.y then
		self.attacktimer = math.random(2, 4)
		self.attack = "none"
		return
	end

	self.speedx = 0
	self.doUpdate = false
	
	local ang = math.atan2( (v.y + v.height / 2) - self.y + self.height / 2, (v.x + v.width / 2) - self.x + self.width / 2 )

	self.speedx = math.cos(ang) * 140
	self.speedy = math.sin(ang) * 140
end

function core:draw()
	if not self.draws then
		return
	end

	if not self.start then
		love.graphics.draw(coreimg, cmdquads[1], self.x, self.y)
		love.graphics.setColor(255, 255, 255, 255 * self.otherFade)
		love.graphics.draw(cmdimg, cmdquads[1], self.x, self.y)

		love.graphics.setColor(255, 255, 255, 255 * self.fade)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(255, 255, 255, 255)
	else
		love.graphics.setColor(255, 255, 255, 255 * self.fade)
		love.graphics.draw(coreimg, cmdquads[self.quadi], self.x, self.y)
	end
end

function core:die()
	bossdiesnd:play()

	self.song:stop()

	endBossSong = nil

	collectgarbage()
	collectgarbage()

	game_Explode(self, nil, {0, 0, 0})

	self.remove = true

	eventSystem:decrypt(mapScripts[currentScript])
end

function core:upCollide(name, data)
	if name == "player" then
		return false
	end
end

function core:leftCollide(name, data)
	if name ~= "player" then
		self.speedx = -self.speedx
		return false
	else
		if not self.invincible then
			data:takeDamage(-1)
		end
		return false
	end
end

function core:rightCollide(name, data)
	if name ~= "player" then
		self.speedx = -self.speedx
		return false
	else
		if not self.invincible then
			data:takeDamage(-1)
		end
		return false
	end
end

function core:downCollide(name, data)
	if name == "tile" then
		table.insert(objects["laser"], laser:new(self.x + self.width / 2 - 2, self.y + self.height / 2 - 2, -220, 0))
		
		table.insert(objects["laser"], laser:new(self.x + self.width / 2 - 2, self.y + self.height / 2 - 2, 220, 0))
		
		shakeIntensity = 10
		self.fixHeight = true
		self.attack = "none"
		self.attacktimer = math.random(2, 4)
		self.gravity = 0
		self.speedy = 0
	else
		if name == "player" then
			if not self.invincible then
				data:takeDamage(-1)
			end
			return false
		end
	end
end

laser = class("laser")

function laser:init(x, y, speedx, speedy)
	lasersnd:play()

	self.x = x
	self.y = y
	
	self.width = 8
	self.height = 1
	
	self.active = false
	
	self.laserColors = { {229, 62, 50}, {61, 193, 34}, {85, 73, 216} }
	self.timer = 0
	self.colori = 1
	
	self.speedx = speedx
	self.speedy = speedy
	
	self.startTime = 0

	self.lifeTime = 2
end

function laser:update(dt)
	self.timer = self.timer + 8 * dt
	self.colori = math.floor(self.timer % #self.laserColors) + 1
	
	self.x = self.x + self.speedx * dt

	if self.lifeTime > 0 then
		self.lifeTime = self.lifeTime - dt
	else
		self.remove = true
	end
end

function laser:draw()
	love.graphics.setColor(unpack(self.laserColors[self.colori]))
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255)
end