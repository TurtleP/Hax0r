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
				objects["console"][1] = console:new(v.args[1], v.args[2], v.args[3])
			elseif v.cmd == "wait" then
				self.sleep = v.args
			elseif v.cmd == "spawnplayer" then
				objects["player"][1] = player:new(v.args[1], v.args[2], true)
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