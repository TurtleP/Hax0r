firewall = class("firewall")

function firewall:init(x, y)
	self.x = x
	self.y = y
	self.width = 16
	self.height = 16

	self.mask = 
	{
		["player"] = true
	}

	self.speedx = 0
	self.speedy = 0

	self.quadi = 1
	self.animationtimer = 0

	self.fadeout = false
	self.fadeValue = 1
end

function firewall:upCollide(name, data)
	if name == "player" then
		return false
	end
end

function firewall:downCollide(name, data)
	if name == "player" then
		return false
	end
end

function firewall:leftCollide(name, data)
	if name == "player" then
		return false
	end
end

function firewall:rightCollide(name, data)
	if name == "player" then
		return false
	end
end

function firewall:update(dt)
	self.animationtimer = self.animationtimer + 8 *dt
	self.quadi = math.floor(self.animationtimer%2)+1

	if self.fadeout then
		if self.fadeValue > 0 then
			self.fadeValue = math.max(self.fadeValue - dt, 0)
		else
			self.remove = true
		end
	end
end

function firewall:fade()
	self.fadeout = true
end

function firewall:draw()
	love.graphics.setColor(255, 255, 255, 255 * self.fadeValue)
	love.graphics.draw(firewallimg[self.quadi], self.x, self.y, 0, scale, scale)
	love.graphics.setColor(255, 255, 255, 255)
end