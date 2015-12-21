class = require 'libraries/middleclass'

require 'data'

require 'classes/console'
require 'classes/pausemenu'
require 'classes/player'
require 'classes/tile'
require 'classes/antivirus'
require 'classes/bitenemy'
require 'classes/firewall'
require 'classes/proxy'
require 'classes/map'
require 'classes/roomsign'
require 'classes/healthitem'
require 'classes/barrier'

require 'libraries/event'
require 'libraries/physics'
require 'libraries/gamefunctions'

require 'states/game'
require 'states/title'
require 'states/win'
require 'states/credits'
require 'states/intro'
require 'states/gameover'

require 'enemies/music'
require 'enemies/paintbird'
require 'enemies/executioner'
require 'enemies/sudo'
require 'enemies/webexplore'
require 'enemies/document'
require 'enemies/cmd'

require 'classes/bitenemy'

--[[
	So as long as you stick to the lisence I will not try to hunt you down. That means you CAN modify the game but CANNOT reditribute the game as profit.
	Furthermore, you must give me credit (TurtleP aka Jeremy Postelnek) for any modifications you make of said game. Not sure why you'd be in this file,
	but who knows since you probably want to look at this code. It's not the best, trust me on that.

	Obligatory hidden webm's from Jeviny:
	https://u.pomf.io/fpqedd.webm
	https://u.pomf.io/arwmbp.webm

	You're welcome Jeviny.
--]]

