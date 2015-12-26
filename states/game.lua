function game_init(loadSaveFile)
	maps = {}
	
	for k = 1, 14 do
		maps[k] = {map = require("maps/" .. k), name = _MAPNAMES[k]}
	end

	playerhealth = 3

	if not loadSaveFile then
		currentMap = 1

		eventSystem = eventsystem:new()

		score = 0

		maplist = {}

		maplist[1] = maps[1]

		while (#maplist < 14) do
			if #maps < 2 then
				break
			end

			local rand = math.random(2, #maps)
			if maps[rand].name ~= "C:\\PowerCore32\\> PowerCMD" and maps[rand].name ~= "System Core" then
				print(maps[rand].name)
				table.insert(maplist, maps[rand])
				table.remove(maps, rand)
			end
		end
	end

	maplist[15] = {map = require("maps/midboss"), name = "C:\\PowerCore32\\> PowerCMD"}
	maplist[16] = {map = require("maps/finalboss"), name = "System Core"}


	loadMap(currentMap)

	paused = false

	mapFade = 0

	gameover = false
	mapFadeOut = false

	terminalstrings = {}

	datablinktimer = 0
	pointsAdd = false
	pointsAddTimer = 0
	scoreAdd = 0
	
	love.graphics.setBackgroundColor(0, 80, 80)

	shakeIntensity = 0
	pointsRate = 0.01
	scoreRate = 1
end

function fixTerminalData(tofixtext, maxLength)
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

function game_update(dt)
	if not objects["boss"][1] then
		if not titlemusic:isPlaying() then
			titlemusic:play()
		end
	else
		if not objects["boss"][1].song:isPlaying() then
			objects["boss"][1].song:play()
		end
	end

	if paused then
		return
	end

	if shakeIntensity > 0 then
		shakeIntensity = shakeIntensity - 10 * dt
	end

	eventSystem:update(dt)

	physicsupdate(dt)

	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.remove then
				table.remove(objects[k], j)
			end
		end
	end

	if currentMap ~= 1 then
		if getEnemyCount() == 0 and not eventSystem.running then
			if objects["firewall"][1] then
				objects["firewall"][1]:fade()
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

	datablinktimer = datablinktimer + 2 * dt
	if datablinktimer > 3 then
		datablinktimer = 0
	end

	if pointsAdd then
		if math.abs(scoreAdd - score) == 0 then
			pointsAdd = false
		end

		if pointsAddTimer < pointsRate then
			pointsAddTimer = pointsAddTimer + dt
		else
			if math.abs(scoreAdd - score) ~= 0 then
				score = math.min(score + scoreRate, scoreAdd, 48000)
			else
				pointsAdd = false
			end
			pointsAddTimer = 0
		end
	end

	if mapFadeOut then
		if mapFade < 1 then
			mapFade = math.min(mapFade + 0.8 * dt, 1)
		else
			if not gameover then
				mapFadeOut = false
				loadMap(currentMap + 1)
			else
				gameFunctions.changeState("gameover")
			end
		end
	else
		if mapFade > 0 then
			mapFade = math.max(mapFade - 0.8 * dt, 0)
		end
	end

	if roomSign then
		roomSign:update(dt)
	end
end

function game_draw()
	love.graphics.setColor(255, 255, 255, 255)

	love.graphics.setScreen("top")

	if shakeIntensity > 0 then
		love.graphics.translate( (math.random() * 2 - 1) * shakeIntensity, (math.random() * 2 - 1) * shakeIntensity ) 
	end

	love.graphics.setColor(255, 255, 255, 255)
	for k, v in pairs(objects) do
		for j, w in pairs(v) do
			if w.draw then
				w:draw()
			end
		end	
	end

	love.graphics.setColor(255, 255, 255, 255)
	
	love.graphics.setFont(consoleFont)

	for k, v in pairs(consoles) do
		v:draw()
	end

	if roomSign then
		roomSign:draw()
	end

	if mapFade > 0 then
		love.graphics.setColor(0, 0, 0, 255 * mapFade)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setColor(255, 255, 255, 255)
	end

	--INTERFACE

	--if homebrewMode then
		love.graphics.setScreen("bottom")

		local batteryimg = UIIcons["battery"][1]

		local batteryLeft = _PLAYERLIVES

		local batteryColor = {0, 127, 14}
		local percentColor = {0, 155, 15}

		if batteryLeft == 2 then
			percentColor = {255, 106, 0}
			batteryColor = {196, 78, 0}
		elseif batteryLeft < 2 then
			percentColor = {232, 0, 0}
			batteryColor = {190, 0, 0}
		end

		love.graphics.setColor(32, 32, 32)
		love.graphics.rectangle("fill", 0, 0, gameFunctions.getWidth(), 18)
		love.graphics.rectangle("fill", 0, gameFunctions.getHeight() - 18, gameFunctions.getWidth(), 18)

		love.graphics.setColor(16, 16, 16)
		love.graphics.rectangle("fill", 0, 18, gameFunctions.getWidth(), gameFunctions.getHeight() - 36)


		love.graphics.setColor(unpack(batteryColor))
		love.graphics.draw(batteryimg, 2, gameFunctions.getHeight() - batteryimg:getHeight() - 2)

		love.graphics.setColor(unpack(percentColor))
		for k = 1, batteryLeft do
			love.graphics.rectangle("fill", 5 + (k - 1) * 5, (gameFunctions.getHeight() - batteryimg:getHeight() - 2) + 2, 4, 10)
		end

		love.graphics.setColor(255, 255, 255)
		love.graphics.print(os.date("%I:%M %p"), gameFunctions.getWidth() - consoleFont:getWidth(os.date("%I:%M %p")) - 2, gameFunctions.getHeight() - consoleFont:getHeight(os.date("%I:%M %p")) - 4)
		
		if objects["player"][1] then
			love.graphics.draw(UIIcons["health"]["img"], UIIcons["health"]["quads"][math.min(objects["player"][1].health + 1, 4)], 2, 0)
		else
			love.graphics.draw(UIIcons["health"]["img"], UIIcons["health"]["quads"][1], 2, 0)
		end

		love.graphics.draw(UIIcons["power"], gameFunctions.getWidth() - 18, 1)

		local scoreType = getScoreType(score)
		local cmd = "user@H@x0rPC:~$ Infected: " .. round(convert(score, scoreType), 2) .. scoreType .. "/48MB"
		love.graphics.print(cmd, 0, 18)

		love.graphics.setColor(255, 255, 255, 255 * math.sin(datablinktimer))
		love.graphics.print("_", consoleFont:getWidth(cmd) + consoleFont:getWidth("_") / 2, 18)
		love.graphics.setColor(255, 255, 255, 255)

		local spacer = 5
		local yy = 0
		for k = 1, #terminalstrings do
			local t = terminalstrings[k]:split("\n")
			for i, v in ipairs(t) do
				love.graphics.print(v, 2, 40 + yy)
				yy = yy + consoleFont:getHeight() + spacer
			end
		end

		love.graphics.setColor(255, 255, 255)

		if objects["boss"][1] then
			local name = objects["boss"][1].name .. ":"
			local x = (gameFunctions.getWidth() / 2 - ( (consoleFont:getWidth(name) / 2) + 52 / 2) )
			love.graphics.print(name, x, (18 / 2) - consoleFont:getHeight(name) / 2 - 2)

			for k = 1, objects["boss"][1].maxhealth do
				if k > objects["boss"][1].health then
					love.graphics.setColor(127, 127, 127)
				else
					love.graphics.setColor(255, 255, 255)
				end
				love.graphics.draw(hitpointimg, math.floor(x + consoleFont:getWidth(name)) + 4 + (k - 1) * 12, 9 - hitpointimg:getHeight() / 2)
			end
		end
	--end

	love.graphics.setScreen("top")
	if paused then
		love.graphics.setColor(0, 0, 0, 255 * 0.5)
		love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

		love.graphics.setColor(255, 255, 255, 255)

		love.graphics.setFont(introFont)
		love.graphics.print("GAME PAUSED", love.graphics.getWidth() / 2 - introFont:getWidth("GAME PAUSED") / 2, love.graphics.getHeight() / 2 - introFont:getHeight() - 2)
	end
end

function game_keypressed(key)
	if key == controls["pause"] then
		if not gameover then
			paused = not paused

			if paused then
				pausesnd:play()
			end
		end
	end

	if consoles[1] then
		if key == "x" then
			table.remove(consoles, 1)
			eventSystem.sleep = 0
		end
	end

	if not objects["player"][1] or _LOCKPLAYER then
		return
	end

	if key == controls["left"] then
		objects["player"][1]:moveleft(true)
	elseif key == controls["right"] then
		objects["player"][1]:moveright(true)
	elseif key == controls["jump"] then
		objects["player"][1]:jump()
	elseif key ==  controls["up"] then
		objects["player"][1]:moveup(true)
	elseif key == controls["down"] then
		objects["player"][1]:movedown(true)
	elseif key == controls["dodge"][1] or key == controls["dodge"][2] then
		objects["player"][1]:dodge()
	end
end

function game_mousepressed(x, y, button)
	if x > gameFunctions.getWidth() - 18 and x < (gameFunctions.getWidth() - 18) + 16 and y > 1 and y < 18 then
		paused = not paused
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
	elseif key ==  controls["up"] then
		objects["player"][1]:moveup(false)
	elseif key == controls["down"] then
		objects["player"][1]:movedown(false)
	end
end

function game_Explode(self, other, color)
	local w, h
	local size = 3
	local class
	local obj 

	if not other then
		obj = self
		class = tostring(self)
		w, h = self.width, self.height
	else
		obj = other
		class = tostring(other)
		w, h = other.width, other.height
	end

	table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y, nil, -60, -60, false, size, size, color, false))

	table.insert(objects["paintdrop"], paintdrop:new(self.x + w, self.y, nil, 60, -60, false, size, size, color, false))

	table.insert(objects["paintdrop"], paintdrop:new(self.x, self.y + h, nil, -60, 0, false, size, size, color, false))

	table.insert(objects["paintdrop"], paintdrop:new(self.x + w, self.y + h, nil, 60, 0, false, size, size, color, false))

	if not obj.extensions then
		return
	end
	
	for k = #class, 1, -1 do
		if class:sub(k, k) == " " then
			class = class:sub(k + 1)
		end
	end

	class = class:gsub("^%l", string.upper)

	local t = obj.extensions.t

	local min, max

	if t == "system" then
		min, max = 364, 420
	elseif t == "image" then
		min, max = 34, 40
	elseif t == "audio" then
		min, max = 634, 706
	elseif t == "executable" then
		min, max = 1524, 1620
	elseif t == "web document" then
		min, max = 40, 50
	elseif t == "document" then
		min, max = 140, 160
	else
		min, max = 18000, 18000 --ye 18MB
	end

	local objData = math.random(min, max)
	local str = fixTerminalData("VIRUS [H@x0r] has infected file: [" .. class .. ", " .. obj.extensions.t .. " file] . File size: " .. objData .. " KB.", 304)

	scoreAdd = scoreAdd + objData

	pointsAdd = true

	for i, v in pairs(str) do
		table.insert(terminalstrings, v)
	end

	if #terminalstrings > 8 then
		for k = 2, 1, -1 do
			table.remove(terminalstrings, k)
		end
	end

	collectSnd[math.random(#collectSnd)]:play()

	if objects["player"][1].health < 3 then
		if math.random(100) < 30 then
			table.insert(objects["health"], healthitem:new(obj.x + obj.width / 2, obj.y))
		end
	end
end

function loadMap(mapn)
	objects = {}

	objects["firewall"] = {}

	objects["player"] = {}

	objects["tile"] = {}

	objects["audioblaster"] = {}
	objects["notes"] = {}

	objects["paintbird"] = {}
	objects["paintdrop"] = {}

	objects["executioner"] = {}

	objects["sudo"] = {}
	objects["rocket"] = {}

	objects["webexplorer"] = {}

	objects["document"] = {}

	objects["health"] = {}

	objects["boss"] = {}
	
	objects["barrier"] = {}
	objects["beam"] = {}
	objects["bullet"] = {}
	objects["laser"] = {}

	consoles = {}

	if not maplist[mapn] then
		gameFunctions.changeState("gameover")
		return
	end

	map = maplist[mapn].map
	currentMap = mapn

	makeTiles(map)
	
	playerX, playerY = 0, 0
	for y = 1, #map do
		for x = 1, #map[1] do
			if map[y][x] == 3 then
				playerX = (x - 1) * 16
				playerY = (y - 1) * 16
			elseif map[y][x] == 2 then
				table.insert(objects["firewall"], firewall:new((x - 1) * 16, (y - 1) * 16))
			elseif map[y][x] == 4 then
				table.insert(objects["audioblaster"], audioblaster:new((x - 1) * 16, (y - 1) * 16))
			elseif map[y][x] == 8 then
				table.insert(objects["paintbird"], paintbird:new((x - 1) * 16 - 2, (y - 1) * 16 + 3))
			elseif map[y][x] == 9 then
				table.insert(objects["executioner"], executioner:new((x - 1) * 16, (y - 1) * 16 - 5))
			elseif map[y][x] == 10 then
				table.insert(objects["sudo"], sudo:new((x - 1) * 16 + 2, (y - 1) * 16 + 2))
			elseif map[y][x] == 11 then
				table.insert(objects["webexplorer"], webexplore:new())
			elseif map[y][x] == 12 then
				table.insert(objects["document"], document:new((x - 1) * 16, (y - 1) * 16))
			elseif map[y][x] == 13 then
				objects["boss"][1] = cmd:new((x - 1) * 16, (y - 1) * 16)
			end
		end
	end

	if currentMap ~= 1 then
		objects["player"][1] = player:new(playerX, playerY, false, playerhealth)
	end

	roomSign = roomsign:new(maplist[mapn].name)

	if mapScripts[currentScript] then
		eventSystem:decrypt(mapScripts[currentScript])
	end

	objects["barrier"][1] = barrier:new(0, -16, 400, 16)
	objects["barrier"][2] = barrier:new(-16, 0, 16, 240)

	objects["barrier"][3] = barrier:new(416, 0, 16, 240)
	objects["barrier"][4] = barrier:new(0, 240, 400, 16)
end

function makeTiles(mapData)
	local w, h = {0, 0, 0}, 16
	local pos = {["tile"] = {}, ["water"] = {}, ["waterbase"] =  {}}
	local first = {false, false, false}
	
	--map loop (tiles)
	for y = 1, #mapData do
		for x = 1, #mapData[y] do
			if mapData[y][x] == 1 then
				--found a tile, add width
				w[1] = w[1] + 16
				
				--store START positions because it's big fuckin tile.. sometimes
				if not first[1] then
					table.insert(pos["tile"], {x, y, 0, 16})
					first[1] = true
				end
			end

			if mapData[y][x] == 5 then
				--found a tile, add width
				w[2] = w[2] + 16
				
				--store START positions because it's big fuckin tile.. sometimes
				if not first[2] then
					table.insert(pos["water"], {x, y, 0, 16})
					first[2] = true
				end
			end

			if mapData[y][x] == 6 then
				--found a tile, add width
				w[3] = w[3] + 16
				
				--store START positions because it's big fuckin tile.. sometimes
				if not first[3] then
					table.insert(pos["waterbase"], {x, y, 0, 16})
					first[3] = true
				end
			end

			if first[1] then
				if mapData[y][x] ~= 1 then
					--Welcome to the part where I store you the width and height
					--also reset width to not screw up badly (and first is false since see above)
					pos["tile"][#pos["tile"]][3] = w[1]
					w[1] = 0
					first[1] = false
				end
			end

			if first[2] then
				if mapData[y][x] ~= 5 then
					--Welcome to the part where I store you the width and height
					--also reset width to not screw up badly (and first is false since see above)
					pos["water"][#pos["water"]][3] = w[2]
					w[2] = 0
					first[2] = false
				end
			end

			if first[3] then
				if mapData[y][x] ~= 6 then
					--Welcome to the part where I store you the width and height
					--also reset width to not screw up badly (and first is false since see above)
					pos["waterbase"][#pos["waterbase"]][3] = w[3]
					w[3] = 0
					first[3] = false
				end
			end
		end

		--We made it to another level of the map on the y coord. Time to reset/store again
		if first[1] then
			pos["tile"][#pos["tile"]][3] = w[1]
			w[1] = 0
			first[1] = false
		end

		if first[2] then
			pos["water"][#pos["water"]][3] = w[2]
			w[2] = 0
			first[2] = false
		end

		if first[3] then
			pos["waterbase"][#pos["waterbase"]][3] = w[3]
			w[3] = 0
			first[3] = false
		end
	end
	
	for index, value in pairs(pos) do
		for k = 1, #pos[index] do
			objects["tile"][pos[index][k][1] .. "-" .. pos[index][k][2]] = tile:new((pos[index][k][1] - 1) * 16, (pos[index][k][2] - 1) * 16, pos[index][k][3], pos[index][k][4], index)
		end
	end
end

function getEnemyCount()
	local o = objects
	local audio, exe, doc, sys, img, web, boss = o["audioblaster"], o["executioner"], o["document"], o["sudo"], o["paintbird"], o["webexplorer"], o["boss"]

	return (#audio + #exe + #doc + #sys + #img + #web + #boss)
end