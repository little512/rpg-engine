local util = {}

function util.debugInform()
	print("debug mode activated")
	print([[enter "cont" to exit this prompt]])
	debug.debug()
end

function util.getIndexFromXY(x, y, sy)
	return x + (sy * y)
end

function util.getXYFromIndex(index, sx, sy)
	return (index % sy), math.floor(index / sy)
end

function util.lerp(p0, p1, dt)
	return (1 - dt) * p0 + dt * p1
end

return util
