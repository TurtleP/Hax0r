function newAntivirus(x, y)
	local av = {}

	av.x = x
	av.y = y

	av.ang = math.atan( (y - objects["player"][1].y) / (x - objects["player"][1].x) )

	local speed = 120
	if x > objects["player"][1].x then
		speed = -120
	end

	av.speedx = math.cos(av.ang) * speed
	av.speedy = math.sin(av.ang) * speed

	av.width = 9
	av.height = 9

	av.active = true
	av.gravity = 0

	av.mask = { ["tile"] = true , ["player"] = true }
	av.quadi = 1
	av.timer = 0

	function av:update(dt)
		self.timer = self.timer + 8 * dt
		self.quadi = math.floor(self.timer%#antivirusquads)+1
	end

	function av:leftCollide(name, data)
		if name == "player" or name == "tile" then
			self:die()
		end
	end

	function av:rightCollide(name, data)
		if name == "player" or name == "tile" then
			self:die()
		end
	end

	function av:upCollide(name, data)
		if name == "player" or name == "tile" then
			self:die()
		end
	end

	function av:downCollide(name, data)
		if name == "player" or name == "tile" then
			self:die()
		end
	end

	function av:die()
		table.insert(objects["explosion"], newExplosion(self.x, self.y))
		self.remove = true
	end

	function av:draw()
		love.graphics.draw(antivirusrocket, antivirusquads[self.quadi], self.x * scale, self.y * scale, 0, scale, scale)
	end

	return av
end

function newExplosion(x, y)
	local explosion = {}

	explosion.x = x
	explosion.y = y
	explosion.width = 9
	explosion.height = 9

	explosionsnd:play()

	explosion.graphic = love.graphics.newImage("graphics/explosion.png")
	explosion.quads = {}
	for k = 1, 16 do
		explosion.quads[k] = love.graphics.newQuad(( k - 1) * 10, 0, 9, 9, explosion.graphic:getWidth(), explosion.graphic:getHeight())
	end

	explosion.timer = 0
	explosion.quadi = 1

	function explosion:update(dt)
		if self.quadi < #self.quads then
			self.timer = self.timer + 12 * dt
			self.quadi = math.floor(self.timer%#self.quads)+1

			tremorX = love.math.random(-10, 10)
			tremorY = love.math.random(-10, 10)
		else
			self.remove = true
		end
	end

	function explosion:draw()
		love.graphics.draw(self.graphic, self.quads[self.quadi], self.x * scale, self.y * scale, 0, scale, scale)
	end

	return explosion
end