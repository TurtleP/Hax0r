function newProxy(x, y)
	local proxy = {}

	proxy.x = x
	proxy.y = y

	local spd = {-40, 40}
	proxy.speed = 50
	proxy.speedy = 0
	proxy.gravity = 0
	proxy.speedx = proxy.speed

	proxy.active = true

	proxy.mask = { ["tile"] = true, ["player"] = true }

	proxy.width = 9
	proxy.height = 9

	proxy.quadi = 1
	proxy.timer = 0

	proxy.intro = true

	proxy.turnAround = {false, false}

	function proxy:update(dt)
		if self.intro then
			if self.quadi < #proxyintroquads then
				self.timer = self.timer + 8 * dt
				self.quadi = math.floor(self.timer%#proxyintroquads)+1
			else
				self.timer = 0
				self.intro = false
				self.quadi = 1
			end
		else
			self.timer = self.timer + 4 * dt
			self.quadi = math.floor(self.timer%#proxyquads)+1
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
	end

	function proxy:upCollide(name, data)
		if name == "player" then
			return false
		end
	end

	function proxy:leftCollide(name, data)
		if name == "tile" then
			self.turnAround[2] = true
		end

		if name == "player" then
			return false
		end
	end	

	function proxy:rightCollide(name, data)
		if name == "tile" then
			self.turnAround[1] = true
		end

		if name == "player" then
			return false
		end
	end

	function proxy:downCollide(name, data)
		if name == "tile" then
			self:die()
		end

		if name == "player" then
			return false
		end
	end

	function proxy:die()
		if not self.intro then
			table.insert(objects["explosion"], newExplosion(self.x, self.y))
			self.remove = true
		end
	end

	function proxy:draw()
		love.graphics.setColor(255, 255, 255, 255)
		if self.intro then
			love.graphics.draw(proxyintro, proxyintroquads[self.quadi], self.x * scale, self.y * scale, 0, scale, scale)
		else
			love.graphics.draw(proxyimg, proxyquads[self.quadi], self.x * scale, self.y * scale, 0, scale, scale)
		end
	end	

	return proxy
end