-- adapted from sprite.lua

local image = love.image
local graphics = love.graphics

local sprite = {}
sprite.__index = sprite

function sprite.new(imagePath, _scaleX, _scaleY, _posX, _posY)
	return setmetatable({
		image = graphics.newImage(imagePath);

		scaleX = _scaleX or 1;
		scaleY = _scaleY or 1;

		posX = _posX or 0;
		posY = _posY or 0;

		quads = {};
		currentQuad = "";
	}, sprite)
end

function sprite:createQuad(name, x, y, sx, sy)
	self.quads[name] = graphics.newQuad((x * self.scaleX), (y * self.scaleY), sx, sy, self.image:getDimensions())

	return self
end

function sprite:createRawQuad(name, x, y, sx, sy) -- for when you have a complicated sprite sheet to chop up
	self.quads[name] = graphics.newQuad(x, y, sx, sy, self.image:getDimensions())

	return self
end

function sprite:getQuad(name)
	return self.quads[name]
end

function sprite:setQuad(name)
	if type(name) == "string" then
		self.currentQuad = self.quads[name]
	elseif type(name) == "Quad" then
		self.currentQuad = name -- not actually name
	end

	return self
end

function sprite:draw(precise)
	graphics.draw(self.image,
		self.currentQuad,
		precise and
			self.posX or
			((self.posX) * self.scaleX),
		precise and
			self.posY or
			((self.posY) * self.scaleY))
end

return sprite
