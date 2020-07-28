local graphics = love.graphics

local util = require("src.util")

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

function tilemap:setTile(tile, x, y) -- tile = reference to tile in self.tileset.tiles
	-- NOTE: fixed strange bug where y - 1 gets the collision state wanted but x + 1 gets the tile wanted
	self.map[util.getIndexFromXY(x + 1, y, self._y)] = tile
end

function tilemap:getTile(x, y)
	return self.map[util.getIndexFromXY(x + 1, y, self._y)]
end

function tilemap:draw()
	for i, tile in pairs(self.map) do 	-- NOTE: changed to pairs because ipairs wasn't necessary and caused problems with 
										-- gaps being stopped at, hence the rest of the tileset wouldn't be rendered
		local x, y = util.getXYFromIndex(i - 1, self._x, self._y)
		graphics.draw(self.tileset.image, tile, x * self.tileset.scale, y * self.tileset.scale)
	end
end

return tilemap
