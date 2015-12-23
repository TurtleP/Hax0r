--[[
	BUTTON CONSTANTS

	Bottom face button (A).
	a
	
	Right face button (B).
	b
	
	Left face button (X).
	x
	
	Top face button (Y).
	y
	
	Back button.
	back
	
	Guide button.
	guide
	
	Start button.
	start
	
	Left stick click button.
	leftstick
	
	Right stick click button.
	rightstick
	
	Left bumper.
	leftshoulder
	
	Right bumper.
	rightshoulder
	
	D-pad up.
	dpup
	
	D-pad down.
	dpdown
	
	D-pad left.
	dpleft
	
	D-pad right.
	dpright
--]]

_JOYLIMIT = 1

local gameJoysticks = {}
function love.joystickadded(joyStick)
	if #gameJoysticks < _JOYLIMIT then
		local id = joyStick:getID()
		table.insert(gameJoysticks, joystick:new(joyStick, id))
	end
end

function love.joystickremoved(joyStick)
	for k, v in ipairs(gameJoysticks) do
		if joyStick:getID() == v.id then
			table.remove(gameJoysticks, k)
		end
	end
end

function love.gamepadaxis(joyStick, axis, value)
	for k, v in ipairs(gameJoysticks) do
		if joyStick:getID() == v.id then
			v:onAxis(axis, value)
		end
	end
end

function love.gamepadpressed(joyStick, button)
	for k, v in ipairs(gameJoysticks) do
		if joyStick:getID() == v.id then
			v:buttonPressed(button)
		end
	end
end

function love.gamepadreleased(joyStick, button)
	for k, v in ipairs(gameJoysticks) do
		if joyStick:getID() == v.id then
			v:buttonReleased(button)
		end
	end
end

function getJoystick(id)
	return gameJoysticks[id]
end

joystick = class("joystick")

function joystick:init(joyObject, id, onAxis, buttonPressed, buttonReleased)
	self.joy = joyObject
	self.id = id

	self.doAxis = onAxis or function(self, axis, value) end
	self.doPressed = buttonPressed or function(self, button) end
	self.doReleased = buttonReleased or function(self, button) end
end

function joystick:onAxis(axis, value)
	self:doAxis(axis, value)
end

function joystick:buttonPressed(button)
	self:doPressed(button)
end

function joystick:buttonReleased(button)
	self:doReleased(button)
end