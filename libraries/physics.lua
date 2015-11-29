--[[
	Turtle's Physics Library
	All code is mine.
	(c) 2015 Tiny Turtle Industries
	(Obviously same licensing as the game)
--]]

function physicsupdate(dt)
	local obj = objects

	for name, objectT in pairs(obj) do
		if name ~= "tile" then --not updating tiles!
			for _, objData in pairs(objectT) do --check object variables
				if objData.active and not objData.static then

					local hor, ver = false, false 

					objData.speedy = math.min(objData.speedy + objData.gravity * dt, 10 * 16) --add gravity to objects

					for name2, object2T in pairs(obj) do
						if objData.mask and objData.mask[name2] == true and not objData.passive then
							hor, ver = checkCollision(objectT, object2T, objData, name, name2, dt)
						else
							checkPassive(objectT, object2T, objData, name, name2, dt)
						end
					end
					
					if not hor then
						objData.x = objData.x + objData.speedx * dt
					end

					if not ver then
						objData.y = objData.y + objData.speedy * dt
					end
				end
			end
		end
	end
end

function checkRectangle(x, y, w, h, obj)

	if type(obj) == "string" then
		for k, v in pairs(objects[obj]) do
			if aabb(x, y, w, h, v.x, v.y, v.width, v.height) then
				return true
			end
		end
		return false
	else
		for k = 1, #obj do
			local v = obj[k]
			for j, v in pairs(objects[v]) do
				if aabb(x, y, w, h, v.x, v.y, v.width, v.height) then
					return true
				end
			end
		end
		return false
	end

end

function checkPassive(objTable, obj2Table, objData, objName, obj2Name, dt)
	for _, obj2Data in pairs(obj2Table) do
		if aabb(objData.x, objData.y + objData.speedy * dt, objData.width, objData.height, obj2Data.x, obj2Data.y, obj2Data.width, obj2Data.height) or aabb(objData.x + objData.speedx * dt, objData.y, objData.width, objData.height, obj2Data.x, obj2Data.y, obj2Data.width, obj2Data.height) then --was vertical
			if objData.passiveCollide then
				objData:passiveCollide(obj2Name, obj2Data)
			end
		end
	end
end

function checkCollision(objTable, obj2Table, objData, objName, obj2Name, dt)
	local hor, ver = false, false

	for _, obj2Data in pairs(obj2Table) do
		if not obj2Data.passive then

			if aabb(objData.x + objData.speedx * dt, objData.y + objData.speedy * dt, objData.width, objData.height, obj2Data.x, obj2Data.y, obj2Data.width, obj2Data.height) then

				if aabb(objData.x, objData.y + objData.speedy * dt, objData.width, objData.height, obj2Data.x, obj2Data.y, obj2Data.width, obj2Data.height) then --was vertical
					ver = verticalCollide(objName, objData, obj2Name, obj2Data)
				elseif aabb(objData.x + objData.speedx * dt, objData.y, objData.width, objData.height, obj2Data.x, obj2Data.y, obj2Data.width, obj2Data.height) then
					hor = horizontalCollide(objName, objData, obj2Name, obj2Data)
				else
					--dat bug doe, some sort of dianal collision thing. gg Maurice.
					--[[if (objData.speedy - objData.gravity * dt) > (objData.speedx) then
						ver = verticalCollide(objName, objData, obj2Name, obj2Data)
					else
						hor = horizontalCollide(objName, objData, obj2Name, obj2Data)
					end]]
				end

			end

		else 
			checkPassive(objTable, obj2Table, objData, objName, obj2Name, dt)
			hor = false
			ver = false
		end
	end

	return hor, ver
end

function horizontalCollide(objName, objData, obj2Name, obj2Data)
	local changedspeed = true 

	if objData.speedx > 0 then
		if objData.rightCollide then --first object collision
			changedspeed = objData:rightCollide(obj2Name, obj2Data)
			if changedspeed ~= false then
				objData.x = obj2Data.x - objData.width
				objData.speedx = 0
			end
		else 
			objData.x = obj2Data.x - objData.width
			objData.speedx = 0
			changedspeed = true
		end	

		if obj2Data.leftCollide then --opposing object collides
			changedspeed = obj2Data:leftCollide(objName, objData) --Item 2 collides..
			if changedspeed ~= false then
				if obj2Data.speedx < 0 then
					obj2Data.speedx = 0
				end
			end
		else
			if obj2Data.speedx < 0 then
				obj2Data.speedx = 0
			end
		end
	elseif objData.speedx < 0 then
		if objData.leftCollide then
			changedspeed = objData:leftCollide(obj2Name, obj2Data)
			if changedspeed ~= false then
				objData.x = obj2Data.x + obj2Data.width
				objData.speedx = 0
			end
		else 
			objData.x = obj2Data.x + obj2Data.width
			objData.speedx = 0
			changedspeed = true
		end

		if obj2Data.rightCollide then
			changedspeed = obj2Data:rightCollide(objName, objData) --Item 2 collides..
			if changedspeed ~= false then
				if obj2Data.speedx > 0 then
					obj2Data.speedx = 0
				end
			end
		else
			if obj2Data.speedx > 0 then
				obj2Data.speedx = 0
			end
		end
	end

	return changedspeed
end

function verticalCollide(objName, objData, obj2Name, obj2Data)
	local changedspeed = true 

	if objData.speedy > 0 then
		if objData.downCollide then --first object collision
			changedspeed = objData:downCollide(obj2Name, obj2Data)

			if changedspeed ~= false then
				objData.y = obj2Data.y - objData.height
				objData.speedy = 0
			end
		else 
			objData.y = obj2Data.y - objData.height
			objData.speedy = 0
			changedspeed = true
		end	

		if obj2Data.upCollide then --opposing object collides
			changedspeed = obj2Data:upCollide(objName, objData) --Item 2 collides..
			if changedspeed ~= false then
				if obj2Data.speedy < 0 then
					obj2Data.speedy = 0
				end
			end
		else
			if obj2Data.speedy < 0 then
				obj2Data.speedy = 0
			end
		end
	elseif objData.speedy < 0 then
		if objData.upCollide then
			changedspeed = objData:upCollide(obj2Name, obj2Data)

			if changedspeed ~= false then
				objData.y = obj2Data.y + obj2Data.height
				objData.speedy = 0
			end
		else 
			objData.y = obj2Data.y + obj2Data.height
			objData.speedy = 0
			changedspeed = true
		end

		if obj2Data.downCollide then
			changedspeed = obj2Data:downCollide(objName, objData) --Item 2 collides..
			if changedspeed ~= false then
				if obj2Data.speedy > 0 then
					obj2Data.speedy = 0
				end
			end
		else
			if obj2Data.speedy > 0 then
				obj2Data.speedy = 0
			end
		end
	end

	return changedspeed
end

function aabb(v1x, v1y, v1width, v1height, v2x, v2y, v2width, v2height)
	local v1farx, v1fary, v2farx, v2fary = v1x + v1width, v1y + v1height, v2x + v2width, v2y + v2height
	return v1farx > v2x and v1x < v2farx and v1fary > v2y and v1y < v2fary
end

function CheckCollision(ax1, ay1, aw, ah, bx1, by1, bw, bh)
	local ax2, ay2, bx2, by2 = ax1*scale + aw*scale, ay1*scale + ah*scale, bx1*scale + bw*scale, by1*scale + bh*scale
	return ax1*scale < bx2 and ax2 > bx1*scale and ay1*scale < by2 and ay2 > by1*scale
end