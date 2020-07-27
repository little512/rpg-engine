local image = love.image
local graphics = love.graphics

local tileset = {}
tileset.__index = tileset

function tileset.new(imagePath, scale)
	return setmetatable({
		image = graphics.newImage(imagePath);
		scale = scale;
		tiles = {};
	}, tileset)
end

function tileset:createTile(name, x, y, sx, sy)
	self.tiles[name] = graphics.newQuad((x * self.scale), (y * self.scale), sx, sy, self.image:getDimensions())
end

return tileset
