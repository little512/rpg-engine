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

return util
