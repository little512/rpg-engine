local draw = {}
draw.__index = draw

function draw.new()
	return setmetatable({
		drawObjects = {
			background = {} -- background is always drawn first
		} -- objects to call :draw() on
	}, draw)
end

function draw:addLayer()
	local index = #self.drawObjects + 1

	table.insert(self.drawObjects, {})

	return index
end

function draw:removeLayer()
	local index = #self.drawObjects

	if index > 1 then
		table.remove(self.drawObjects, index)
	else
		print("can't remove layer 1")
	end

	return #self.drawObjects
end

function draw:getLayers()
	return #self.drawObjects
end

function draw:addObject(layer, key, obj, ...)
	local layers = #self.drawObjects

	if type(layer) ~= "string" then
		layer = (layer <= layers) and layer or layers
	end

	local args = {...}
	self.drawObjects[layer][key] = {(function(...)
		obj:draw(...)
	end), args}
end

function draw:removeObject(layer, key)
	local layers = #self.drawObjects
	if type(layer) ~= "string" then
		layer = (layer <= layers) and layer or layers
	end
	self.drawObjects[layer][key] = nil
end

function draw:draw()
	for k, o in pairs(self.drawObjects.background) do
		o[1](unpack(o[2]))
	end

	for i, l in ipairs(self.drawObjects) do
		for k, o in pairs(l) do
			o[1](unpack(o[2]))
		end
	end
end

local drawObject = draw.new()
drawObject:addLayer()

function love.draw()
	drawObject:draw()
end

return drawObject
