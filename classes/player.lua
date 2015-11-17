player = class("player")

function player:init(x, y, fadein, health)
	self.x = x
	self.y = y
	self.width = 16
	self.height = 16

	self.pointingangle = 0

	self.rightkey = false
	self.leftkey = false
	self.upkey = false
	self.downkey = false

	self.speedx = 0
	self.speedy = 0

	self.active = true
	self.gravity = 400

	self.mask = 
	{
		["tile"] = true,
		["firewall"] = true,
		["paintbird"] = true,
		["paintdrop"] = true,
		["audioblaster"] = true,
		["executioner"] = true,
		["rocket"] = true,
		["webexplorer"] = true,
		["notes"] = true,
		["document"] = true
	}
	
	self.quads = {}

	self.quadi = 1
	self.timer = 0
	self.rate = 8

	self.fade = 1
	self.fadeOut = false
	self.jumping = false

	self.fadeOut = fadein or false

	if fadein then
		self.fade = 0
	end
	
	self.offset = 0

	self.animations =
	{
		1,
		2,
		3,
		2
	}

	self.blinkrand = math.random(4)

	self.shouldAnimate = false

	self.health = health or 5

	self.dodgeValue = false
	self.canDodge = true

	self.dashTimer = 0

	playerspawn:play()

	self.dashes = {}

	self.dodging = false

	self.invincible = false
	self.draws = true
	self.invincibleTimer = 0

	self.deathtimer = 0

	self.graphic = playerimg
	self.quads = playerquads

	self.enemyList =
	{
		["audioblaster"] = true,
		["paintdrop"] = true,
		["paintbird"] = true,
		["sudo"] = true,
		["rocket"] = true,
		["webexplorer"] = true,
		["notes"] = true,
		["document"] = true,
		["executioner"] = true
	}
end

function player:update(dt)
	if self.dead then
		self.speedx = 0
		self.speedy = 0

		if self.quadi < 13 then
			self.timer = self.timer + 12 * dt
			self.quadi = math.floor(self.timer % 13) + 1
		else
			self:die()
		end

		return
	end

	if not self.dodging then
		if not self.rightkey and not self.leftkey and not self.jumping then
			self.speedx = 0
		elseif self.rightkey then
			self.speedx = 80
		elseif self.leftkey then
			self.speedx = -80
		end
	else
		if self.dashTimer < 0.2 then
			self.dashTimer = self.dashTimer + dt
		else
			table.insert(self.dashes, dash:new(self.x, self.y, self.quadi))
			self.dashTimer = 0
		end

		self.gravity = 0

		if self.speedx > 0 then
			self.speedx = math.max(self.speedx - 110 * dt, 0)
		else
			self.speedx = math.min(self.speedx + 110 * dt, 0)
		end

		if self.speedy > 0 then
			self.speedy = math.max(self.speedy - 110 * dt, 0)
		else
			self.speedy = math.min(self.speedy + 110 * dt, 0)
		end

		if self.speedx == 0 and self.speedy == 0 then
			self.gravity = playergravity
			self.dodging = false
		end
	end

	if self.quadi < 4 then
		if self.shouldAnimate then
			self.timer = self.timer + self.rate * dt
			self.quadi = math.floor(self.timer%4)+1
		end
	else
		self.shouldAnimate = false
		self.blinkrand = math.random(4)
		self.quadi = 1
		self.timer = 0
	end

	if self.fade ~= 1 then
		self.fade = math.min(1, self.fade + dt)
		self.speedx = 0
		self.speedy = 0
	end

	if self.blinkrand > 0 then
		self.blinkrand = self.blinkrand - dt
	else
		self.shouldAnimate = true
	end

	if self.x > 400 then
		mapFadeOut = true
	end
	if self.jumping == false then
		self.jumping = true
	end

	for k, v in pairs(self.dashes) do
		if v.remove then
			table.remove(self.dashes, k)
		end
		v:update(dt)
	end

	if self.invincible then
		self.invincibleTimer = self.invincibleTimer + 6 * dt

		if math.floor(self.invincibleTimer%2) ~= 0 then
			self.draws = false
		else
			self.draws = true
		end

		if self.invincibleTimer > 18 then
			self.invincibleTimer = 0
			self.invincible = false
		end
	end
end

function player:draw()
	if self.dead then
		love.graphics.draw(self.graphic, self.quads[self.quadi], self.x , self.y )
		return
	end

	if self.draws then
		love.graphics.setColor(255, 255, 255, 255 * self.fade)
		love.graphics.draw(self.graphic, self.quads[self.animations[self.quadi]], self.x , self.y )
		love.graphics.setColor(255, 255, 255, 255)
	end

	for k, v in pairs(self.dashes) do
		v:draw()
	end

	love.graphics.setColor(255, 255, 255, 255)
