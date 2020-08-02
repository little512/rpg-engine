-- plug in player inputs to manage character movement

local timer = love.timer

local collisionmap = require("src.collisionmap")
local util = require("src.util")

local min, max = math.min, math.max
local abs = math.abs

local rulesPassed = false
local shouldCheckCollision = true

local character = {}
character.__index = character

function character.new(_player, _character, _room) -- can construct character with a room argument to save a function call later
	local _character = {
		player = _player;
		character = _character; -- should be drawable, finer details later

		moving = false;		-- is the character currently moving between tiles? (if yes wait until no longer moving to buffer another movement)
		running = false; 	-- is the character running because a movement was started and the player was holding shift?
		speed = 0.25;		-- how many seconds in deltaTime should it take for the character to reach the destination
		runSpeed = 0.10;	-- how many seconds in deltaTime to subtract from speed when running

		currentRoom = _room;

		absX = 0;	-- coordinate positions
		absY = 0;

		elap = 0; 	-- elapsed time

		x = 0; 	-- pixel positions
		y = 0;

		_startX = 0;	-- internal variables for lerping
		_startY = 0;
	}

	if _room then
		local _x, _y = util.absToPixels(_room.startX,
			_room.startY,
			_character,
			_room.maps.tile.tileset)

		_character.x = _x
		_character.y = _y
	end

	return setmetatable(_character, character)
end

function character:move(mx, my, dt)
	if self.currentRoom then
		local function update()
			self.elap = self.elap + ((1 / (self.speed - (self.running and self.runSpeed or 0))) * dt)
	
			self.x = util.clamp(
				util.round(
					util.lerp(self._startX, mx, self.elap)), min(self._startX, mx), max(self._startX, mx))
			self.y = util.clamp(
				util.round(
					util.lerp(self._startY, my, self.elap)), min(self._startY, my), max(self._startY, my))
		end
	
		local function _move(np, pfX, pfY)
			if not self.moving then
				self.moving = true
			end
	
			self.running = self.player.holdingShift

			if not self.player.diagonal then
				self.absX = self.absX +
					((not np) and (pfX and self.player.dirX or 0) or self.player.dirX)
				self.absY = self.absY +
					((not np) and (pfY and self.player.dirY or 0) or self.player.dirY)
			else
				local correctedDirX, correctedDirY = self.player.dirX, self.player.dirY

				if self.player.direction ~= nil then
					if self.player.direction then -- up/down
						correctedDirX = 0
					else -- left/right
						correctedDirY = 0
					end
				end

				self.absX = self.absX +
					((not np) and (pfX and correctedDirX or 0) or correctedDirX)
				self.absY = self.absY +
					((not np) and (pfY and correctedDirY or 0) or correctedDirY)
			end
	
			update()
		end

		local function _reset()
			self.x = mx
			self.y = my

			self.moving = false
			self.running = false
		end

		rulesPassed = false

		local function _collision()
			--print("calculating collision")
			self._startX = self.x
			self._startY = self.y

			local collision = self.currentRoom.maps.collision
	
			if collision then
				local nextIntendedDirectionX, nextIntendedDirectionY = ((self.player.diagonal == true) and
						(self.player.direction == true) and 0 or self.player.dirX),
					((self.player.diagonal == true) and
						(self.player.direction == false) and 0 or self.player.dirY)

				local nextIntendedPositionX, nextIntendedPositionY =
					self.absX + nextIntendedDirectionX,
					self.absY + nextIntendedDirectionY
	
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

				local cardinal = ((nextIntendedDirectionX ~= 0 and
					nextIntendedDirectionY == 0) or
					(nextIntendedDirectionX == 0 and
					nextIntendedDirectionY ~= 0))
	
				rulesPassed = -- TODO: make these optional
					-- possibly passable
					( normallyPassable or (passableForX or passableForY) ) 				and
					-- no empty movement directly into walls
					( not (not normallyPassable and cardinal) ) 						and
					-- no clipping into corners where X and Y are both passable		
					( not (not normallyPassable and (passableForX and passableForY)) ) 	and
					-- no clipping through corners where the NIP is passable
					( not (normallyPassable and (not passableForX and not passableForY)) )

				if rulesPassed then
					--print("rules passed")
					_move(normallyPassable, passableForX, passableForY)
				else
					--print("rules didn't pass")
					_reset()
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
				_reset()
			else
				_collision()
			end
		else
			update()
		end
	else
		print("no room set for character!")
	end
end

function character:setRoom(_room)
	self.currentRoom = _room

	self.absX, self.absY = _room.startX, _room.startY
	self.x, self.y = util.absToPixels(self.absX, self.absY, self, self.currentRoom.maps.tile.tileset)

	self.elap = 0

	self.moving = false
	self.running = false
end

return character
