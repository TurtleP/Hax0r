--[[About:
	LovePotion v1.0.1 Compatability Library by Jael Clark
	
	This library allows you to play or test your LovePotion games without the need for a 3ds or messy compatability code!
	When executed, this library will try to accurately run lovepotion code as much as possible!
	
	-

	Installation:
	1. Put 3ds.lua at the root of the project folder
	2. Copy & Paste the below code into love.load()
	
	if not (love.system.getOS() == '3ds') then require "3ds" end
	
	-
	
	3ds Screen Dimensions:
	Top - 400x240
	Bottom - 320x240
	
	-
	
	Enjoy!
]]

--[[Key Config:]]
local config = {}
--L&R Buttons
config["lbutton"] = "q"
config["rbutton"] = "e"

--ZL&ZR Buttons
config["lzbutton"] = "1"
config["rzbutton"] = "3"

--Circlepad
config["cpadup"] = "w"
config["cpaddown"] = "s"
config["cpadleft"] = "a"
config["cpadright"] = "d"

--Dpad
config["dup"] = ""
config["ddown"] = ""
config["dleft"] = ""
config["dright"] = ""

--Nub
config["cstickup"] = "kp2"
config["cstickdown"] = "kp5"
config["cstickleft"] = "kp4"
config["cstickright"] = "kp6"

--The Face Buttons
config["a"] = "u"
config["b"] = "i"
config["x"] = "o"
config["y"] = "p"

--Start & Select
config["start"] = "return"
config["select"] = "."


--[[Library Code:]]
local screen = "bottom"

love.graphics.setDefaultFilter("nearest", "nearest", 0)
love.window.setMode(400, 240 * 2)

--LovePotion Exclusive Functions
function love.graphics.setScreen(s)
	love.graphics.setScissor()
	love.graphics.origin()
	if s == "top" then
		love.graphics.setScissor(0,0,400,240)
		screen = "top"
	elseif s == "bottom" then
		love.graphics.setScissor(40,240,320,240)
		love.graphics.translate(40,240)
		screen = "bottom"
	end
end

function love.graphics.setDepth(depth)

end

function love.graphics.getScreen() return screen end

--Regular Functions
local oldclear = love.graphics.clear
function love.graphics.clear()
	love.graphics.setScissor()
	oldclear()
end

local oldisdown = love.keyboard.isDown
function love.keyboard.isDown(...)
	local arg = {...}
	for i=1, #arg do
		if config[arg[i]] then
			if oldisdown(config[arg[i]]) then
				return true
			end
		end
	end
end

local oldgetWidth = love.graphics.getWidth
function love.graphics.getWidth()
	if screen == "top" then
		return 400
	elseif screen == "bottom" then
		return 320
	end
end

local oldMouseGetPosition = love.mouse.getPosition
function love.mouse.getPosition()
	if love.graphics.getScreen() == "top" then
		return love.mouse.getX(), love.mouse.getY()
	else
		return love.mouse.getX() - 40, love.mouse.getY() - 240
	end
end

local oldgetHeight = love.graphics.getHeight
function love.graphics.getHeight() return 240 end

local oldgetDimensions = love.graphics.getDimensions
function love.graphics.getDimensions() return love.graphics.getWidth(),240 end

local oldsetColor = love.graphics.setColor
function love.graphics.setColor(r,g,b,a)
	local r2,g2,b2,a2 = love.graphics.getColor()
	local ra
	if a then
		ra = a
	else
		ra = a2
	end
	oldsetColor(r,g,b,ra)
end

local olddraw = love.graphics.draw
function love.graphics.draw(image, quad, x, y, r)
	if r then
		if r > 0 then
			olddraw(image,x + image:getWidth() / 2, y + image:getHeight() / 2, r, 1, 1, image:getWidth() / 2, image:getHeight() / 2)
		end
	else
		if not quad then
			olddraw(image, x, y)
		else
			olddraw(image, quad, x, y)
		end
	end
end

function love.window.getDisplayCount() return 2 end
--function love.system.getOS() return "3ds" end

--Callbacks
if love.mousepressed then
	local clamp = function(n,min,max) 
		if n < min then 
			return min 
		elseif n > max then 
			return max 
		else 
			return n 
		end 
	end

	local oldmousepress = love.mousepressed
	function love.mousepressed(x,y,b)
		if b == "l" then
			oldmousepress(clamp(x-40,0,320),clamp(y-240,0,240),"l")
		end
	end
end

if love.keypressed then
	local oldkeypress = love.keypressed
	
	function love.keypressed(key,r)
		local button
		for k,v in pairs(config) do
			if v == key then
				button = k
				break
			end
		end
		
		if button then
			oldkeypress(button,r)
		end
	end
end

if love.keyreleased then
	local oldkeyrelease = love.keyreleased
	
	function love.keyreleased(key,r)
		local button
		for k,v in pairs(config) do
			if v == key then
				button = k
				break
			end
		end
		
		if button then
			oldkeyrelease(button,r)
		end
	end
end

if love.draw then
	local olddraw = love.draw
	
	function love.draw()
		love.graphics.setColor(0,0,0)

			love.graphics.rectangle("fill",0,240,40,240)

			love.graphics.rectangle("fill",360,240,40,240)

			love.graphics.setColor(255,255,255)
			
		if screen == "top" then
			love.graphics.setScissor(0, 0, 400, 240)
		elseif screen == "bottom" then
			love.graphics.setScissor(40, 240, 320, 240)
			love.graphics.translate(40, 240)
		end
		olddraw()
	end
end