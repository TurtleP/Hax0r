webexplore = class("webexplore")

function webexplore:init()
	local pos = {-64, 464}

	self.x = pos[math.random(#pos)]

	if objects["player"][1] then
		self:getStaticY()
	else
		self.y = 0
		self.playerFound = false
	end

	self.width = 16
	self.height = 16

	self.active = true
	self.gravity = 0

	local speed = 50
	self.quadiy = 1
	if self.x > 400 then
		speed = -50
		self.quadiy = 2
	end
	self.originalSpeed = speed

	self.speedx = speed
	self.speedy = 0

	self.mask = 
	{
	}

	self.quadi = 1


	self.timer = 0

	self.sintimer = 0
	self.staticy = self.y

	self.extensions = {t = "web document", ext = {".html", ".htm"}}

	self.freezeTimer = math.random(3)
	self.freezeDuration = math.random(6)
end

function webexplore:update(dt)
	if self.freezeTimer > 0 then
		self.freezeTimer = self.freezeTimer - dt
	else
		self.speedx = 0
		if self.freezeDuration > 0 then
			self.freezeDuration = self.freezeDuration - dt
		else
			self.freezeDuration = math.random(6)
			self.freezeTimer = math.random(3)
			self.speedx = self.originalSpeed
		end
		return
	end

	self.timer = self.timer + 8 * dt
	self.quadi = math.floor(self.timer % 2) + 1

	self.sintimer = self.sintimer + 2 * dt

	self.y = self.staticy + math.sin(self.sintimer) * 8

	if self.staticy == 0 and self.playerFound == false then
		if objects["player"][1] then
			if not self.playerFound then
				self.staticy = self:getStaticY()
				self.playerFound = true
			end
		end
	end

	if self.x + self.width < -64 then
		self:flip()
	elseif self.x > 464 then
		self:flip()
	end
end

function webexplore:draw()
	love.graphics.draw(exploreimg, explorequads[self.quadi][self.quadiy], self.x, self.y)
end

function webexplore:getStaticY()
	if not objects["player"][1] then
		return self.y
	end

	local v = objects["player"][1]
	return math.clamp(math.random(v.y - v.height / 2, v.y + v.height + v.height / 2), 0, love.graphics.getHeight())
end

function webexplore:flip()
	self.speedx = -self.speedx
	self.staticy = self:getStaticY()
	self.originalSpeed = self.speedx
	
	if self.speedx > 0 then
		self.quadiy = 1
		self.x = self.x + 1
	else
		self.quadiy = 2
		self.x = self.x - 1
	end
end

function webexplore:die()
	self.remove = true
end

function webexplore:passiveCollide(name, data)
	if name == "player" then
		if not data.dodging then
			data:takeDamage(-1)
		end
	end
end