local floor = math.floor
local sign = math.sign
local min, max = math.min, math.max

local util = {}

function util.debugInform()
	print("debug mode activated")
	print([[enter "cont" to exit this prompt]])
	debug.debug()
end

function util.lerp(p0, p1, dt)
	return (1 - dt) * p0 + dt * p1
end

function util.absToPixels(x, y, character, tileset)
	local characterImageX, characterImageY = character.character:getDimensions()

	return (x * tileset.scale) +
		characterImageX / (tileset.scale / characterImageX),
	(y * tileset.scale) +
		characterImageY / (tileset.scale / characterImageY)
end

function util.sign(n)
	return n > 0 and 1 or n < 0 and -1 or 0
end

function util.round(n)
	return floor(n + (0.5 * util.sign(n)))
end

function util.clamp(n, low, high)
	return min(max(n, low), high)
end

return util
