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

function tilemap:getCanvas()
	local function _draw()
		for y, row in ipairs(self.map) do
			for x, tile in ipairs(row) do
				graphics.draw(self.tileset.image, tile, (x - 1) * self.tileset.scale, (y - 1) * self.tileset.scale)
			end
		end
	end

	local _canvas = graphics.newCanvas(self.x * self.tileset.scale, self.y * self.tileset.scale) -- create canvas for our tiles

	graphics.setCanvas(_canvas)
		_draw() -- draw tiles to the canvas
	graphics.setCanvas()

	return _canvas
end

return tilemap
