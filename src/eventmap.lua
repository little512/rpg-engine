local eventmap = {}
eventmap.__index = eventmap

function eventmap.new(_x, _y)
	local _eventmap = {
		x = _x;
		y = _y;
		map = {};
		events = {}
	}

	for y = 1, _eventmap.y do
		_eventmap.map[y] = {}
		--for x = 1, _x do
			-- _eventmap.map[y][x]
		--end
	end

	return setmetatable(_eventmap, eventmap)
end

eventmap.types = {
	BUTTON = 0;
	CROSS = 1;
}

eventmap.interactions = {
	TOUCH = 0;
	ACTION = 1;
	ANY = 2;
}

function eventmap:registerEvent(name, _type, _interaction, _func, ...)
	self.events[name] = {func = _func;
		type = _type;
		interaction = _interaction;
		args = {...};
		setCoordinates = {}}
end

function eventmap:setEvent(name, x, y)
	local e = self.events[name]
	if e then
		self.map[y + 1][x + 1] = e
		table.insert(e.setCoordinates, {x, y})
	end
end

function eventmap:getEvent(x, y)
	return self.map[y + 1][x + 1]
end

function eventmap:clearEvent(x, y)
	local e = self.map[y + 1][x + 1]
	if e then
		self.map[y + 1][x + 1] = nil
		for i, v in ipairs(e.setCoordinates) do
			if v[1] == x and v[2] == y then
				table.remove(e.setCoordinates, i)
				return
			end
		end
	end
end

return eventmap
