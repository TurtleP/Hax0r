function game_init()
	eventSystem = eventsystem:new()

	loadMap(1)

	score = 0

	backgroundLines = {}
	for k = 1, 16 do
		backgroundLines[k] = newBackgroundLine(backgroundLines, k)
	end

	gameover = false
	gameoversin = 0
	tremorX = 0
	tremorY = 0

	scoreTypes = {"KB", "MB", "GB"}
	scorei = 1

	combo = 0
	combotimeout = 0
	paused = false

	bgm_start:play()
	bgm:stop()

	pauseMenu = newPauseMenu()
end

function game_update(dt)
	if paused then
		return
	end

	eventSystem:update(dt)

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.remove then
				table.remove(objects[k], j)
			end
		end
	end

	if tremorX and tremorY then
		if tremorX > 0 then
			tremorX = math.max(tremorX - 10 * dt, 0)
		else
			tremorX = math.min(tremorX + 10 * dt, 0)
		end

		if tremorY > 0 then
			tremorY = math.max(tremorY - 10 * dt, 0)
		else
			tremorY = math.min(tremorY + 10 * dt, 0)
		end
	end

	if gameover then
		gameoversin = gameoversin + dt

		for k, v in pairs(objects["digits"]) do
			v:update(dt)
		end

		for k, v in pairs(objects["explosion"]) do
			v:update(dt)
		end

		return
	end

	if combo > 1 then
		if combotimeout < 1 then
			combotimeout = combotimeout + dt
		else
			combo = 0
			combotimeout = 0
		end
	end

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.update then
				w:update(dt)
			end
		end	
	end

	for k, v in pairs(timers) do
		for j, w in pairs(v) do
			w:update(dt)

			if w.remove then
				table.remove(timers[k], j)
			end
		end
	end

	for k, v in pairs(backgroundLines) do
		v:update(dt)
	end

	if background[currentPos].fadeOut then
		background[currentPos].fade = math.max(0, background[currentPos].fade - 160 * dt)

		if positionTimer == 0 then
			positionTimer = 0.01
		end
	else
		if positionTimer > 0 then
			positionTimer = positionTimer - dt
		else
			currentPos = love.math.random(#background)
			background[currentPos].fadeOut = true
			positionTimer = 0.01
		end
	end

	for k = #background, 1, -1 do
		if background[k].fade == 0 then
			background[k].fade = 255
			background[k].fadeOut = false
		end
	end

	physicsupdate(dt)
end

function game_draw()
	for j = 1, #background do
		if background[j].fadeOut then
			love.graphics.setColor(255, 255, 255, background[j].fade)
			love.graphics.print(background[j].value, background[j].x, background[j].y)
		end
	end

	for k, v in pairs(backgroundLines) do
		v:draw()
	end

	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.push()

	love.graphics.translate(tremorX + mapscrollx, tremorY + mapscrolly)
	love.graphics.draw(gameBatch)

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.draw then
				w:draw()
			end
		end	
	end

	love.graphics.pop()

	love.graphics.setFont(backgroundFont)

	love.graphics.setColor(0, 0, 0, 255)

	love.graphics.setColor(255, 255, 255, 255)
	if gameover then
		love.graphics.draw(gameoverimg, gameFunctions.getWidth() / 2 * scale - (38 / 2) * scale, gameFunctions.getHeight() / 2 * scale - (58 / 2) * scale + math.sin(gameoversin) * 20, 0, scale, scale)

		love.graphics.print("Press '" .. controls["pause"] .. "' to retry.", gameFunctions.getWidth() / 2 * scale - backgroundFont:getWidth("Press '" .. controls["pause"] .. "' to retry.") / 2, gameFunctions.getHeight() / 2 * scale - backgroundFont:getWidth("Press '" .. controls["pause"] .. "' to retry.") / 2 + 100 * scale  + math.sin(gameoversin) * 20)
	end

	if paused and not gameover then
		pauseMenu:draw()
	end
end

function game_mousepressed(x, y, button)

end

function nextMap()
	currentmap = currentmap + 1

	if love.filesystem.exists("graphics/" .. currentmap .. ".png") then
		loadMap(currentmap)
	else
		return
	end
end

function game_keypressed(key)
	if key == controls["pause"] then
		if not gameover then
			paused = not paused
		else
			gameFunctions.changeState("game")
		end
	end

	if paused then
		pauseMenu:keypressed(key)
	end

	if not objects["player"][1] then
		return
	end

	if key == controls["left"] then
		objects["player"][1]:moveleft(true)
	elseif key == controls["right"] then
		objects["player"][1]:moveright(true)
	elseif key == controls["jump"] then
		objects["player"][1]:jump()
	end

	if key == "lshift" then
		objects["player"][1]:dash()
	end
end

function game_keyreleased(key)
	if not objects["player"][1] then
		return
	end

	if key == controls["left"] then
		objects["player"][1]:moveleft(false)
	elseif key == controls["right"] then
		objects["player"][1]:moveright(false)
	end
end

function loadMap(map)
	loadmap = love.image.newImageData("maps/1.png")

	objects = {}

	objects["player"] = {}
	objects["tile"] = {}
	objects["bit"] = {}
	objects["bitblood"] = {}
	objects["explosion"] = {}
	objects["digits"] = {}
	objects["proxy"] = {}
	objects["firewall"] = {}

	objects["console"] = {}

	objects["bullet"] = {}

	objects["antivirus"] = {}
	timers = { ["bits"] = {} , ["console"] = {} , ["av"] = {} , ["events"] = {} , ["firewall"] = {} }

	mapscrollx = 0
	mapscrolly = 0

	local values = {"0", "1"}
	background = {}
	for k = 1, loadmap:getHeight() do
		for y = 1, loadmap:getWidth() do 
			local val = values[love.math.random(#values)]
			table.insert(background, {value = val, fade = 255, x = (y - 1) * 16 * scale + (16 / 2) * scale - backgroundFont:getWidth(val) / 2, y = (k - 1) * 16 * scale + (16 / 2) * scale - backgroundFont:getHeight(val) / 2})
		end
	end
	currentPos = 1
	positionTimer = 0.01

	gameBatch:clear()

	local playerX, playerY
	for y = 1, loadmap:getHeight() do
		for x = 1, loadmap:getWidth() do
			local r, g, b = loadmap:getPixel(x - 1, y - 1)

			if r == 0 and g == 0 and b == 0 then
				table.insert(objects["tile"], tile:new((x - 1) * 16, (y - 1) * 16, 1))
			elseif r == 255 and g == 0 and b == 0 then
				playerX, playerY = (x - 1) * 16, (y - 1) * 16
				--table.insert(objects["tile"], tile:new((x - 1) * 16, (y - 1) * 16, 1, true))
			elseif r == 255 and g == 255 and b == 255 then
				--table.insert(objects["tile"], tile:new((x - 1) * 16, (y - 1) * 16, 1, true))
			end
		end
	end

	mapwidth = loadmap:getWidth()
	mapheight = loadmap:getHeight()

	--[[roomCount = 1
	while roomCount < 10 do
		game_newRoom()
		roomCount = roomCount + 1
	end]]

	--make a default map lol

	eventSystem:queue("console", {"Hello, world!"})
	eventSystem:queue("wait", 4)
	eventSystem:queue("spawnplayer", {playerX, playerY})
end

function consoleDelay(t, s, c, f)
	table.insert(timers["console"], newTimer(t, function()
		objects["console"][1] = newConsole(s, c, f)
	end))
end

function newTimer(t, f, stopAtMax)
	local timerthing = {}

	timerthing.maxtime = t
	timerthing.func = f
	timerthing.time = 0
	timerthing.stopAtMax = stopAtMax

	timerthing.stop = false

	function timerthing:update(dt)
		if self.time < self.maxtime then
			self.time = self.time + dt
		else
			if not self.stop then
				self.func()
				self.remove = true
				self.stop = true
			end
		end
	end

	return timerthing
end

function newRepeatTimer(t, f)
	local timerthing = {}

	timerthing.maxtime = t
	timerthing.func = f
	timerthing.time = 0
	timerthing.stopAtMax = stopAtMax

	timerthing.stop = false

	function timerthing:update(dt)
		if self.time < self.maxtime then
			self.time = self.time + dt
		else
			self.func()
			self.time = 0
		end
	end

	return timerthing
end

function newBackgroundLine()
	local y = 0

	local line = {}

	line.x = love.math.random(4, gameFunctions.getWidth() - 8)
	line.y = y
	line.initX = x
	line.initY = y

	line.speed = love.math.random(80, 160)

	line.width = love.math.random(4, 8)
	line.height = love.math.random(30, 40)

	line.colors = {love.math.random(120, 255), love.math.random(120, 255), love.math.random(120, 255), 100}

	function line:draw()
		love.graphics.setColor(self.colors)
		love.graphics.rectangle("fill", self.x * scale, self.y * scale, self.width * scale, self.height * scale)
	end

	function line:update(dt)
		self.y = self.y + self.speed * dt
		
		if self.y > gameFunctions.getHeight() then
			self.x = self:newX()
			self.y = 0
			self.colors = self:newColors() --seems legal
		end
	end

	function line:newX()
		return love.math.random(4, gameFunctions.getWidth() - 8)
	end

	function line:newColors()
		return {love.math.random(120, 255), love.math.random(120, 255), love.math.random(120, 255), 100}
	end

	return line
end