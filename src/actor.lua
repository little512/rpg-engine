local actor = {}
actor.__index = actor

function actor.new(_sprite, _data, _room)
	local _actor = setmetatable({
		sprite = _sprite;
		data = _data;
		room = _room;
		_accumulatedTime = 0;
		_workingTime = 0;
		_accumulatedFrames = 0;
	}, actor)

	_actor.room:addSprite(_actor.data.name, _actor.sprite)
	_actor.room:addActor(_actor.data.name, _actor)

	return _actor
end

local function incrementIndex(a)
	local max = #a.data.quadTable

	a.data.index = (max > 0 and (
		(a.data.index + 1 <= max) and a.data.index + 1 or 1
	) or 1)
end

local function _time(a, e)
	if a._workingTime >= a.data.divisor then
		a._workingTime = 0

		incrementIndex(a)

		a.sprite:setQuad(a.data.quadTable[a.data.index])

		a.room:makeSpriteCanvasDirty() -- updating this actor
	end
end

local function _frames(a, e)
	if a._accumulatedFrames % a.data.divisor == 0 then
		incrementIndex(a)

		a.sprite:setQuad(a.data.quadTable[a.data.index])

		a.room:makeSpriteCanvasDirty() -- updating this actor
	end
end

actor.dataParsingModes = {
	time = _time;
	frames = _frames;
}

function actor:update(dt, fc, ...)
	local extraData = {...}
	self._accumulatedTime = self._accumulatedTime + dt
	self._workingTime = self._workingTime + dt
	self._accumulatedFrames = self._accumulatedFrames + 1
	
	local dataOperation = actor.dataParsingModes[self.data.mode]

	if dataOperation then
		dataOperation(self, extraData)
	end
end

function actor:setRoom(_room)
	self.room:removeActor(self.data.name)
	self.room:removeSprite(self.data.name)

	self.room:addActor(self.data.name, self)
	self.room:addSprite(self.data.name, self.sprite)
end

return actor
