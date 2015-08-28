function title_init()
	introtimer = 0
	titleRects = {}

	for k = 1, 20 do
		titleRects[k] = newBackgroundLine()
	end

	titleThings = 
	{
		{"New user session", function() title_runCMD("game") end},
		{"Toggle fullscreen", function() title_runCMD("fullscreen") end},
		{"View credits", function() title_runCMD("credits") end},
		{"Exit terminal", function() title_runCMD("quit") end}
	}

	menui = 1

	titlestringi = 0
	titlestringrep = 0
	lastrep = 0

	gameTitle = "HAX0R?"
	gameName = "HAX0R?"

	cmdtimer = 0
	titlecmd = ""
	titledrawstring = ""
	cmdi = 0
	realcmd = ""

	cmdendtimer = 0
	runcmdfade = 1

	if mobileMode then
		table.remove(titleThings, 2)
	end
end

function replace_char(pos, str, r)
    return str:sub(1, pos-1) .. r .. str:sub(pos+1)
end

function title_update(dt)
	if introtimer < 0.6 then
		introtimer = introtimer + dt
		if introtimer < 1/60 then
			blipsnd:play()
		end
	else
		for k, v in pairs(titleRects) do
			v:update(dt)
		end

		if titlemusic:isStopped() then
			titlemusic:play()
		end

		if titlestringrep < 10/60 then
			titlestringrep = titlestringrep + dt
		else
			if lastrep ~= 0 then
				gameTitle = replace_char(lastrep, gameName, gameName:sub(lastrep, lastrep))
			end
			titlestringi = love.math.random(#gameMap)
			lastrep = titlestringi
			gameTitle = replace_char(lastrep, gameTitle, gameMap[lastrep])
			titlestringrep = 0
		end
	end

	if #titlecmd > 0 then
		if #titledrawstring < #titlecmd then
			if cmdtimer < 0.03 then
				cmdtimer = cmdtimer + dt
			else
				cmdi = cmdi + 1
				titledrawstring = titledrawstring .. titlecmd:sub(cmdi, cmdi)
				cmdtimer = 0
			end
		else
			if realcmd then
				cmdendtimer = cmdendtimer + dt
				runcmdfade = cmdendtimer%2

				if cmdendtimer > 2 then
					if realcmd == "quit" then
						love.event.quit()
					elseif realcmd == "game" then
						gameFunctions.changeState("game")
						titlemusic:stop()
					elseif realcmd == "fullscreen" then
						fullscreen = not fullscreen
						gameFunctions.fullScreen()
					elseif realcmd == "credits" then
						showCredits = true
					end

					titledrawstring = ""
					titlecmd = ""
					realcmd = ""
					cmdi = 0
					cmdtimer = 0
					cmdendtimer = 0
				end
			end
		end
	end
end

function title_draw()
	if introtimer < 1/60 then
		love.graphics.rectangle("fill", 0, (gameFunctions.getHeight() / 2) * scale - 1 * scale, gameFunctions.getWidth() * scale, 2 * scale)
	elseif introtimer > 1/60 and introtimer < 0.1 then
		love.graphics.rectangle("fill", 0, 0, gameFunctions.getWidth() * scale, gameFunctions.getHeight() * scale)
	elseif introtimer > 0.4 then
		for k, v in pairs(titleRects) do
			v:draw()
		end

		if not showCredits then
			love.graphics.setColor(255, 255, 255)
			love.graphics.setFont(mainFont)
			love.graphics.print(gameTitle, (gameFunctions.getWidth() / 2) * scale - mainFont:getWidth(gameTitle) / 2,  40 * scale)

			love.graphics.setFont(backgroundFont)

			local offset
			for k = 1, #titleThings do
				if menui == k then
					offset = backgroundFont:getWidth("> ")
				else
					offset = 0
				end
				love.graphics.print(titleThings[k][1], 1 * scale + offset, (120 + (k - 1) * 14) * scale)
			end

			love.graphics.print("> ", 1 * scale, (120 + (menui - 1) * 14) * scale)

			if #titledrawstring > 0 then
				love.graphics.print(titledrawstring, 1 * scale, gameFunctions.getHeight() * scale - backgroundFont:getHeight("~$" .. titledrawstring))

				love.graphics.setColor(255, 255, 255, 255 * runcmdfade)
				love.graphics.print("_", 1 * scale + backgroundFont:getWidth(titledrawstring), gameFunctions.getHeight() * scale - backgroundFont:getHeight("_"))
			end
		end

		if showCredits then
			for k = 1, #credits do
				love.graphics.print(credits[k], (gameFunctions.getWidth() / 2) * scale - backgroundFont:getWidth(credits[k]) / 2, (12 + (k - 1) * 14) * scale) 
			end
		end
	end
end

function title_keypressed(key)
	if key == controls["down"] then
		menui = math.min(menui + 1, #titleThings)
	end

	if key == controls["up"] then
		menui = math.max(menui - 1, 1)
	end

	if key == controls["jump"] then
		if not showCredits then
			titleThings[menui][2]()
		else
			showCredits = false
		end
	end

	if key == controls["pause"] then
		love.event.quit()
	end
end

function title_runCMD(s)
	titlecmd = "~$run " .. s
	realcmd = s
end