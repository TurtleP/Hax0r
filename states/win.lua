function win_init()
	love.graphics.setFont(winFont)
	wintexts = {}

	wintimers = 
	{
		newTimer(1, function() addText("Booting local mach-- [WARN] PATH CORRUPT!", {255, 35, 0}) end),
		newTimer(4, function() addText("Checking BIOS..", {0, 148, 255}) end),
		newTimer(6, function() addText("Checking grub..", {128, 128, 128}) end),
		newTimer(8, function() addText("Checking filesystem on user@ludumdare33:/", {255, 106, 0}) end),
		newTimer(10, function() addText("Bad sector found on user@ludumdare33:/!", {255, 35, 0}) bgm_start:stop() bgm:stop() end),
		newTimer(12, function() addText("Initializing data..") end),
		newTimer(14, function() addText("Boot sector 0 at head position 0\nfilesystem is fully corrupt!", {255, 35, 0}, 10) end),
		newTimer(16, function() addText('"You cannot get rid of me."\n- H@#0R, your "monster" of a virus', {255, 255, 255}, 30) end),
		newTimer(20, function() wintexts = {} end)
	}
end

local virus = "    +     +  \n++\\+++/+\n++@+++@+\n+++++++++\n++++==+++\n+++++++++"
local virusi = 0
local virustimer = 0
local virusdraw = ""

function win_update(dt)
	for k, v in pairs(wintimers) do
		v:update(dt)
	end

	if #wintexts == 8 then
		virustimer = virustimer + dt
		if virustimer > 0.03 then
			virusi = virusi + 1
			virusdraw = virusdraw .. virus:sub(virusi, virusi)
			virustimer = 0
		end
	end
end

function win_draw()
	for k = 1, #wintexts do
		love.graphics.setColor(wintexts[k].color)
		love.graphics.print(wintexts[k].text, 1 * scale, (wintexts[k].offset * scale) + 1 * scale + (k - 1) * 10 * scale)
	end

	love.graphics.print(virusdraw, 1 * scale, 130 * scale)

	if #virusdraw == #virus and #wintexts == 0 then
		for k = 1, #credits do
			love.graphics.print(credits[k], (gameFunctions.getWidth() / 2) * scale - winFont:getWidth(credits[k]) / 2, (10 + (k - 1) * 10) * scale) 
		end
	end
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
	"Music made with PixiTracker",
	"",
	"Art made with Paint.NET",
	"",
	"Sounds made with BFXR",
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