function newTile(x, y, id)
	local tile = {}

	tile.x = x
	tile.y = y

	tile.width = 16
	tile.height = 16

	tile.speedx = 0
	tile.speedy = 0

	gameBatch:add(floorQuads[id], x * scale, y * scale, 0, scale, scale)

	tile.passive = false

	return tile
end