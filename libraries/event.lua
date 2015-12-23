eventsystem = class("eventsystem")

function eventsystem:init()
	self.sleep = 0
	self.i = 0
	self.events = {}
	currentScript = 8
	self.running = true
end

function eventsystem:update(dt)
	if self.i < #self.events then
		if self.sleep > 0 then
			self.sleep = math.max(0, self.sleep - dt)
		end

		if self.sleep == 0 and self.running then
			self.i = self.i + 1

			local v = self.events[self.i]

			if v.cmd == "console" then
				consoles[1] = console:new(v.args)
			elseif v.cmd == "wait" then
				self.sleep = v.args
			elseif v.cmd == "spawnplayer" then
				objects["player"][1] = player:new(playerX, playerY, true)
			elseif v.cmd == "firewallfree" then
				if objects["firewall"][1] then
					objects["firewall"][1]:fade()
				end
			elseif v.cmd == "freezeplayer" then
				_LOCKPLAYER = true
			elseif v.cmd == "unfreezeplayer" then
				_LOCKPLAYER = false
			elseif v.cmd == "terminaladd" then
				local data = fixTerminalData(v.args)

				for i, v in pairs(data) do
					table.insert(terminalstrings, v)
				end
			elseif v.cmd == "spawnBoss" then
				objects["boss"][1] = core:new(12 * 16, 6 * 16)
			elseif v.cmd == "shake" then
				shakeIntensity = tonumber(v.args)
			elseif v.cmd == "changeState" then
				gameFunctions.changeState(v.args)
			elseif v.cmd == "killPlayer" then
				objects["player"][1]:ide(true)
			end
		end
	else
		if self.running then
			currentScript = currentScript + 1
			self.running = false
		end
	end
end

function eventsystem:queue(e, args)
	table.insert(self.events, {cmd = e, args = args})
end

function eventsystem:clear()
	self.events = {}
end

function eventsystem:decrypt(scriptString)
	local split = scriptString:split("\n")
	local cmd = {}

	for k, v in pairs(split) do
		local thingy = v:split("=")
		
		if thingy[2] then
			thingy[2] = thingy[2]:sub(1, #thingy[2] - 1)
		end

		table.insert(cmd, {thingy[1], thingy[2]})
	end

	if cmd[1][1] == "levelequals" then
		if currentMap ~= tonumber(cmd[1][2]) then
			return
		else
			self.running = true
		end
	else
		self.running = true
	end

	for k = 1, #cmd do
		local arg = cmd[k][2]
		if cmd[k][1] == "wait" then
			cmd[k][2] = tonumber(arg)
		end
		self:queue(cmd[k][1], cmd[k][2])
	end
end