local input = require("src.input")

local abs = math.abs

local player = {}
player.__index = player

function player.new()
	return setmetatable({
		dirX = 0; 	-- input direction
		dirY = 0;

		controls = {
			up = "up";
			down = "down";
			left = "left";
			right = "right";
		
			sprint = "lshift";
		
			a = "z";
			b = "x";
		};

		ambiguity = 0; -- -1 for negative direction, 0 for no ambiguity, 1 for positive direction
		diagonal = false; -- true when wa, as, sd, dw held
		direction = nil; -- true for up/down, nil for no direction, false for left/right

		controlling = true;	-- is the player currently controlling the character?
		inputting = false;  -- whether or not the player is pressing a key
		holdingShift = false; -- whether or not the player is holding shift

		AButton = false;
		BButton = false;
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

	local function setButtons(b, p)
		if b then
			self.AButton = p
		else
			self.BButton = p
		end

		self.character:handleInputs(b, p)
	end
	
	local function registerControls()
		input:addHookPressed(self.controls.left, leftRight, true, true)
		input:addHookPressed(self.controls.right, leftRight, false, true)
		input:addHookPressed(self.controls.up, upDown, true, true)
		input:addHookPressed(self.controls.down, upDown, false, true)
	
		input:addHookReleased(self.controls.left, leftRight, false, false)
		input:addHookReleased(self.controls.right, leftRight, true, false)
		input:addHookReleased(self.controls.up, upDown, false, false)
		input:addHookReleased(self.controls.down, upDown, true, false)

		input:addHookPressed(self.controls.sprint, setShift, true)
		input:addHookReleased(self.controls.sprint, setShift, false)

		input:addHookPressed(self.controls.a, setButtons, true, true)
		input:addHookReleased(self.controls.a, setButtons, true, false)

		input:addHookPressed(self.controls.b, setButtons, false, true)
		input:addHookReleased(self.controls.b, setButtons, false, false)
	end

	registerControls()
end

return player
