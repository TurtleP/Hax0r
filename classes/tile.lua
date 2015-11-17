tile = class("tile")

function tile:init(x, y, w, h, id)
	self.x = x
	self.y = y

	self.width = w
	self.height = h

	self.speedx = 0
	self.speedy = 0

	self.timer = 0
	self.quadi = 1

	self.id = id

	self.passive = false

	if id == "water" then
		self.graphic = waterimg
		self.passive = true
	elseif id == "waterbase" then
		self.graphic = waterbaseimg
		self.passive = true
	else
		self.graphic = tileimg
	end
end

function tile:update(dt)
	if self.id == "water" then
		self.timer = self.timer + 8 * dt
		self.quadi = math.floor(self.timer % 6) + 1
	else
		return
	end
end

function tile:draw()
	if not self.id then
		for k = 1, self.width / 16 do
			love.graphics.draw(tileimg, self.x + (k - 1) * 16, self.y)
		end
	else
		for k = 1, self.width / 16 do
			if self.id == "water" then
				love.graphics.draw(self.graphic, waterquads[self.quadi], self.x + (k - 1) * 16, self.y)
			else
				love.graphics.draw(self.graphic, self.x + (k - 1) * 16, self.y)
			end
		end
	end
end