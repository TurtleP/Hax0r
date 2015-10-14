function love.load()
	--image filter
	love.graphics.setDefaultFilter("nearest", "nearest")

	--auto require cause lazy
	local luaFiles = love.filesystem.getDirectoryItems("")

	for k = 1, #luaFiles do
		if love.filesystem.isFile(luaFiles[k]) then
			if luaFiles[k] ~= "main.lua" and luaFiles[k] ~= "conf.lua" and luaFiles[k]:sub(-4) == ".lua" then
				require(luaFiles[k]:gsub(".lua", ""))
			end
		end
	end

	--images
	floorTile = love.graphics.newImage("graphics/tile.png")
	floorTileData = love.image.newImageData("graphics/tile.png")
	floorQuads = {}

	for y = 1, floorTile:getHeight() / 17 do
		for x = 1, floorTile:getWidth() / 17 do
			table.insert(floorQuads, love.graphics.newQuad((x - 1) * 17, (y - 1) * 17, 16, 16, floorTile:getWidth(), floorTile:getHeight()))
		end 
	end

	playerimg = love.graphics.newImage("graphics/player.png")

	gameBatch = love.graphics.newSpriteBatch(floorTile, 100)

	antivirusrocket = love.graphics.newImage("graphics/antivirus.png")
	antivirusquads = {}
	for k = 1, 10 do
		antivirusquads[k] = love.graphics.newQuad((k - 1) * 10, 0, 9, 9, antivirusrocket:getWidth(), antivirusrocket:getHeight())
	end
	gameoverimg = love.graphics.newImage("graphics/gameover.png")

	proxyintro = love.graphics.newImage("graphics/proxy_intro.png")
	proxyintroquads = {}
	for k = 1, 9 do
		proxyintroquads[k] = love.graphics.newQuad((k - 1) * 10, 0, 9, 9, proxyintro:getWidth(), proxyintro:getHeight())
	end

	proxyimg = love.graphics.newImage("graphics/proxy.png")
	proxyquads = {}
	for k = 1, 2 do
		proxyquads[k] = love.graphics.newQuad((k - 1) * 10, 0, 9, 7, proxyimg:getWidth(), proxyimg:getHeight())
	end

	firewallimg = love.graphics.newImage("graphics/firewall.png")
	firewallquads = {}
	for k = 1, 8 do
		firewallquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, firewallimg:getWidth(), firewallimg:getHeight())
	end

	--music
	bgm = love.audio.newSource("audio/bgm.ogg")
	bgm:setLooping(true)
	--bgm:play()
	bgm_start = love.audio.newSource("audio/bgm-start.ogg")
	bgm_start:setLooping(true)
	bgm_start:play()
	
	gameoversnd = love.audio.newSource("audio/gameover.ogg")

	hitproxysnd = love.audio.newSource("audio/hitproxy.ogg")
	playerspawnsnd = love.audio.newSource("audio/playerspawn.ogg")

	--sfx
	explosionsnd = love.audio.newSource("audio/explosion.ogg")
	jumpsnd = love.audio.newSource("audio/jump.ogg")
	blipsnd = love.audio.newSource("audio/blip.ogg")

	bitsnd = {love.audio.newSource("audio/bit.ogg"), love.audio.newSource("audio/bit2.ogg"), love.audio.newSource("audio/bit3.ogg")}
	--other
	scale = 2

	currentmap = 1

	backgroundFont = love.graphics.setNewFont("graphics/windows_command_prompt.ttf", 16 * scale)
	consoleFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 8 * scale)
	winFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 12 * scale)

	love.window.setMode(17 * 16 * scale, 12 * 16 * scale)
	love.window.setTitle("Hax0r?")
	love.window.setIcon(love.image.newImageData("graphics/icon.png"))

	gameFunctions.changeState("menu")

	gameMap = { {"H", "&", 0, 1}, {"A", "@", 0, 1}, {"X", "%", 0, 1}, {"0", "#", 0, 1}, {"R", "*", 0, 1}, {"?", "!", 0, 1} }
end

function love.update(dt)
	dt = math.min(1/60, dt)

	if _G[state .. "_update"] then
		_G[state .. "_update"](dt)
	end
end

function love.draw()
	if _G[state .. "_draw"] then
		_G[state .. "_draw"]()
	end
end

function love.keypressed(key)
	if _G[state .. "_keypressed"] then
		_G[state .. "_keypressed"](key)
	end
end

function love.keyreleased(key)
	if _G[state .. "_keyreleased"] then
		_G[state .. "_keyreleased"](key)
	end
end

gameFunctions = {}
function gameFunctions.changeState(newState, ...)
	local arg = {...}

	state = newState

	if _G[state .. "_init"] then
		_G[state .. "_init"](unpack(arg))
	end
end

function gameFunctions.getWidth()
	return 17 * 16
end

function gameFunctions.getHeight()
	return 12 * 16
end

function love.focus(f)
	if not f and not gameover then
		paused = true
	end
end