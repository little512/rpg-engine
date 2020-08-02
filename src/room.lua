-- holds maps and relevant character info

local room = {}

function room.new(_tile, _collision, _event, _startX, _startY, _cameraMode, _stationaryX, _stationaryY) -- TODO: create eventmap class
	return setmetatable({
		maps = {
			tile = _tile;
			collision = _collision;
			event = _event;
		};
		startX = _startX or 0;
		startY = _startY or 0;

		canvas = _tile:getCanvas();

		cameraMode = _cameraMode; -- true = follow, false = stationary
		stationaryX = _stationaryX or 0; -- offset from center
		stationaryY = _stationaryY or 0;
	}, room)
end

return room