function love.load()

	startTime = love.timer.getTime()
	loadingData = {}

	controls = {}

	controls["right"] = "cpadright"
	controls["left"] = "cpadleft"
	controls["up"] = "cpadup"
	controls["down"] = "cpaddown"

	controls["jump"] = "a"
	controls["pause"] = "start"
	controls["dodge"] = {"lbutton", "rbutton"}

	homebrewMode = true

	if love.system.getOS() ~= "3ds" then
		--image filter
		love.graphics.setDefaultFilter("nearest", "nearest")
		love.window.setTitle("Hax0r?")
		love.window.setIcon(love.image.newImageData("graphics/icon.png"))

		homebrewMode = false
		math.random = love.math.random

		require 'libraries/3ds'
	else
		math.randomseed(os.time())
	end

	consoleFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 16)
	introFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 32)

	loading(0, "graphics")

	titleimg = love.graphics.newImage("graphics/title.png")

	tileimg = love.graphics.newImage("graphics/base.png")

	UIIcons =
	{
		["battery"] = {love.graphics.newImage("graphics/3ds/battery.png"), love.graphics.newImage("graphics/3ds/charging.png")},
		["health"] = {["img"] = love.graphics.newImage("graphics/interface/health.png"), ["quads"] = {}},
		["power"] = love.graphics.newImage("graphics/interface/power.png")
	}

	for k = 1, 6 do
		UIIcons["health"]["quads"][k] = love.graphics.newQuad((k - 1) * 20, 0, 19, 16, UIIcons["health"]["img"]:getWidth(), 16)
	end

	loading(1)

	playerimg = love.graphics.newImage("graphics/player-new.png")
	playerquads = {}
	for k = 1, 3 do
		playerquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, playerimg:getWidth(), playerimg:getHeight())
	end

	firewallimg = love.graphics.newImage("graphics/firewall.png")
	firewallquads = {}
	for k = 1, 2 do
		firewallquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, firewallimg:getWidth(), firewallimg:getHeight()) 
	end

	loading(2)

	waterimg = love.graphics.newImage("graphics/digitalsea.png")
	waterquads = {}
	for k = 1, 6 do
		waterquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, waterimg:getWidth(), waterimg:getHeight())
	end

	deathimg = love.graphics.newImage("graphics/death.png")
	deathquads = {}
	for k = 1, 13 do
		deathquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, deathimg:getWidth(), deathimg:getHeight())
	end

	loading(3)

	waterbaseimg = love.graphics.newImage("graphics/seatile.png")

	executionerimg = {love.graphics.newImage("enemies/executioner.png"), love.graphics.newImage("enemies/executionerFlip.png")}
	executionerquads = {}
	for k = 1, 5 do
		executionerquads[k] = love.graphics.newQuad((k - 1) * 22, 0, 21, 29, executionerimg[1]:getWidth(), executionerimg[1]:getHeight())
	end

	loading(4)
	
	musicimg = love.graphics.newImage("enemies/musicFile.png")
	musicquads = {}
	for k = 1, 3 do
		musicquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 13, musicimg:getWidth(), musicimg:getHeight())
	end

	noteimg = love.graphics.newImage("enemies/notes.png")
	notequads = {}
	for k = 1, 2 do
		notequads[k] = love.graphics.newQuad((k - 1) * 7, 0, 6, 8, noteimg:getWidth(), noteimg:getHeight())
	end

	loading(5)

	paintbirdimg = 
	{
		["left"] = {love.graphics.newImage("enemies/imageFile.png"), love.graphics.newImage("enemies/imageFile2.png")},
		["right"] = {love.graphics.newImage("enemies/imageFileFlip.png"), love.graphics.newImage("enemies/imageFileFlip2.png")}
	}
	paintbirdquads = {}
	for k = 1, 3 do
		paintbirdquads[k] = love.graphics.newQuad((k - 1) * 19, 0, 18, 13, paintbirdimg["left"][1]:getWidth(), paintbirdimg["left"][1]:getHeight())
	end

	loading(6)

	background = {}
	for k = 1, 8 do
		background[k] = love.graphics.newImage("graphics/background/" .. k .. ".png")
	end

	sudoimg = love.graphics.newImage("enemies/sudo.png")
	sudoquads = {}
	for k = 1, 8 do
		sudoquads[k] = love.graphics.newQuad((k - 1) * 15, 0, 14, 14, sudoimg:getWidth(), sudoimg:getHeight())
	end

	loading(7)

	smokeimg = love.graphics.newImage("enemies/smoke.png")
	smokequads = {}
	for k = 1, 3 do
		smokequads[k] = love.graphics.newQuad((k - 1) * 10, 0, 9, 9, smokeimg:getWidth(), smokeimg:getHeight())
	end

	exploreimg = love.graphics.newImage("enemies/ie.png")
	explorequads = {}
	for x = 1, 2 do
		explorequads[x] = {}
		for y = 1, 2 do
			explorequads[x][y] = love.graphics.newQuad((x - 1) * 17, (y - 1) * 17, 16, 16, exploreimg:getWidth(), exploreimg:getHeight())
		end
	end

	loading(8)

	documentimg = love.graphics.newImage("enemies/document.png")
	documentquads = {}
	for k = 1, 4 do
		documentquads[k] = love.graphics.newQuad((k - 1) * 16, 0, 15, 16, documentimg:getWidth(), documentimg:getHeight())
	end

	computerimg = love.graphics.newImage("graphics/computericon.png")

	loading(9)

	appsicon = love.graphics.newImage("graphics/ds.png")
	
	bannerimg = love.graphics.newImage("graphics/bannerbig.png")

	loading(10)

	gameoverimg = love.graphics.newImage("graphics/gameover.png")
	introimg = love.graphics.newImage("graphics/intro.png")

	saveimg = love.graphics.newImage("graphics/savebar.png")

	loading(11)

	bufferimg = love.graphics.newImage("graphics/buffer.png")
	bufferquads = {}
	for y = 1, 2 do
		for x = 1, 12 do
			table.insert(bufferquads, love.graphics.newQuad((x - 1) * 40, (y - 1) * 40, 40, 40, bufferimg:getWidth(), bufferimg:getHeight()))
		end
	end

	loading(12)

	cmdimg = love.graphics.newImage("enemies/powercmd.png")
	cmdquads = {}
	for k = 1, 5 do
		cmdquads[k] = love.graphics.newQuad((k - 1) * 17, 0, 16, 16, cmdimg:getWidth(), cmdimg:getHeight())
	end

	hitpointimg = love.graphics.newImage("graphics/hitpoint.png")

	loading(13, "map scripts")

	--maps

	local myDirectory = "sdmc:/3ds/Hax0r/game/maps/scripts"
	local open = io.open
	if not homebrewMode then
		myDirectory = "maps/scripts"
		open = love.filesystem.read
	end

	mapScripts = {}
	for k = 1, 6 do
		local f = open(myDirectory .. "/" .. k .. ".txt")
		
		if type(f) ~= "string" and f then
			mapScripts[k] = f:read("*a")
			f:close()
		else
			mapScripts[k] = f
		end

		loading(13 + k)
	end

	--audio

	loading(20, "music")

	titlemusic = love.audio.newSource("audio/title.wav", "stream")
	midbossmusic = love.audio.newSource("audio/midboss.wav")

	loading(21, "sound effects")

	consolesound = love.audio.newSource("audio/console.wav")
	jumpsound = love.audio.newSource("audio/jump.wav")

	playerspawn = love.audio.newSource("audio/playerspawn.wav")

	gameoversnd = love.audio.newSource("audio/gameover.wav")

	loading(22)

	deathsnd = love.audio.newSource("audio/death.wav")

	savesnd = love.audio.newSource("audio/save.wav")
	blipsnd = love.audio.newSource("audio/blip.wav")

	loading(23)

	lifesnd = love.audio.newSource("audio/addlife.wav")

	collectSnd = {}
	for k = 1, 3 do
		collectSnd[k] = love.audio.newSource("audio/infect" .. k .. ".wav")
	end

	loading(24)
end

function loading(amount, t)
	local p = (amount / 24) * 360
	local time = love.timer.getTime() - startTime

	love.graphics.origin()

	love.graphics.setFont(consoleFont)

	local data = t
	if not t then
		data = ".."
	end

	love.graphics.setScreen("top")

	love.graphics.setColor(255, 255, 255)

	love.graphics.print("> [ " .. round(time, 2) .. "s ]: Loading.. " .. data, 20, 194)

	love.graphics.rectangle("fill", 20, 212, p, 8)

	love.graphics.present()

	if p == 360 then
		gameFunctions.changeState("intro")
	end
