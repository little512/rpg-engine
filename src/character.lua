-- plug in player inputs to manage character movement

local timer = love.timer

local floor = math.floor

local collisionmap = require("src.collisionmap")
local util = require("src.util")

local character = {}
character.__index = character

function character.new(_player, _character)
	return setmetatable({
		player = _player;
		character = _character; -- should be drawable, finer details later

		moving = false;		-- is the character currently moving between tiles? (if yes wait until no longer moving to buffer another movement)
		running = false; 	-- is the character running because a movement was started and the player was holding shift?
		speed = 0.25;		-- how many seconds in deltaTime should it take for the character to reach the destination
		runSpeed = 0.10;	-- how many seconds in deltaTime to subtract from speed when running

		elap = 0; 	-- elapsed time

		x = 0; 	-- pixel positions
		y = 0;

		_startX = 0;	-- internal variables for lerping
		_startY = 0;

		absX = 0;	-- coordinate positions
		absY = 0;
	}, character)
end

function character:move(mx, my, dt, collision)
	local function update()
		self.elap = self.elap + ((1 / (self.speed - (self.running and self.runSpeed or 0))) * dt)

		self.x = floor(util.lerp(self._startX, mx, self.elap))
		self.y = floor(util.lerp(self._startY, my, self.elap))
	end

	local function _move(np, pfX, pfY)
		if not self.moving then
			self.moving = true
		end

		self.running = (self.player.holdingShift)

		self.absX = self.absX +
			((not np) and (pfX and self.player.dirX or 0) or self.player.dirX)
		self.absY = self.absY +
			((not np) and (pfY and self.player.dirY or 0) or self.player.dirY)

		update()
	end

	local function _collision()
		self._startX = self.x
		self._startY = self.y

		if collision then
			local nextIntendedPositionX, nextIntendedPositionY =
				self.absX + self.player.dirX,
				self.absY + self.player.dirY

			local collisionStateX = collision:getCollisionState(nextIntendedPositionX, self.absY)
			local collisionStateY = collision:getCollisionState(self.absX, nextIntendedPositionY)

			local passableForX = 
				collisionStateX == collisionmap.states.PASSABLE or
				collisionStateX == nil -- treat nil as passable
			local passableForY = 
				collisionStateY == collisionmap.states.PASSABLE or
				collisionStateY == nil

			local nextIntendedState = collision:getCollisionState(nextIntendedPositionX, 
				nextIntendedPositionY)

			local normallyPassable = nextIntendedState == collisionmap.states.PASSABLE or 
				nextIntendedState == nil

			local cardinal = (
				(self.player.dirX ~= 0 and 
				self.player.dirY == 0) or 
				(self.player.dirX == 0 and 
				self.player.dirY ~= 0))

			local rules = -- TODO: make these optional
				-- possibly passable
				( normallyPassable or (passableForX or passableForY) ) 				and
				-- no empty movement directly into walls
				( not (not normallyPassable and cardinal) ) 						and
				-- no clipping into corners where X and Y are both passable		
				( not (not normallyPassable and (passableForX and passableForY)) ) 	and
				-- no clipping through corners where the NIP is passable
				( not (normallyPassable and (not passableForX and not passableForY)) )

			if rules then
				_move(normallyPassable, passableForX, passableForY)
			end
		else
			_move(true, true, true)
		end
	end

	if not self.moving then
		_collision()
	elseif self.elap >= 1 then
		self.elap = 0

		if not self.player.inputting then
			self.x = mx
			self.y = my

			self.moving = false
			self.running = false
		else
			_collision()
		end
	else
		update()
	end
end

return character
