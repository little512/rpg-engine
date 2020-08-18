local actordata = {}
actordata.__index = actordata

function actordata.new(_mode, _divisor, _name)
	return setmetatable({
		mode = _mode or "time";
		divisor = _divisor or 2;
		name = _name;

		index = 1;
		quadTable = {}

		-- ideas for modes:
		-- 	frames: every time the accumulated frames is divisible by some number (e.g. 2 or 3) 
		--	increase an index number to index a table of quads, if idx > #quads then idx = 1
		-- 	time: every interval of time (e.g. one second), increase the index

	}, actordata)
end

function actordata:pushQuad(_quad)
	table.insert(self.quadTable, _quad)

	return self
end

function actordata:popQuad()
	table.remove(self.quadTable)

	return self
end

return actordata
