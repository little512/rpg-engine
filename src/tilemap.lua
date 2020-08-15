local graphics = love.graphics

local util = require("src.util")

local tilemap = {}
tilemap.__index = tilemap

function tilemap.new(_tileset, _x, _y, filltile)
	local _tilemap = {
		x = _x,
		y = _y,
		tileset = _tileset,
		map = {}
	}

	for y = 1, _y do
		_tilemap.map[y] = {}
		for x = 1, _x do
			_tilemap.map[y][x] = filltile
		end
	end

	return setmetatable(_tilemap, tilemap)
end

function tilemap:setTile(tile, x, y) -- tile = reference to tile in self.tileset.tiles
	-- NOTE: fixed strange bug where y - 1 gets the collision state wanted but x + 1 gets the tile wanted
	self.map[y + 1][x + 1] = tile
end

function tilemap:getTile(x, y)
	return self.map[y + 1][x + 1]
end

return tilemap
