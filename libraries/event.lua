eventsystem = class("eventsystem")

function eventsystem:init()
	self.sleep = 0
	self.i = 0
	self.events = {}
end

function eventsystem:update(dt)
	if self.i < #self.events then
		if self.sleep > 0 then
			self.sleep = math.max(0, self.sleep - dt)
		end

		if self.sleep == 0 then
			self.i = self.i + 1

			local v = self.events[self.i]

			if v.cmd == "console" then
				consoles[1] = console:new(v.args[1], v.args[2], v.args[3])
			elseif v.cmd == "wait" then
				self.sleep = v.args
			elseif v.cmd == "spawnplayer" then
				objects["player"][1] = player:new(v.args[1], v.args[2], true)
			elseif v.cmd == "firewallfree" then
				if objects["firewall"][1] then
					objects["firewall"][1]:fade()
				end
			end
		end
	end
end

function eventsystem:queue(e, args)
	table.insert(self.events, {cmd = e, args = args})
end

function eventsystem:clear()
	self.events = {}
end

function eventsystem:onMapLoad(map)
	if map == 1 then
		eventSystem:queue("console", {"Alright.. so this goes here.."})
		eventSystem:queue("wait", 6)
		eventSystem:queue("console", {"... and this needs to be secured.."})

		eventSystem:queue("wait", 6)
		eventSystem:queue("console", {"[HOST] Connecting to remote PC at XXX.XX.XXX.X:XXXXX .."})
		eventSystem:queue("wait", 8)

		eventSystem:queue("spawnplayer", {playerX, playerY})
		eventSystem:queue("wait", 1)
		eventSystem:queue("console", {"Good. Now my monsterous virus .. wait is this a PowerPC 95?"})

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
end