end

function savelog(data)
	local pcdata = os.date("!*t")
	
	local errFile = io.open("sdmc:/3ds/Hax0r/error.txt")
	
	if errFile then
		errFile:write(data)
	end
end

local function error_printer(msg, layer)
    print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errhand(msg)
	local errortime = os.date()
    msg = tostring(msg)

    error_printer(msg, 2)

	if not homebrewMode then
		if not love.window or not love.graphics or not love.event then
			return
		end

		if not love.graphics.isCreated() or not love.window.isCreated() then
			if not pcall(love.window.setMode, 800, 600) then
				return
			end
		end
	end
	
    if love.audio then 
		love.audio.stop() 
	end

    love.graphics.setColor(255, 255, 255, 255)

    local trace = debug.traceback()

    --love.graphics.clear()
    love.graphics.origin()
	
	if not consoleFont then
		consoleFont = love.graphics.newFont("graphics/windows_command_prompt.ttf", 16)
	end
	
	love.graphics.setBackgroundColor(0, 0, 0)
	
	 local err = {}

    table.insert(err, "Error: " .. msg)
	
	local n = 0
    for l in string.gmatch(trace, "(.-)\n") do
		n = n+1
		if not string.match(l, "boot.lua") and n ~= 2 and n ~= 3 then
            l = string.gsub(l, "stack traceback:", "[Stack Traceback]\n")
            table.insert(err, l)
        end
    end

    local p = table.concat(err, "\n")

    p = string.gsub(p, "\t", "")
    --p = string.gsub(p, "%[string \"(.-)\"%]", "%1")
	--p = string.gsub(p, "\r\n", "\n")
	--p = string.gsub(p, "\n", "\r\n")
	
	function string:split(delimiter) --Not by me
		local result = {}
		local from  = 1
		local delim_from, delim_to = string.find( self, delimiter, from  )
		while delim_from do
			table.insert( result, string.sub( self, from , delim_from-1 ) )
			from = delim_to + 1
			delim_from, delim_to = string.find( self, delimiter, from  )
		end
		table.insert( result, string.sub( self, from  ) )
		return result
	end
	
	function fixText(tofixtext, maxLength)
		local text = {""}
		local i1 = 1
		local font = consoleFont
		
		for i = 1, string.len(tofixtext) do
			local v = string.sub(tofixtext, i, i)
			
			if font:getWidth( string.sub(tofixtext, i1, i) ) >= maxLength then
				i1 = i
				table.insert(text, v)
			else
				text[#text] = text[#text] .. v
			end
		end

		return text
	end

	local major, minor, revision, codename = love.getVersion( )

	local errorlog = {	
					"[Love Version] " .. major .. "." .. minor .. "." .. revision .. "(" .. codename .. ")",
					"[Error time] " .. errortime, p,
					"[System OS] " .. love.system.getOS(),
					}

	savelog(table.concat(errorlog, "\r\n\r\n"))
	
	p = string.gsub(p, "\r\n", "\n")
	
	local errT = fixText(p, 400)
	
	local realError = {}
	for k, v in ipairs(errT) do
		realError[k] = v
	end
	
	local function draw()
        love.graphics.clear()

		love.graphics.setScreen("top")

		love.graphics.setFont(consoleFont)
		
		local spacer = 5
		local yy = 0
		for k = 1, #realError do
			local t = realError[k]:split("\n")
			for i, v in ipairs(t) do
				love.graphics.print(v, 0, 10 + yy)
				yy = yy + consoleFont:getHeight() + spacer
			end
		end
		
		love.graphics.setScreen("bottom")

		love.graphics.print("Love Potion version: " .. major .. "." .. minor .. "." .. revision .. " (" .. codename .. ")", 0, 10)

		love.graphics.print("Error time: " .. errortime, 0, 30)

		love.graphics.present()
	end
	
	while true do
		if not homebrewMode then
			love.event.pump()

			for e, a, b, c in love.event.poll() do
				if e == "quit" then
					return
				end
				if e == "keypressed" and a == "escape" then
					return
				end
			end
		end
		
		draw()

		if not homebrewMode then
			if love.timer then
				love.timer.sleep(0.1)
			end
		end
	end
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

function love.mousepressed(x, y, button)
	if _G[state .. "_mousepressed"] then
		_G[state .. "_mousepressed"](x, y, button)
	end
end

function love.mousereleased(x, y, button)
	if _G[state .. "_mousereleased"] then
		_G[state .. "_mousereleased"](x, y, button)
	end
end

gameFunctions = {}
function gameFunctions.changeState(newState, ...)
	local arg = {...}

	if _G[newState .. "_init"] then
		_G[newState .. "_init"](unpack(arg))
	end

	state = newState
end

function gameFunctions.getWidth(tile)
	local g = love.graphics.getWidth()
	
	if tile then
		return g / 16
	end
	return g
end

function gameFunctions.getHeight(tile)
	local g = love.graphics.getHeight()
	
	if tile then
		return g / 16
	end
	return g
end

function love.focus(f)
	if not f and not gameover then
		--paused = true
	end
end