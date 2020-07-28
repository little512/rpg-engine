-- adapted from tilemap.lua

local collisionmap = {}
collisionmap.__index = collisionmap

function collisionmap.new(x, y, _OOBIsNonPassable)
	return setmetatable({
		_x = x,
		_y = y,
		OOBIsNonPassable = _OOBIsNonPassable;
		map = {}
	}, collisionmap)
end

local function getIndexFromXY(x, y, sy)
	return x + (sy * y)
end

local function getXYFromIndex(index, sx, sy)
	return (index % sy), math.floor(index / sy)
end

collisionmap.states = { -- enum-type
	PASSABLE = 0;
	NONPASSABLE = 1;
}

function collisionmap:setCollisionState(state, x, y) 	-- NOTE: untested/undefined behavior when setting collision states
														-- out of bounds, this is discouraged.
	self.map[getIndexFromXY(x, y - 1, self._y)] = state
end

function collisionmap:getCollisionState(x, y)
	if self.OOBIsNonPassable then
		if (x < self._x) and (x > -1) and (y < self._y) and (y > -1) then
			return self.map[getIndexFromXY(x, y - 1, self._y)]
		else
			return collisionmap.states.NONPASSABLE
		end
	else
		return self.map[getIndexFromXY(x, y - 1, self._y)]
	end
end

return collisionmap
