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

		moving = false;	-- is the character currently moving between tiles? (if yes wait until no longer moving to buffer another movement)
		speed = 0.25;	-- how many seconds in deltaTime should it take for the character to reach the destination

		elap = 0; 	-- elapsed time

		x = 0; 	-- pixel positions
		y = 0;

		absX = 0;	-- coordinate positions
		absY = 0;

		posX = 0;	-- used for lerp calculation
		posY = 0;
	}, character)
end

function character:move(mx, my, dt, collision)
	local function update()
		self.elap = self.elap + ((1 / self.speed) * dt)

		self.posX = util.lerp(self.x, mx, self.elap)
		self.posY = util.lerp(self.y, my, self.elap)

		self.x = floor(self.posX)
		self.y = floor(self.posY)
	end

	if not self.moving then
		local function _move(np, pfX, pfY)
			self.moving = true

			self.absX = self.absX +
				((not np) and (pfX and self.player.dirX or 0) or self.player.dirX)
			self.absY = self.absY +
				((not np) and (pfY and self.player.dirY or 0) or self.player.dirY)

			update()
		end

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
	else
		if self.elap >= 1 then -- done moving
			self.moving = false

			self.x = mx
			self.y = my

			self.elap = 0
		else
			update()
		end
	end
end

return character
