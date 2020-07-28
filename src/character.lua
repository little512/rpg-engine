-- plug in player inputs to manage character movement

local timer = love.timer

local floor = math.floor

local character = {}
character.__index = character

local function lerp(p0, p1, dt)
	return (1 - dt) * p0 + dt * p1
end

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

function character:move(mx, my, dt)
	local function update()
		self.elap = self.elap + ((1 / self.speed) * dt)

		self.posX = lerp(self.x, mx, self.elap)
		self.posY = lerp(self.y, my, self.elap)

		self.x = floor(self.posX)
		self.y = floor(self.posY)
	end

	if not self.moving then
		self.moving = true

		self.absX = self.absX + self.player.dirX
		self.absY = self.absY + self.player.dirY

		update()
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
