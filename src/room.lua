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

		tilemapCanvas = _tile:getCanvas();

		scale = _scale;

		spritelist = {}; -- TODO: change this when actor class is implemented
		dirty = true; -- whether or not to redraw the canvas (should be dirty when instantiated to permit drawing)

		cameraMode = _cameraMode; -- true = follow, false = stationary
		stationaryX = _stationaryX or 0; -- offset from center
		stationaryY = _stationaryY or 0;
	}

	room._tilemapX, room._tilemapY = _room.maps.tile.x * _room.maps.tile.tileset.scale, _room.maps.tile.y * _room.maps.tile.tileset.scale

	return setmetatable(_room, room)
end

function room:addSprite(name, sprite)
	self.spritelist[name] = sprite

	self:makeDirty()
end

function room:removeSprite(name)
	self.spritelist[name] = nil

	self:makeDirty()
end

function room:updateSpriteCanvas(doNotClear)
	if self.dirty then
		if self.spriteCanvas and not doNotClear then
			self.spriteCanvas:renderTo(function()
				graphics.clear()
			end)
		end
	end
end

function room:drawSpriteCanvas(update)
	if self.dirty then
		local function _draw()
			for _, s in pairs(self.spritelist) do
				s:draw(s.precise)
			end
		end
	
		if not self.spriteCanvas then
			self.spriteCanvas = graphics.newCanvas(self._tilemapX, self._tilemapY)
		end

		self.spriteCanvas:renderTo(_draw)

		self.dirty = false
	end

	if self.spriteCanvas and not update then
		graphics.draw(self.spriteCanvas)
	end
end

function room:makeDirty() -- update sprite canvas
	self.dirty = true

	self:drawSpriteCanvas(true)
end

function room:drawTilemapCanvas()
	graphics.draw(self.tilemapCanvas)
end

function room:updateTilemapCanvas()
	self.tilemapCanvas = self.maps.tile:getCanvas(self.tilemapCanvas)
end

return room
