--[[
	Virtual Button

	Makes it so there's buttons to tap
	Fancy stuff. Yeh.
--]]

function newVirtualButton(x, y, r, text, key, backKey, gameOnly)
	local virtualbutton = {}

	virtualbutton.x = x
	virtualbutton.y = y
	virtualbutton.text = text
	virtualbutton.key = key
	virtualbutton.r = r

	virtualbutton.backKeyData = backKey

	virtualbutton.boundsX = x - r
	virtualbutton.boundsY = y - r

	virtualbutton.width = r * 2
	virtualbutton.height = virtualbutton.width

	virtualbutton.gameOnly = gameOnly

	virtualbutton.colors =
	{
		["true"] = {255, 255, 255, 200},
		["false"] = {42, 42, 42, 200}
	}

	virtualbutton.pressed = false

	virtualbutton.id = 0

	local function toboolean(b)
		if type(b) == "string" then
			if b == "true" then
				return true
			end
			return false
		end
	end

	function virtualbutton:setID(id)
		self.id = id + 1
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

		if CheckCollision(self.boundsX, self.boundsY, self.width, self.height, x / scale, y / scale, 8, 8) then
			self.pressed = true

			self:setID(id)

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
			if self.id == id + 1 then
				self.pressed = false
			end
		end
	end

	function virtualbutton:draw()
		if self.gameOnly and state ~= "game" then
			return
		end

		love.graphics.setFont(winFont)

		love.graphics.setColor(self.colors[tostring(self.pressed)])
		love.graphics.circle("fill", self.x * scale, self.y * scale, self.r * scale)

		love.graphics.setColor(self.colors[tostring(not self.pressed)])
		love.graphics.print(self.text, (self.boundsX + self.width / 2) * scale - winFont:getWidth(self.text) / 2, (self.boundsY + self.height / 2) * scale - winFont:getHeight(self.text) / 2)

		--self:debugDraw()
	end

	return virtualbutton
end