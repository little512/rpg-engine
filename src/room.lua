-- holds maps and relevant character info

local graphics = love.graphics

local room = {}
room.__index = room

function room.new(_tile, _collision, _event, _startX, _startY, _scale, _cameraMode, _stationaryX, _stationaryY) -- TODO: create eventmap class
	local _room = {
		maps = {
			tile = _tile;
			collision = _collision;
			event = _event;
		};
		startX = _startX or 0;
		startY = _startY or 0;

		canvases = {};
		dirt = {
			tilemap = true;
			sprite = true;
		};

		scale = _scale;

		spritelist = {}; -- TODO: change this when actor class is implemented

		cameraMode = _cameraMode; -- true = follow, false = stationary
		stationaryX = _stationaryX or 0; -- offset from center
		stationaryY = _stationaryY or 0;
	}

	room._tilemapX, room._tilemapY = _room.maps.tile.x * _room.maps.tile.tileset.scale, _room.maps.tile.y * _room.maps.tile.tileset.scale

	return setmetatable(_room, room)
end

function room:addSprite(name, sprite)
	self.spritelist[name] = sprite

	self:makeSpriteCanvasDirty()
end

function room:removeSprite(name)
	self.spritelist[name] = nil

	self:makeSpriteCanvasDirty()
end

function room:updateSpriteCanvas(doNotClear)
	if self.dirt.sprite then
		if self.canvases.sprite and not doNotClear then
			self.canvases.sprite:renderTo(function()
				graphics.clear()
			end)
		end
	end
end

function room:drawSpriteCanvas(update)
	if self.dirt.sprite then
		local function _draw()
			for _, s in pairs(self.spritelist) do
				s:draw(s.precise)
			end
		end
	
		if not self.canvases.sprite then
			self.canvases.sprite = graphics.newCanvas(self._tilemapX, self._tilemapY)
		end

		self.canvases.sprite:renderTo(_draw)

		self.dirt.sprite = false
	end

	if self.canvases.sprite and not update then
		graphics.draw(self.canvases.sprite)
	end
end

function room:makeSpriteCanvasDirty() -- update sprite canvas
	self.dirt.sprite = true

	self:drawSpriteCanvas(true)
end

function room:drawTilemapCanvas(update)
	if self.dirt.tilemap then
		local function _draw()
			for y, row in ipairs(self.maps.tile.map) do
				for x, tile in ipairs(row) do
					graphics.draw(self.maps.tile.tileset.image, tile, (x - 1) * self.maps.tile.tileset.scale, (y - 1) * self.maps.tile.tileset.scale)
				end
			end
		end

		if not self.canvases.tilemap then 
			self.canvases.tilemap = graphics.newCanvas(self._tilemapX, self._tilemapY)
		end

		self.canvases.tilemap:renderTo(_draw)

		self.dirt.tilemap = false
	end

	if self.canvases.tilemap and not update then
		graphics.draw(self.canvases.tilemap)
	end
end

function room:updateTilemapCanvas()
	if self.dirt.tilemap and self.canvases.tilemap then
		print("clear tilemap")
		self.canvases.tilemap:renderTo(function() graphics.clear() end)
	end
end

function room:makeTilemapCanvasDirty()
	self.dirt.tilemap = true

	self:drawTilemapCanvas(true)
end

return room
