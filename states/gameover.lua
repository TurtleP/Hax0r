function gameover_init()
	gameoversnd:play()

	gameoveroptions =
	{
		"Reload last save",
		"Return to main menu"
	}

	selectioni = 2
	if io.open("sdmc:/3ds/Hax0r/save.txt") then
		selectioni = 1
	end
	minselect = selectioni
end

function gameover_draw()
	love.graphics.setFont(introFont)

	love.graphics.setScreen("top")
	love.graphics.draw(gameoverimg, gameFunctions.getWidth() / 2 - gameoverimg:getWidth() / 2, 60)

	love.graphics.setScreen("bottom")

	for k = 1, 2 do
		if k == minselect then
			love.graphics.setColor(255, 255, 255)
		else
			love.graphics.setColor(127, 127, 127)
		end

		love.graphics.print(gameoveroptions[k], gameFunctions.getWidth() / 2 - introFont:getWidth(gameoveroptions[k]) / 2, 90 + (k - 1) * 40)
	end
end

function gameover_keypressed(key)
	if key == "cpaddown" then
		if selectioni < #gameoveroptions then
			selectioni = selectioni + 1
		else
			selectioni = minselect
		end
	elseif key == "cpadup" then
		if selectioni > minselect then
			selectioni = selectioni - 1
		else
			selectioni = #gameoveroptions
		end
	end

	if key == "a" then
		if selectioni == 1 then
			game_saveLoad()
		else
			gameFunctions.changeState("title")
		end
	end
end