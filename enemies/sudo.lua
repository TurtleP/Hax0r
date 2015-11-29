sudo = class("sudo")

function sudo:init(x, y)
	self.x = x
	self.y = y

	self.width = 14
	self.height = 14

	self.active = true

	self.gravity = 0
	
	self.speedy = 0
	self.speedx = 0

	self.mask =
	{
		
	}

	self.timer = 0
	self.quadi = 1

	self.scanTimer = math.random(4)
	self.doAnimation = false
	self.isAwake = false

	self.scanDuration = math.random(3)

	self.extensions = {t = "system", ext = {".sys", ".dll", ".dat", ".bin"}}
end

function sudo:update(dt)
	if self.isAwake then
		if not self.doAnimation then
			if self.scanTimer > 0 then
				self.scanTimer = self.scanTimer - dt
			else
				self.timer = 0
				self.doAnimation = true
				self.scanTimer = math.random(4)
			end
		else
			if self.scanDuration > 0 then
				self.timer = self.timer + 8 * dt
				self.quadi = 4 + math.floor(self.timer % 4) + 1

				self.scanDuration = self.scanDuration - dt

				if objects["player"][1] then
					local v = objects["player"][1]
					if aabb(self.x, self.y, self.width, self.height * 2, v.x, v.y, v.width, v.height) then
						if #objects["rocket"] == 0 then
							table.insert(objects["rocket"], rocket:new(self.x + (self.width / 2) - 1.5, self.y + (self.height / 2) - 1.5))
						end
					end
				end
			else
				self.doAnimation = false
				self.quadi = 4
				self.scanDuration = math.random(3)
			end
		end
	else
		if self.quadi < 4 then
			self.timer = self.timer + 8 * dt
			self.quadi = math.floor(self.timer % 4) + 1
		else
			self.isAwake = true
		end
	end
end

function sudo:draw()
	love.graphics.draw(sudoimg, sudoquads[self.quadi], self.x, self.y + math.sin(love.timer.getTime() * 2) * 2)
end

function sudo:passiveCollide(name, data)
	if name == "player" then
		if not data.dodging then
			data:takeDamage(-1)
		end
		return false
	end
end	

rocket = class("rocket")

function rocket:init(x, y)
	self.x = x
	self.y = y
	self.width = 3
	self.height = 3

	self.active = true

	self.mask =
	{
		["player"] = true
	}

	self.gravity = 0

	self.speedx = 0
	self.speedy = 0

	if objects["player"][1] then
		self.target = objects["player"][1]
	end

	self.speed = 80
	self.friction = 1
	print("woomy")

	self.smokes = {}

	self.smoketimer = math.random(0.5, 1)

	self.color = {255, 0, 0}

	self.chase = false

	self.starty = y

	self.life = 5
end	

function rocket:update(dt)
	if not self.target then
		self.remove = true
		return
	end
	
	if not self.chase then
		if self.y > self.starty - 32 then
			self.speedy = -40
		else
			self.chase = true
		end

		return
	end
	
	local spinfactor = math.pi/120
	
	local a = math.atan2(self.speedy, self.speedx)
	local a2 = math.atan2((self.target.y + (self.target.height / 2))-self.y, self.target.x-self.x)
	if a < a2 and a2 - a > math.pi then spinfactor = spinfactor * (-1)
	elseif a > a2 and a - a2 <= math.pi then spinfactor = spinfactor * (-1) end
	
	a = a + spinfactor
	if a < 0 then a = a + math.pi*2
	elseif a >= math.pi*2 then a = a - math.pi*2 end
	
	self.speedx = self.speed*math.cos(a)
	self.speedy = self.speed*math.sin(a)
	
	
	if false then --Lazy code removing technique
		if self.target.x > self.x then
			self.speedx = self.speedx + self.speed
		end
		
		if self.target.x < self.x then
			self.speedx = self.speedx - self.speed
		end
		
		if self.target.y + self.target.height / 2 > self.y then
			self.speedy = self.speedy + self.speed
		end
		
		if self.target.y < self.y then
			self.speedy = self.speedy - self.speed
		end
	end
	
	--Do that for all 4 directions
	
	if self.speedx > 0 then
		self.speedx = math.max(0, self.speedx -self.friction)
	end
	
	if self.speedx < 0 then
		self.speedx = math.min(0, self.speedx + self.friction)
	end
	
	if self.speedy < 0 then
		self.speedy = math.min(0, self.speedy + self.friction)
	end
	
	if self.speedy > 0 then
		self.speedy = math.max(0, self.speedy - self.friction)
	end
	--Do that for all 4 directions as well
	
	if self.smoketimer > 0 then
		self.smoketimer = self.smoketimer - dt
	else
		table.insert(self.smokes, {quadi = math.random(3), x = self.x + (self.width / 2) - 3, y = self.y + (self.height / 2) - 3, fade = 1})
		self.smoketimer = math.random(0.5, 1)
	end
	
	for k, v in pairs(self.smokes) do
		if v.fade > 0 then
			v.fade = math.max(v.fade - 0.8 * dt, 0)
		else
			table.remove(self.smokes, k)
		end
	end

	if self.life > 0 then
		self.life = self.life - dt
	else
		game_Explode(self, nil, {255, 0, 0})
		self.remove = true
	end
end

function rocket:draw()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	love.graphics.setColor(255, 255, 255)

	for k, v in pairs(self.smokes) do
		love.graphics.setColor(255, 255, 255, 255 * v.fade)
		love.graphics.draw(smokeimg, smokequads[v.quadi], v.x, v.y)
		love.graphics.setColor(255, 255, 255, 255)
	end
end

function rocket:rightCollide(name, data)
	if name == "player" then

		if not data.dodging then
			table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, nil, -60, -60, false, self.width, self.height, {255, 0, 0}))

			table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, nil, -60, 0, false, self.width, self.height, {255, 0, 0}))

			self.remove = true
			data:takeDamage(-1)
		end
	end
end

function rocket:leftCollide(name, data)
	if name == "player" then

		if not data.dodging then
			table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, nil, 60, -60, false, self.width, self.height, {255, 0, 0}))

			table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, nil, 60, 0, false, self.width, self.height, {255, 0, 0}))

			self.remove = true
			data:takeDamage(-1)
		end
	end
end

function rocket:upCollide(name, data)
	if name == "player" then

		if not data.dodging then
			table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, nil, -60, -60, false, self.width, self.height, {255, 0, 0}))

			table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, nil, 60, -60, false, self.width, self.height, {255, 0, 0}))

			self.remove = true
			data:takeDamage(-1)
		end
	end
end

function rocket:downCollide(name, data)
	if name == "player" then

		if not data.dodging then
			table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, nil, -60, 0, false, self.width, self.height, {255, 0, 0}))

			table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, nil, 60, 0, false, self.width, self.height, {255, 0, 0}))

			data:takeDamage(-1)

			self.remove = true
		end
	end
end

function rocket:passiveCollide(name, data)
	if name == "sudo" and self.chase then
		game_Explode(self, data, {255, 0, 0})

		data.remove = true
		self.remove = true
	end
end