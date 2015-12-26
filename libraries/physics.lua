--[[
	Turtle's Physics Library
	All code is mine.
	(c) 2015 Tiny Turtle Industries
	(Obviously same licensing as the game)
	v1.2
--]]

function physicsupdate(dt)
	local obj = objects

	for name, objectT in pairs(obj) do
		if name ~= "tile" then --not updating tiles!
			for _, objData in pairs(objectT) do --check object variables
				if objData.active and not objData.static then

					local hor, ver = false, false 

					objData.speedy = math.min(objData.speedy + objData.gravity * dt, 15 * 16) --add gravity to objects

					for name2, object2T in pairs(obj) do
						if objData.mask then
							if objData.mask[name2] and not objData.passive then
								hor, ver = checkCollision(objectT, object2T, objData, name, name2, dt)
							else
								checkPassive(objectT, object2T, objData, name, name2, dt)
							end
						else
							checkPassive(objectT, object2T, objData, name, name2, dt)
						end
					end
					
					if hor == false then
						objData.x = objData.x + objData.speedx * dt
					end

					if ver == false then
						objData.y = objData.y + objData.speedy * dt
					end
				end
			end
		end
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
					if verticalCollide(objName, objData, obj2Name, obj2Data) then
						ver = true
					end
				elseif aabb(objData.x + objData.speedx * dt, objData.y, objData.width, objData.height, obj2Data.x, obj2Data.y, obj2Data.width, obj2Data.height) then
					if horizontalCollide(objName, objData, obj2Name, obj2Data) then
						hor = true
					end
				else
					--Diagnal shit
					local g = 15 * 16 * dt
					if objData.gravity then
						g = objData.gravity
					end
					
					if math.abs(objData.speedy - g) < math.abs(objData.speedx) then
						if verticalCollide(objName, objData, obj2Name, obj2Data) then
							ver = true
						end
					else
						if horizontalCollide(objName, objData, obj2Name, obj2Data) then
							hor = true
						end
					end
				end

			end

		else 
			checkPassive(objTable, obj2Table, objData, objName, obj2Name, dt)
		end
	end

	return hor, ver
end

function horizontalCollide(objName, objData, obj2Name, obj2Data)
	if objData.speedx > 0 then
		if objData.rightCollide then --first object collision
			if objData:rightCollide(obj2Name, obj2Data) ~= false then
				if objData.speedx > 0 then
					objData.speedx = 0
				end
				objData.x = obj2Data.x - objData.width
				return true
			end
		else 
			if objData.speedx < 0 then
				objData.speedx = 0
			end
			objData.x = obj2Data.x - objData.width
			return true
		end	

		if obj2Data.leftCollide then --opposing object collides
			if obj2Data:leftCollide(objName, objData) ~= false then
				if obj2Data.speedx < 0 then
					obj2Data.speedx = 0
				end
			end
		else
			if obj2Data.speedx < 0 then
				obj2Data.speedx = 0
			end
		end
	else
		if objData.leftCollide then
			if objData:leftCollide(obj2Name, obj2Data) ~= false then
				if objData.speedx < 0 then
					objData.speedx = 0
				end
				objData.x = obj2Data.x + obj2Data.width
				return true
			end
		else 
			if objData.speedx < 0 then
				objData.speedx = 0
			end
			objData.x = obj2Data.x + obj2Data.width
			return true
		end

		if obj2Data.rightCollide then
			--Item 2 collides..
			if obj2Data:rightCollide(objName, objData) ~= false then
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

	return false
end

function verticalCollide(objName, objData, obj2Name, obj2Data)
	if objData.speedy > 0 then
		if objData.downCollide then --first object collision
			if objData:downCollide(obj2Name, obj2Data) ~= false then
				if objData.speedy > 0 then
					objData.speedy = 0
				end
				objData.y = obj2Data.y - objData.height
				return true
			end
		else 
			if objData.speedy > 0 then
				objData.speedy = 0
			end
			objData.y = obj2Data.y - objData.height
			return true
		end	

		if obj2Data.upCollide then --opposing object collides
			--Item 2 collides..
			if obj2Data:upCollide(objName, objData) ~= false then
				if obj2Data.speedy < 0 then
					obj2Data.speedy = 0
				end
			end
		else
			if obj2Data.speedy < 0 then
				obj2Data.speedy = 0
			end
		end
	else
		if objData.upCollide then
			if objData:upCollide(obj2Name, obj2Data) ~= false then
				if objData.speedy < 0 then
					objData.speedy = 0
				end
				objData.y = obj2Data.y + obj2Data.height
				return true
			end
		else 
			if objData.speedy < 0 then
				objData.speedy = 0
			end
			objData.y = obj2Data.y + obj2Data.height
			return true
		end

		if obj2Data.downCollide then
			--Item 2 collides..
			if obj2Data:downCollide(objName, objData) ~= false then
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

	return false
end

function aabb(v1x, v1y, v1width, v1height, v2x, v2y, v2width, v2height)
	local v1farx, v1fary, v2farx, v2fary = v1x + v1width, v1y + v1height, v2x + v2width, v2y + v2height
	return v1farx > v2x and v1x < v2farx and v1fary > v2y and v1y < v2fary
end

function CheckCollision(ax1, ay1, aw, ah, bx1, by1, bw, bh)
	local ax2, ay2, bx2, by2 = ax1*scale + aw*scale, ay1*scale + ah*scale, bx1*scale + bw*scale, by1*scale + bh*scale
	return ax1*scale < bx2 and ax2 > bx1*scale and ay1*scale < by2 and ay2 > by1*scale
end