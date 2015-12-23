function win_init()
	love.graphics.setFont(consoleFont)
	wintexts = {}

	rebootsnd:play()

	wintimers = 
	{
		newTimer(1, function() addText("Booting local mach-- [WARN] PATH CORRUPT!", {255, 35, 0}) end),
		newTimer(4, function() addText("Checking BIOS..", {0, 148, 255}) end),
		newTimer(6, function() addText("Checking grub..", {128, 128, 128}) end),
		newTimer(8, function() addText("Checking filesystem on user@H@x0rPC:~$:/", {255, 106, 0}) end),
		newTimer(10, function() addText("Bad sector found on user@H@x0rPC:~$/!", {255, 35, 0}) love.audio.stop() errorsnd:play() end),
		newTimer(12, function() addText("Initializing data..") end),
		newTimer(14, function() addText("Boot sector 0 at head position 0.", {255, 35, 0}, 10) errorsnd:play() end),
		newTimer(16, function() addText("Filesystem is fully corrupt!", {255, 35, 0}, 10) end),
		newTimer(18, function() addText('"You cannot get rid of me."', {255, 255, 255}, 30) end),
		newTimer(20, function() addText('H@#0R, your "monster" of a virus', {255, 255, 255}, 30) end),
		newTimer(28, function() gameFunctions.changeState("title") end)
	}

	hax0rfade = 0
end

function newTimer(t, f)
	local timer = {}

	timer.time = t
	timer.func = f

	function timer:update(dt)
		if not self.enabled then
			if self.time > 0 then
				self.time = self.time - dt
			else
				self.func()
				self.enabled = true
			end
		end
	end

	return timer
end

function win_update(dt)
	for k, v in pairs(wintimers) do
		v:update(dt)
	end

	if #wintexts == 10 then
		hax0rfade = math.min(hax0rfade + 0.6 * dt, 1)
	end
end

function win_draw()
	love.graphics.setScreen("top")
	for k = 1, #wintexts do
		local r, g, b = unpack(wintexts[k].color)
		love.graphics.setColor(r, g, b, 255)
		love.graphics.print(wintexts[k].text, 1, (wintexts[k].offset) + 1 + (k - 1) * 18)
	end

	love.graphics.setScreen("bottom")

	love.graphics.setColor(255, 255, 255, 255 * hax0rfade)
	love.graphics.draw(hax0r, love.graphics.getWidth() / 2 - hax0r:getWidth() / 2, love.graphics.getHeight() / 2 - hax0r:getHeight() / 2)
end

function addText(t, color, offset)
	local c = color or {255, 255, 255}
	local off = offset or 0
	table.insert(wintexts, {text = t, color = c, offset = off})
end

credits = 
{
	":: Hax0r Credits ::",
	"",
	"A GAME MADE FOR LUDUM DARE #33",
	"",
	"Game and code by Jeremy S. Postelnek",
	"",
	":: Music ::",
	"Stephen Wayde",
	"",
	":: Art ::",
	"Jeremy Postelnek",
	"HugoBDesigner",
	"",
	":: Sounds ::",
	"Jeremy Postelnek",
	"",
	"Font used is Windows CMD",
	"",
	"",
	"",
	"",
	"This version has been polished",
	"since initial release.",
	"",
	"Check out my blog for other games:",
	"http://www.jpostelnek.blogspot.com/"
}