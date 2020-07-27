local graphics = love.graphics

local tilemap = {}
tilemap.__index = tilemap

function tilemap.new(_tileset, y, x)
	return setmetatable({
		_x = x,
		_y = y,
		tileset = _tileset,
		map = {}
	}, tilemap)
end

local function getIndexFromXY(x, y, sy)
	return x + (sy * y)
end

local function getXYFromIndex(index, sx, sy)
	return (index % sy), math.floor(index / sy)
end

function tilemap:setTile(tile, x, y) -- tile = reference to tile in self.tileset.tiles
	self.map[getIndexFromXY(x, y - 1, self._y)] = tile
end

function tilemap:getTile(x, y)
	return self.map[getIndexFromXY(x, y - 1, self._y)]
end

function tilemap:draw()
	for i, tile in ipairs(self.map) do
		local x, y = getXYFromIndex(i - 1, self._x, self._y)
		graphics.draw(self.tileset.image, tile, x * self.tileset.scale, y * self.tileset.scale)
	end
end

return tilemap
