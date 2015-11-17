map = class("map")

function map:init(mapData)
	self.objects = {}

	self.objects["firewall"] = {}

	self.objects["player"] = {}
	self.objects["playerdeath"] = {}

	self.objects["tile"] = {}

	self.objects["audioblaster"] = {}
	self.objects["notes"] = {}

	self.objects["paintbird"] = {}
	self.objects["paintdrop"] = {}

	local map = mapData

	playerX, playerY = 0, 0
	for y = 1, #map do
		for x = 1, #map[1] do
			if map[y][x] == 1 then
				self.objects["tile"][x .. "-" .. y] = tile:new((x - 1) * 16, (y - 1) * 16)
			elseif map[y][x] == 3 then
				playerX = (x - 1) * 16
				playerY = (y - 1) * 16
			elseif map[y][x] == 2 then
				table.insert(self.objects["firewall"], firewall:new((x - 1) * 16, (y - 1) * 16))
			elseif map[y][x] == 4 then
				table.insert(self.objects["audioblaster"], audioblaster:new((x - 1) * 16, (y - 1) * 16))
			elseif map[y][x] == 5 then
				self.objects["tile"][x .. "-" .. y] = tile:new((x - 1) * 16, (y - 1) * 16, "water", 5)
			elseif map[y][x] == 6 then
				self.objects["tile"][x .. "-" .. y] = tile:new((x - 1) * 16, (y - 1) * 16, "waterbase")
			elseif map[y][x] == 7 then
				--save point
			elseif map[y][x] == 8 then
				table.insert(self.objects["paintbird"], paintbird:new((x - 1) * 16, (y - 1) * 16))
			end
		end
	end

	if playerX == 0 and playerY == 0 then
		playerX = 0
		playerY = 14 * 16

		self.objects["player"][1] = player:new(playerX, playerY)
	end
end

function map:update(dt)
	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.update then
				w:update(dt)
			end
		end	
	end
end

function map:draw()
	love.graphics.setColor(255, 255, 255)
	for k, v in pairs(self.objects) do
		for j, w in pairs(v) do
			if w.draw then
				w:draw()
			end
		end	
	end
end