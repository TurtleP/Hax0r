function newHack(x, y)
	local hack = {}

	hack.x = x
	hack.y = y
	hack.width = 20
	hack.height = 3

	hack.passive = true

	return hack
end