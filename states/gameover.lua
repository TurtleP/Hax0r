function gameover_init()
	love.audio.stop()
	
	gameoversnd:play()

	love.graphics.setBackgroundColor(140, 0, 0)

	local prompt = "Click"
	if mobileMode then
		prompt = "Touch"
	end

	errorStrings =
	{
		"If this problem persists, please contact",
		"the System Administator. For more details, check",
		"the Operations Manual for the error code:",
		"",
		"0x5669 0x7275 0x7320 0x6465 0x6C65 0x7465",
		"0x6420 0x6672 0x6F6D 0x2050 0x4300 0x0000",
		"",
		prompt .. " anywhere to cycle the power."
	}

	love.graphics.setFont(gameOverFont)
end

function gameover_draw()
	love.graphics.draw(gameoverimg, gameFunctions.getWidth() / 2 - gameoverimg:getWidth() / 2, gameFunctions.getHeight() * 0.05)

	for k = 1, #errorStrings do
		love.graphics.print(errorStrings[k], gameFunctions.getWidth() / 2 - gameOverFont:getWidth(errorStrings[k]) / 2, (gameFunctions.getHeight() * 0.40) + (k - 1) * 18)
	end
end

function gameover_keypressed(key)
	gameFunctions.changeState("title")
end

function gameover_mousepressed(x, y, button)
	gameFunctions.changeState("title")
end