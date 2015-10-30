player = class("player")

function player:init(x, y, fadein)
	self.x = x
	self.y = y
	self.width = 16
	self.height = 16

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
		["firewall"] = true,
		["paintbird"] = true,
		["paintdrop"] = true
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

	self.health = 5

	playerspawn:play()
end

function player:update(dt)
	if not self.rightkey and not self.leftkey and not self.downkey and not self.upkey then
		self.speedx = 0
	elseif self.rightkey then
		self.speedx = 60
	elseif self.leftkey then
		self.speedx = -60
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

	if self.x > love.graphics.getWidth() then
		mapscrollx = 25 * 16
		loadMap(currentMap + 1)
	elseif self.x + self.width < 0 then
		mapscrollx = -(25 * 16)
		loadMap(currentMap - 1)
	end
end

function player:draw()
	love.graphics.setColor(255, 255, 255, 255 * self.fade)
	love.graphics.draw(playerimg, playerquads[self.animations[self.quadi]], self.x , self.y )
	love.graphics.setColor(255, 255, 255, 255)
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

		jumpsound:play()

		self.jumping = true
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

	if name == "antivirus" then
		self:die()
	end

	self.jumping = false
end

function player:upCollide(name, data)
	if name == "bit" or name == "proxy" then
		return false
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

	if name == "antivirus" then
		self:die()
	end
end

function player:passiveCollide(name, data)
	if name == "tile" then
		if data.id then
			self:die()
		end
	end
end

function player:die(win)
	table.insert(objects["playerdeath"], death:new(self.x, self.y))

	self.remove = true

	--obviously
	if not win then
		gameover = true
	end
end

death = class("death")

function death:init(x, y)
	self.x = x
	self.y = y 
	self.width = 16
	self.height = 16
	self.timer = 0
	self.quadi = 1

	gameoversnd:play()
end

function death:update(dt)
	if self.quadi < 8 then
		self.timer = self.timer + 8 * dt
		self.quadi = math.floor(self.timer % 8) + 1
	else
		self.remove = true
	end
end

function death:draw()
	for y = 0, math.floor(self.y) do
		love.graphics.draw(deathimg, deathquads[self.quadi], self.x, self.y - (y - 1) * 16)
	end
end