trailmesh = class("trailmesh")

function trailmesh:init(x, y, img, width, lifetime, interval, method)
	self.type = "trailmesh"

	self.x = x
	self.y = y
	self.img = img
	self.width = width
	self.lifetime = lifetime
	self.interval = interval
	self.method = method or "stretch"

	self:reset()

	self.mesh = love.graphics.newMesh(self.verts,self.img,"strip")
end

function trailmesh:update(dt)
	self.timer = self.timer + dt
	if self.timer > self.interval then
		if self.method == "repeat" then
			self.length = self.points[1][5]
		end
		table.insert(self.points, 1, {self.x,self.y,self.lifetime})
		self.timer = self.timer - self.interval
	end

	self.points[1] = {self.x,self.y,self.lifetime,self.width}

	for point,v in pairs(self.points) do
		local pv = self.points[point+1]
		local nv = self.points[point-1]

		if v[3] < -self.interval*1.1 then
			table.remove(self.points, #self.points)
			table.remove(self.verts, #self.verts)
			table.remove(self.verts, #self.verts)
			break
		end

		local lifetime = v[3]/self.lifetime

		if self.method == "stretch" then
			if point == 1 then
				local dist = math.sqrt((v[1]-pv[1])^2+(v[2]-pv[2])^2)
				local vert = {(v[2]-pv[2])*v[4]/(dist*2), (v[1]-pv[1])*v[4]/(dist*2)}

				self.verts[1] = {
					v[1]+vert[1],
					v[2]-vert[2],
					lifetime,
					0}
				self.verts[2] = {
					v[1]-vert[1],
					v[2]+vert[2],
					lifetime,
					1}
			elseif point == #self.points then
				local dist = math.sqrt((nv[1]-v[1])^2+(nv[2]-v[2])^2)
				local vert = {(nv[2]-v[2])*v[4]/(dist*2), -(nv[1]-v[1])*v[4]/(dist*2)}

				self.verts[#self.points*2-1] = {
					v[1]+vert[1],
					v[2]-vert[2],
					lifetime,
					0}
				self.verts[#self.points*2] = {
					v[1]-vert[1],
					v[2]+vert[2],
					lifetime,
					1}
			else
				local dist = math.sqrt((nv[1]-pv[1])^2+(nv[2]-pv[2])^2)
				local vert = {(nv[2]-pv[2])*v[4]/(dist*2), (nv[1]-pv[1])*v[4]/(dist*2)}

				self.verts[point*2-1] = {
					v[1]+vert[1],
					v[2]-vert[2],
					lifetime,
					0}
				self.verts[point*2] = {
					v[1]-vert[1],
					v[2]+vert[2],
					lifetime,
					1}
			end
		elseif self.method == "repeat" then
			if point == 1 then
				local dist = math.sqrt((v[1]-pv[1])^2+(v[2]-pv[2])^2)
				local vert = {(v[2]-pv[2])*v[4]/(dist*2), (v[1]-pv[1])*v[4]/(dist*2)}

				v[5] = dist/(self.img:getWidth()/(self.img:getHeight()/self.width)) + self.length

				self.verts[1] = {
					v[1]+vert[1],
					v[2]-vert[2],
					v[5],
					0,
					255,
					255,
					255,
					255*lifetime}
				self.verts[2] = {
					v[1]-vert[1],
					v[2]+vert[2],
					v[5],
					1,
					255,
					255,
					255,
					255*lifetime}
			elseif point == #self.points then
				local dist = math.sqrt((nv[1]-v[1])^2+(nv[2]-v[2])^2)
				local vert = {(nv[2]-v[2])*v[4]/(dist*2), -(nv[1]-v[1])*v[4]/(dist*2)}

				self.verts[#self.points*2-1] = {
					v[1]+vert[1],
					v[2]-vert[2],
					v[5],
					0,
					255,
					255,
					255,
					1}
				self.verts[#self.points*2] = {
					v[1]-vert[1],
					v[2]+vert[2],
					v[5],
					1,
					255,
					255,
					255,
					1}
			else
				local dist = math.sqrt((nv[1]-pv[1])^2+(nv[2]-pv[2])^2)
				local vert = {(nv[2]-pv[2])*v[4]/(dist*2), (nv[1]-pv[1])*v[4]/(dist*2)}

				self.verts[point*2-1] = {
					v[1]+vert[1],
					v[2]-vert[2],
					v[5],
					0,
					255,
					255,
					255,
					255*(lifetime+self.interval)}
				self.verts[point*2] = {
					v[1]-vert[1],
					v[2]+vert[2],
					v[5],
					1,
					255,
					255,
					255,
					255*(lifetime+self.interval)}
			end
		end
		self.points[point][3] = v[3] - dt
	end
	if #self.verts > 3 then
		self.mesh:setVertices(self.verts)
	end
end

function trailmesh:draw()
	love.graphics.draw(self.mesh)
end

function trailmesh:setWidth(size, part)
	if part == "base" or not part then
		self.width = size
	elseif part == "all" then
		for k,v in pairs(self.points) do
			v[4] = size
		end
	end
end

function trailmesh:reset()
	self.timer = 0
	self.length = 0
	self.points = {{self.x,self.y,self.lifetime,self.width,0},{self.x,self.y,self.lifetime-self.interval,self.width,0}}
	self.verts = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}}
end