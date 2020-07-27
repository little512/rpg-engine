local input = {}
input.__index = input

function input.new()
	return setmetatable({
		inputHooks_pressed = {};
		inputHooks_released = {}
	}, input)
end

function input:addHookPressed(key, func, ...)
	local args = {...}
	self.inputHooks_pressed[key] = {(function(...)
		func(...)
	end), args}
end

function input:removeHookPressed(key)
	self.inputHooks_pressed[key] = nil
end

function input:addHookReleased(key, func, ...)
	local args = {...}
	self.inputHooks_released[key] = {(function(...)
		func(...)
	end), args}
end

function input:removeHookReleased(key)
	self.inputHooks_released[key] = nil
end

local inputObject = input.new()

function love.keypressed(key)
	local hook = inputObject.inputHooks_pressed[key]

	if hook then
		hook[1](unpack(hook[2]))
	end
end

function love.keyreleased(key)
	local hook = inputObject.inputHooks_released[key]

	if hook then
		hook[1](unpack(hook[2]))
	end
end

return inputObject
