function newPlayer(x, y, fadein)
	local player = {}

	player.x = x
	player.y = y
	player.width = 16
	player.height = 16

	player.pointingangle = 0

	player.rightkey = false
	player.upkey = false
	player.downkey = false
	player.leftkey = false

	player.speedx = 0
	player.speedy = 0
	player.active = true
	player.gravity = 400

	player.mask = 
	{
		["tile"] = true,
		["bit"] = true,
		["antivirus"] = true
	}

	playerspawnsnd:play()
	
	player.quads = {}

	for k = 1, 4 do
		player.quads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 19, playerimg:getWidth(), playerimg:getHeight())
	end

	player.quadi = 1
	player.timer = 0
	player.rate = 8

	player.fade = 1
	player.fadeOut = false
	player.jumping = false

	player.fadeOut = fadein or false

	if fadein then
		player.fade = 0
	end

	function player:update(dt)
		if not self.rightkey and not self.leftkey and not self.downkey and not self.upkey then
			self.speedx = 0
		elseif self.rightkey then
			self.speedx = 60
		elseif self.leftkey then
			self.speedx = -60
		end

		self.timer = self.timer + self.rate * dt
		self.quadi = math.floor(self.timer%4)+1

		if self.fade ~= 1 then
			self.fade = math.min(1, self.fade + dt)
			self.speedx = 0
			self.speedy = 0
		end
	end

	function player:draw()
		love.graphics.setColor(255, 255, 255, 255 * self.fade)
		love.graphics.draw(playerimg, self.quads[self.quadi], self.x * scale, self.y * scale, 0, scale, scale, 0, 3)
	end

	function player:moveright(move)
		self.rightkey = move
	end

	function player:moveleft(move)
		self.leftkey = move
	end

	function player:jump(shortHop)
		if not self.jumping and not shortHop then
			self.speedy = -160
			self.jumping = true

			if not paused then
				if self.fade == 1 then
					jumpsnd:play()
				end
			end
		else
			if shortHop then
				self.speedy = -120
				self.jumping = true
			end
		end
	end

	function player:downCollide(name, data)
		if name == "bit" or name == "proxy" then
			if self.speedy > 0 then
				self:jump(true)

				if name == "bit" then
					data:die()
				elseif name == "proxy" then
					data.gravity = 180
					hitproxysnd:play()
				end

				combo = combo + 1
			end
			return false
		end

		if name == "firewall" then
			if data.fade == 1 then
				self:die()
			else
				return false
			end
		end

		if name == "antivirus" then
			self:die()
		end

		self.jumping = false
	end

	function player:upCollide(name, data)
		if name == "bit" or name == "proxy" then
			return false
		end

		if name == "firewall" then
			if data.fade == 1 then
				self:die()
			else
				return false
			end
		end
		
		if name == "antivirus" then
			self:die()
		end
	end

	function player:leftCollide(name, data)
		if name == "bit" or name == "proxy" then
			return false
		end

		if name == "tile" then
			if self.speedx < 0 then
				self.speedy = -60
			end
		end

		if name == "firewall" then
			if data.fade == 1 then
				self:die()
			else
				return false
			end
		end

		if name == "antivirus" then
			self:die()
		end
	end

	function player:rightCollide(name, data)
		if name == "bit" or name == "proxy" then
			return false
		end

		if name == "tile" then
			if self.speedx > 0 then
				self.speedy = -60
			end
		end

		if name == "firewall" then
			if data.fade == 1 then
				self:die()
			else
				return false
			end
		end

		if name == "antivirus" then
			self:die()
		end
	end

	function player:die(win)
		table.insert(objects["digits"], newDeath(self.x + self.width / 2 - 4, self.y - 3))
		self.remove = true

		--obviously
		if not win then
			gameover = true
		end
	end

	return player
end

function newDeath(x, y)
	local death = {}

	local deathn = {}
	local values = {"0", "1"}
	for k = 1, 6 do
		deathn[k] = { x = x , y  = y + (k - 1) * 6 , value = values[love.math.random(#values)], speed = (math.random() * 2 - 1) * 40, timer = 0 }
	end

	death.x = x
	death.y = y 
	death.width = 16
	death.height = 16

	gameoversnd:play()

	function death:update(dt)
		for k = 1, #deathn do
			deathn[k].x = deathn[k].x + deathn[k].speed * dt

			if deathn[k].timer < 0.8 then
				deathn[k].timer = deathn[k].timer + dt
				deathn[k].y = deathn[k].y - 30 * dt
			else
				deathn[k].y = deathn[k].y + 30 * dt
			end
		end
	end

	function death:draw()
		love.graphics.setFont(consoleFont)
		for k = 1, #deathn do
			love.graphics.setColor(0, 150, 0)
			love.graphics.print(deathn[k].value, deathn[k].x * scale, deathn[k].y * scale)
		end
	end

	return death
end