end

function player:moveright(move)
	self.rightkey = move
end

function player:moveleft(move)
	self.leftkey = move
end

function player:moveup(move)
	self.upkey = move
end

function player:movedown(move)
	self.downkey = move
end

function player:dodge()
	if self.canDodge then
		local left, right, up, down = self.leftkey, self.rightkey, self.upkey, self.downkey
		local speed = 80
		local x, y = 0, 0

		if right then
			if down then
				y = speed
			elseif up then
				y = -speed
			else
				y = 0
			end
			x = speed
		elseif left then
			if down then
				y = speed
			elseif up then
				y = -speed
			else
				y = 0
			end
			x = -speed
		elseif up then
			if right then
				x = speed
			elseif left then
				x = -speed
			else
				x = 0
			end
			y = -speed
		elseif down then
			if right then
				x = speed
			elseif left then
				x = -speed
			else
				x = 0
			end
			y = speed
		else
			return
		end

		self.speedx = x
		self.speedy = y

		self.dodging = true
		self.canDodge = false
	end
end

function player:jump(shortHop)
	if self.jumping == false and not shortHop then
		self.speedy = -160

		jumpsound:play()

		self.jumping = true
	elseif self.jumping == "left" then
		self.speedy = -120
		self.speedx = 120
		self.jumping = true
		print("Left wall jump")
	elseif self.jumping == "right" then
		self.speedy = -120
		self.speedx = -120
		self.jumping = true
		print("Right wall jump")
	else
		if shortHop then
			self.speedy = -120
			self.jumping = true
		end
	end
end

function player:downCollide(name, data)
	if self.dodging then
		return false
	end
	
	if name == "audioblaster" then
		game_Explode(data, nil, {0, 174, 255})
		self:jump(true)
		data.remove = true
		return false
	end

	if name == "paintbird" then
		data:stomp()
		self:jump(true)
		return false
	end

	if name == "webexplorer" then
		if data.freezeTimer == 0 and data.freezeDuration > 0 then
			return false
		end
		self:jump(true)
		game_Explode(data, nil, {103, 180, 188})
		data:die()
		return false
	end

	if name == "executioner" then
		if data.fade > 0.5 and data.quadi ~= 3 then
			self:jump(true)
			game_Explode(data, nil, {32, 32, 32})
			data.remove = true
		end
		return false
	end

	if name == "document" then
		game_Explode(data, nil, {155, 213, 0})
		self:jump(true)
		data.remove = true
		return false
	end

	self.jumping = false
	self.canDodge = true
end

function player:upCollide(name, data)
	if self.enemyList[name] then
		return false
	end
end

function player:leftCollide(name, data)
	if name == "tile" then
		if self.speedx < 0 then
			self.speedy = -60
			self.jumping = "left"
		end
	end

	if self.enemyList[name] then
		return false
	end
end

function player:rightCollide(name, data)
	if name == "tile" then
		if self.speedx > 0 then
			self.speedy = -60
			self.jumping = "right"
		end
	end

	if self.enemyList[name] then
		return false
	end
end

function player:passiveCollide(name, data)
	if name == "tile" then
		if self.y > data.y then
			if data.id == "water" then
				self:die()
			end
		end
	end
end

function player:takeDamage(value)
	if not self.dead then
		if not self.invincible then
			if self.dodging then
				return
			end

			self.health = math.max(self.health + value, 0)
		
			if value < 0 then
				self.invincible = true
			end

			playerhealth = self.health
		end

		if self.health == 0 then
			self.quadi = 1
			self.graphic = deathimg
			self.quads = deathquads
			self.timer = 0
			deathsnd:play()
			self.dead = true
		end
	end
end

function player:setPosition(x, y)
	self.x = x
	self.y = y
end

function player:die(win)
	--obviously
	if not win then
		gameover = true
		mapFadeOut = true
	end

	self.remove = true
end

dash = class("dash")

function dash:init(x, y, i)
	self.x = x
	self.y = y
	self.fade = 0.5
	self.quadi = i
end

function dash:update(dt)
	if self.fade > 0 then
		self.fade = math.max(self.fade - 0.6 * dt, 0)
	else
		self.remove = true
	end
end

function dash:draw()
	love.graphics.setColor(255, 255, 255, 255 * self.fade)
	love.graphics.draw(playerimg, playerquads[self.quadi], self.x, self.y)
end