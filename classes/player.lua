player = class("player")

function player:init(x, y, fadein, health)
	self.x = x
	self.y = y

	self.oldX = x
	self.oldY = y

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
		["document"] = true,
		["boss"] = true,
		["bullet"] = true,
		["laser"] = true,
		["barrier"] = true
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

	self.health = health or 3

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
		["executioner"] = true,
		["boss"] = true,
	}

	self.minJumpHeight = 6
end

function player:respawn()
	self.quadi = 1
	self.dead = false

	self.x = self.oldX
	self.y = self.oldY

	self.health = 3
	playerhealth = self.health

	self.invincible = true
end

function player:update(dt)
	if self.dead then
		self.speedx = 0
		self.speedy = 0

		if self.quadi < 13 then
			self.timer = self.timer + 12 * dt
			self.quadi = math.floor(self.timer % 13) + 1
		else
			if not self.win then
				_PLAYERLIVES = math.max(_PLAYERLIVES - 1, 0)

				if _PLAYERLIVES == 0 then
					gameFunctions.changeState("gameover")
				else
					self:respawn()
				end
			end
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
			table.insert(self.dashes, dash:new(self.x, self.y, math.min(self.quadi, 3)))
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

	if not self.hopping and not self.dodging then
		if self.falling and self.speedy < 0 then
			if self.speedy < self.minJumpHeight then
				self.speedy = self.minJumpHeight
			end
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

	if self.x >= 400 then
		mapFadeOut = true
	end

	for k, v in pairs(self.dashes) do
		v:update(dt)
		if v.remove then
			table.remove(self.dashes, k)
		end
	end

	if self.invincible then
		self.invincibleTimer = self.invincibleTimer + 12 * dt

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
		love.graphics.draw(deathimg, deathquads[self.quadi], self.x , self.y )
		return
	else
		if self.draws then
			love.graphics.setColor(255, 255, 255, 255 * self.fade)
			love.graphics.draw(self.graphic, self.quads[self.animations[self.quadi]], self.x , self.y )
			love.graphics.setColor(255, 255, 255, 255)
		end

		for k, v in pairs(self.dashes) do
			v:draw()
		end
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
	if self.dodging then
		return
	end

	if (not self.jumping or not self.falling) and not shortHop then
		self.speedy = -160

		jumpsound:play()

		self.jumping = true
	elseif self.jumping == "left" then
		self.speedy = -120
		self.speedx = 120
		self.falling = false
		self.jumping = true
	elseif self.jumping == "right" then
		self.speedy = -120
		self.speedx = -120
		self.falling = false
		self.jumping = true
	else
		if shortHop then
			self.speedy = -120
			self.jumping = true
			self.hopping = true
		end
	end
end

function player:stopJump()
	self.falling = true
end

function player:downCollide(name, data)
	if self.dodging then
		if name ~= "tile" then
			return false
		end
	end
	
	if name == "audioblaster" then
		game_Explode(data, nil, {0, 174, 255})
		self:jump(true)
		data.remove = true
		return false
	end

	if name == "notes" then
		return false
	end

	if name == "paintdrop" then
		return false
	end

	if name == "rocket" then
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
		self:jump(true)
		game_Explode(data, nil, {155, 213, 0})
		data.remove = true
		return false
	end

	if name == "boss" then
		if data.fade > 0.5 then
			if not self.invincible then
				self:jump(true)

				if not data.invincible then
					data:takeDamage()
				end

				return false
			end
		end

		if self.invincible or data.invincible then
			return false
		end
	end
	
	if name == "bullet" then
		self:takeDamage(-1)
		data.remove = true
		return false
	end
	
	if name == "laser" then
		self:takeDamage(-1)
		return false
	end

	self.jumping = false
	self.falling = false
	self.canDodge = true
	self.hopping = false
end

function player:upCollide(name, data)
	if name == "bullet" then
		self:takeDamage(-1)
		data.remove = true
		return false
	end
	
	if name == "laser" then
		self:takeDamage(-1)
		return false
	end
	
	if self.enemyList[name] then
		return false
	end
end

function player:leftCollide(name, data)
	if name == "bullet" then
		self:takeDamage(-1)
		data.remove = true
	end
	
	if name == "laser" then
		self:takeDamage(-1)
		return false
	end
	
	if self.enemyList[name] then
		return false
	end

	if name == "tile" then
		if self.speedx < 0 then
			self.jumping = "left"
		end
	end
end

function player:rightCollide(name, data)
	if name == "bullet" then
		self:takeDamage(-1)
		data.remove = true
		return false
	end
	
	if name == "laser" then
		self:takeDamage(-1)
		return false
	end
	
	if self.enemyList[name] then
		return false
	end
	
	if name == "tile" then
		if self.speedx > 0 then
			self.jumping = "right"
		end
	end
end

function player:passiveCollide(name, data)
	if name == "tile" then
		if self.y >= data.y then
			if data.id == "water" then
				self:die()
			end
		end
	end
end

function player:takeDamage(value)
	if not self.dead and not _LOCKPLAYER then
		if not self.invincible then
			if not self.dodging then
				if value < 0 then
					hurtsnd[math.random(#hurtsnd)]:play()
					self.health = math.max(self.health + value, 0)
					self.invincible = true
				end
			end
		end

		if value > 0 then
			lifesnd:play()

			self.health = math.min(self.health + value, 3)
		end

		playerhealth = self.health

		if self.health == 0 then
			self:die()
		end
	end
end

function player:die(win)
	if not self.dead then
		self.win = win

		self.quadi = 1
		self.timer = 0
		deathsnd:play()

		self.dead = true
	end
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