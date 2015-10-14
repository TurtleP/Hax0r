player = class("player")

function player:init(x, y, fadein)
	self.x = x
	self.y = y
	self.width = 20
	self.height = 33

	self.pointingangle = 0

	self.rightkey = false
	self.upkey = false
	self.downkey = false
	self.leftkey = false

	self.speedx = 0
	self.speedy = 0
	self.active = true
	self.gravity = 400

	self.mask = 
	{
		["tile"] = true,
		["bit"] = true,
		["antivirus"] = true
	}

	playerspawnsnd:play()
	
	self.quads = {}

	for k = 1, 4 do
		self.quads[k] = love.graphics.newQuad((k - 1) * 13, 0, 12, 18, playerimg:getWidth(), playerimg:getHeight())
	end

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

	self.scale = scale
	self.offset = 0

	self.animations =
	{
		["idle"] = {timer = 0, rate = 0.5, frames = {1, 2}},
		["walk"] = {timer = 0, rate = 4, frames = {3, 4, 5, 4}}
	}

	self.crosshair = love.graphics.newImage("graphics/crosshair.png")
	self.angle = 0

	self.animation = "idle"

	circleX, circleY = self.x, self.y
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

	if self.y > gameFunctions.getHeight() then
		self.y = 0
		mapscrolly = mapscrolly + (-12 * 16) * dt
	elseif self.y < 0 then
		self.y = gameFunctions.getHeight()
		mapscrolly = mapscrolly - (12 * 16) * dt
	end

	self.animations[self.animation].timer = self.animations[self.animation].timer + self.animations[self.animation].rate * dt
	self.quadi = self.animations[self.animation].frames[math.floor(self.timer%#self.animations[self.animation].frames)+1]

	self.angle = math.atan2((love.mouse.getY() - 2) - (self.y + self.height / 2) * scale, (love.mouse.getX() - 2) - (self.x + self.width / 2) * scale)
	if love.mouse.isDown("l") then
		objects["bullet"][1] = bullet:new(self.x + self.width / 2, self.y + self.height / 2, self.angle)
	end

	if self.trail then
		self.trail:update(dt)
	end
end

function player:draw()
	love.graphics.setColor(255, 255, 255, 255 * self.fade)
	love.graphics.draw(playerimg, self.x * scale, self.y * scale, 0, self.scale, scale, self.offset)

	love.graphics.draw(self.crosshair, love.mouse.getX() - 2, love.mouse.getY() - 2, 0, scale, scale)

	if self.trail then
		self.trail:draw()
	end
end

function player:moveright(move)
	self.rightkey = move

	if move then
		self.scale = scale
		self.offset = 0
	end
end

function player:moveleft(move)
	self.leftkey = move

	if move then
		self.scale = -scale
		self.offset = self.width
	end
end

function player:dash()
	self.trail = trailmesh:new(self.x * scale, self.y * scale, playerimg, self.width * scale, 0.3, 0.3)
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
	table.insert(objects["digits"], death:new(self.x + self.width / 2 - 4, self.y - 3))
	self.remove = true

	--obviously
	if not win then
		gameover = true
	end
end

death = class("death")

function death:init(x, y)
	local deathn = {}
	local values = {"0", "1"}
	for k = 1, 6 do
		deathn[k] = { x = x , y  = y + (k - 1) * 6 , value = values[love.math.random(#values)], speed = (math.random() * 2 - 1) * 40, timer = 0 }
	end

	self.x = x
	self.y = y 
	self.width = 16
	self.height = 16

	gameoversnd:play()
end

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