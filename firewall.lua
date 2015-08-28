function newFirewall(x, y)
	local wall = {}

	wall.x = x
	wall.y = y
	wall.width = 16
	wall.height = 16

	wall.mask = {}

	wall.speedx = 0
	wall.speedy = 0

	wall.timer = 0
	wall.quadi = 1
	wall.animationtimer = 0
	wall.fade = 0

	function wall:upCollide(name, data)
		if name == "player" then
			return false
		end
	end

	function wall:downCollide(name, data)
		if name == "player" then
			return false
		end
	end

	function wall:leftCollide(name, data)
		if name == "player" then
			return false
		end
	end

	function wall:rightCollide(name, data)
		if name == "player" then
			return false
		end
	end

	function wall:update(dt)
		if self.timer < 6 then
			self.timer = self.timer + dt
		else
			self.remove = true
		end

		self.fade = math.min(self.fade + dt / 2, 1)

		self.animationtimer = self.animationtimer + 8 *dt
		self.quadi = math.floor(self.animationtimer%8)+1
	end

	function wall:draw()
		love.graphics.setColor(255, 255, 255, 255 * self.fade)
		love.graphics.draw(firewallimg, firewallquads[self.quadi], self.x * scale, self.y * scale, 0, scale, scale)
	end

	return wall
end