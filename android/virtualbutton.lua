--[[
	Virtual Button

	Makes it so there's buttons to tap
	Fancy stuff. Yeh.
--]]

virtualbutton = class("virtualbutton")

function virtualbutton:init(x, y, r, text, key, backKey, gameOnly, releaseOnUntouch)
	self.x = x
	self.y = y
	self.text = text
	self.key = key
	self.r = r

	self.backKeyData = backKey

	self.releaseOnUntouch = releaseOnUntouch

	self.boundsX = x - r
	self.boundsY = y - r

	self.width = r * 2
	self.height = self.width

	self.gameOnly = gameOnly

	self.colors =
	{
		["true"] = {255, 255, 255, 200},
		["false"] = {42, 42, 42, 200}
	}

	self.pressed = false

	self.id = 0
end

local function toboolean(b)
	if type(b) == "string" then
		if b == "true" then
			return true
		end
		return false
	end
end

function virtualbutton:setPos(x, y)
	self.x, self.y = x, y
	self.boundsX = x - self.r
	self.boundsY = y - self.r
end

function virtualbutton:touchPressed(id, x, y, pressure)
	if self.gameOnly and state ~= "game" then
		return
	end

	if aabb(self.boundsX, self.boundsY, self.width, self.height, x / scale, y / scale, 8, 8) then
		self.pressed = true
		self.id = id

		if self.backKeyData and not self.key then
			love.keypressed(self.backKeyData)
		elseif self.key and not self.backKeyData then
			love.keypressed(self.key)
		elseif self.key and self.backKeyData then
			if state ~= "game" or (state == "game" and paused) then
				love.keypressed(self.backKeyData)
			else
				love.keypressed(self.key)
			end
		end
	end
end

function virtualbutton:touchReleased(id, x, y, pressure)
	if self.gameOnly and state ~= "game" then
		return
	end

	if self.pressed then
		if self.id == id then
			if self.releaseOnUntouch then
				love.keyreleased(self.key)
			end
			self.pressed = false
		end
	end
end

function virtualbutton:draw()
	if self.gameOnly and state ~= "game" then
		return
	end

	love.graphics.setFont(introFont)

	love.graphics.setColor(self.colors[tostring(self.pressed)])
	love.graphics.circle("fill", self.x * scale, self.y * scale , self.r * scale)

	love.graphics.setColor(self.colors[tostring(not self.pressed)])
	love.graphics.print(self.text, (self.boundsX + self.width / 2) * scale - (introFont:getWidth(self.text) / 2) * scale, (self.boundsY + self.height / 2) * scale - (introFont:getHeight(self.text) / 2) * scale, 0, scale, scale)
end