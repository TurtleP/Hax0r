function colorfade(currenttime, maxtime, c1, c2) --Color function, HugoBDesigner
	local tp = currenttime/maxtime
	local ret = {} --return color

	for i = 1, #c1 do
		ret[i] = c1[i]+(c2[i]-c1[i])*tp
		ret[i] = math.max(ret[i], 0)
		ret[i] = math.min(ret[i], 255)
	end

	return ret
end

function changeScale(s)
	if s then
		scale = s
		love.window.setMode(400 * scale, 240 * scale, {vsync = true})
	else
		love.window.setFullscreen(true, "normal")

		local width, height = love.window.getDesktopDimensions()

		love.window.setMode(width, height, {vsync = true})

		scale = math.floor(math.max(width / 400, height / 240))
	end
end

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

function math.clamp(val, min, max)
	return math.max(min, math.min(val, max))
end

function round(num, idp)
   	local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function convert(a, format)
	local f = format:lower()

	if f == "mb" then
		scoreRate = scoreAdd / 4
		return a / 1024
	else
		return a
	end
end

function getScoreType(a)
	if a >= 1024 then
		return "MB"
	else
		return "KB"
	end
end