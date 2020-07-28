local input = require("src.input")

local player = {}
player.__index = player

function player.new()
	return setmetatable({
		dirX = 0; 	-- input direction
		dirY = 0;

		controlling = true;	-- is the player currently controlling the character?
		inputting = false;  -- whether or not the player is pressing a key
		holdingShift = false; -- whether or not the player is holding shift
	}, player)
end

function player:registerControls()
	local function checkInputs()
		if (self.dirX == 0) and (self.dirY == 0) then
			self.inputting = false
		else
			self.inputting = true
		end
	end	

	local function leftRight(b)
		self.dirX = self.dirX - (b and 1 or -1)

		checkInputs()
	end
	
	local function upDown(b)
		self.dirY = self.dirY - (b and 1 or -1)

		checkInputs()
	end

	local function setShift(b)
		self.holdingShift = b
	end
	
	local function registerControls()
		input:addHookPressed("a", leftRight, true)
		input:addHookPressed("d", leftRight, false)
		input:addHookPressed("w", upDown, true)
		input:addHookPressed("s", upDown, false)
	
		input:addHookReleased("a", leftRight, false)
		input:addHookReleased("d", leftRight, true)
		input:addHookReleased("w", upDown, false)
		input:addHookReleased("s", upDown, true)

		input:addHookPressed("lshift", setShift, true)
		input:addHookReleased("lshift", setShift, false)
	end

	registerControls()
end

return player
