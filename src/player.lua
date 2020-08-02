local input = require("src.input")

local abs = math.abs

local player = {}
player.__index = player

function player.new()
	return setmetatable({
		dirX = 0; 	-- input direction
		dirY = 0;

		ambiguity = 0; -- -1 for negative direction, 0 for no ambiguity, 1 for positive direction
		diagonal = false; -- true when wa, as, sd, dw held
		direction = nil; -- true for up/down, nil for no direction, false for left/right

		controlling = true;	-- is the player currently controlling the character?
		inputting = false;  -- whether or not the player is pressing a key
		holdingShift = false; -- whether or not the player is holding shift
	}, player)
end

function player:registerControls()
	local function checkInputs()
		if (self.dirX == 0) and (self.dirY == 0) then
			self.inputting = false
			self.direction = nil
			self.ambiguity = abs(self.ambiguity)
		else
			self.inputting = true
		end

		if (self.dirX ~= 0) and (self.dirY ~= 0) then
			self.diagonal = true
		elseif (self.dirX ~= 0 and self.dirY == 0) or 
			(self.dirX == 0 and self.dirY ~= 0) then
			self.diagonal = false
		end
	end	

	local function leftRight(b, p)
		self.dirX = self.dirX - (b and 1 or -1)

		if p then
			self.direction = false
			self.ambiguity = self.dirX
		end

		checkInputs()
	end

	local function upDown(b, p)
		self.dirY = self.dirY - (b and 1 or -1)

		if p then
			self.direction = true
			self.ambiguity = self.dirY
		end

		checkInputs()
	end

	local function setShift(b)
		self.holdingShift = b
	end
	
	local function registerControls()
		input:addHookPressed("a", leftRight, true, true)
		input:addHookPressed("d", leftRight, false, true)
		input:addHookPressed("w", upDown, true, true)
		input:addHookPressed("s", upDown, false, true)
	
		input:addHookReleased("a", leftRight, false, false)
		input:addHookReleased("d", leftRight, true, false)
		input:addHookReleased("w", upDown, false, false)
		input:addHookReleased("s", upDown, true, false)

		input:addHookPressed("lshift", setShift, true)
		input:addHookReleased("lshift", setShift, false)
	end

	registerControls()
end

return player
