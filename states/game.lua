function game_init()
	eventSystem = eventsystem:new()

	loadMap(1)

	titleNums = 
	{
		["top"] = {},
		["bottom"] = {}
	}

	makeTitleNums()

	score = 0

	gameover = false
	gameoversin = 0

	scoreTypes = {"KB", "MB", "GB"}
	scorei = 1

	combo = 0
	combotimeout = 0
	paused = false

	--pauseMenu = newPauseMenu()
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

	for k, j in pairs(titleNums) do
		for i, v in ipairs(j) do
			v[3] = v[3] + v[4] * dt

			if v[3] * 16 > gameFunctions.getHeight() then
				v[3] = 0
			end
		end
	end

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.update then
				w:update(dt)
			end
		end	
	end

	for k, v in pairs(consoles) do
		v:update(dt)

		if v.remove then
			table.remove(consoles, k)
		end
	end

	physicsupdate(dt)
end

function game_draw()
	love.graphics.setColor(255, 255, 255, 255)

	--love.graphics.push()

	--love.graphics.translate(tremorX + mapscrollx, tremorY + mapscrolly)

	love.graphics.setFont(backgroundFont)
	for k, v in ipairs(titleNums["top"]) do
		love.graphics.setScreen("top")
		love.graphics.setColor(0, 128, 0)
		love.graphics.print(v[1], 5 + (v[2] - 1) * 16, 1 + (v[3] - 1) * 16)
	end

	love.graphics.setScreen("top")

	love.graphics.setColor(255, 255, 255)
	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.draw then
				w:draw()
			end
		end	
	end

	for k, v in pairs(consoles) do
		v:draw()
	end

	--INTERFACE

	love.graphics.setScreen("bottom")

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(UIIcons["linux"], gameFunctions.getWidth() / 2 - UIIcons["linux"]:getWidth() / 2, gameFunctions.getHeight() / 2 - UIIcons["linux"]:getHeight() / 2)

	local state, percent = love.system.getPowerInfo()
	local batteryimg = UIIcons["battery"][1]

	local batteryColor = {0, 127, 14}
	local percentColor = {0, 155, 15}

	if state == "charging" then
		percentColor = {255, 106, 0}
		batteryColor = {196, 78, 0}
		love.graphics.draw(UIIcons["battery"][2], 2, gameFunctions.getHeight() - batteryimg:getHeight() - 2)
	end

	if not percent then
		percent = 0
	end

	if state ~= "charging" then
		if percent > 60 and percent < 85 then
			percentColor = {219, 182, 0}
			batteryColor = {193, 161, 0}
		elseif percent > 20 and percent < 60 then
			percentColor = {255, 106, 0}
			batteryColor = {196, 78, 0}
		elseif percent < 20 then
			percentColor = {232, 0, 0}
			batteryColor = {190, 0, 0}
		end
	end

	love.graphics.setColor(unpack(batteryColor))
	love.graphics.draw(batteryimg, 2, gameFunctions.getHeight() - batteryimg:getHeight() - 2)

	love.graphics.setColor(unpack(percentColor))
	love.graphics.rectangle("fill", 5, (gameFunctions.getHeight() - batteryimg:getHeight() - 2) + 2, (percent / 100) * 14, 9)

	--love.graphics.print(state, gameFunctions.getWidth() / 2, gameFunctions.getHeight() - 16)

	love.graphics.setColor(255, 255, 255)
	love.graphics.print(os.date("%I:%M %p"), gameFunctions.getWidth() - backgroundFont:getWidth(os.date("%I:%M %p")) - 2, gameFunctions.getHeight() - backgroundFont:getHeight(os.date("%I:%M %p")) - 1)
	--love.graphics.pop()
end

function game_keypressed(key)
	if key == controls["pause"] then
		if not gameover then
			paused = not paused
		else
			gameFunctions.changeState("game")
		end
	end

	if key == "select" then
		if paused then
			gameFunctions.changeState("title")
		end
	end

	if paused then
		--pauseMenu:keypressed(key)
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
	objects = {}

	objects["player"] = {}
	objects["tile"] = {}
	objects["bit"] = {}
	objects["bitblood"] = {}
	objects["explosion"] = {}
	objects["digits"] = {}
	objects["proxy"] = {}
	objects["firewall"] = {}

	consoles = {}

	objects["bullet"] = {}

	objects["antivirus"] = {}

	map = maps[map]
	

	local playerX, playerY
	for y = 1, #map do
		for x = 1, #map[1] do
			if map[y][x] == 1 then
				objects["tile"][x .. "-" .. y] = tile:new((x - 1) * 16, (y - 1) * 16)
			elseif map[y][x] == 3 then
				playerX = (x - 1) * 16
				playerY = (y - 1) * 16
			elseif map[y][x] == 2 then
				table.insert(objects["firewall"], firewall:new((x - 1) * 16, (y - 1) * 16))
			end
		end
	end

	eventSystem:queue("console", {"Alright.. so this goes here.."})
	eventSystem:queue("wait", 6)
	eventSystem:queue("console", {"... and this needs to be secured.."})

	eventSystem:queue("wait", 6)
	eventSystem:queue("console", {"[HOST] Connecting to remote PC at XXX.XX.XXX.X:XXXXX .."})
	eventSystem:queue("wait", 8)

	eventSystem:queue("spawnplayer", {playerX, playerY})
	eventSystem:queue("wait", 1)
	eventSystem:queue("console", {"Good. Now my monsterous virus .. wait .. is this a PowerPC 95?"})

	eventSystem:queue("wait", 8)
	eventSystem:queue("console", {"Whatever. Using you, I can stream data back to me."})
	eventSystem:queue("wait", 8)

	eventSystem:queue("console", {"Go ahead and move with CIRCLEPAD LEFT or RIGHT."})
	eventSystem:queue("wait", 10)
	eventSystem:queue("console", {"Now to decrypt this stupid firewall blocking C:\\.."})

	eventSystem:queue("wait", 10)
	eventSystem:queue("console", {"[HOST] Running /bin/firewalldecrypt.sh on remote PC.."})
	eventSystem:queue("wait", 6)

	eventSystem:queue("console", {"[HOST] Decryption completed."})
	eventSystem:queue("firewallfree")
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