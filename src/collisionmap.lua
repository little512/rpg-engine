-- adapted from tilemap.lua

local util = require("src.util")

local collisionmap = {}
collisionmap.__index = collisionmap

function collisionmap.new(_x, _y, _OOBIsNonPassable)
	local _collisionmap = {
		x = _x,
		y = _y,
		OOBIsNonPassable = _OOBIsNonPassable;
		map = {}
	}

	for y = 1, _y do
		_collisionmap.map[y] = {}
		for x = 1, _x do
			_collisionmap.map[y][x] = 0
		end
	end

	return setmetatable(_collisionmap, collisionmap)
end

collisionmap.states = { -- enum-type
	PASSABLE = 0;
	NONPASSABLE = 1;
}

function collisionmap:setCollisionState(state, x, y)
	self.map[y + 1][x + 1] = state
end

function collisionmap:getCollisionState(x, y)
	if self.OOBIsNonPassable then
		if (x < self.x) and (x > -1) and (y < self.y) and (y > -1) then
			return self.map[y + 1][x + 1]
		else
			return collisionmap.states.NONPASSABLE
		end
	else
		return (self.map[y + 1] or {})[x + 1] -- hack to prevent indexing nil when OOB is passable
	end
end

return collisionmap
