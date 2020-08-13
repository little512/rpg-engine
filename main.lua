local audio =       love.audio
local data =        love.data
local event =       love.event
local font =        love.font
local graphics =    love.graphics
local image =       love.image
local joystick =    love.joystick
local keyboard =    love.keyboard
local love_math =   love.math
local mouse =       love.mouse
local physics =     love.physics
local sound =       love.sound
local system =      love.system
local thread =      love.thread
local timer =       love.timer
local touch =       love.touch
local video =       love.video
local window =      love.window

--[[ TODO: 
		X add tile sheets and tile maps
		X add playable character
		X add collision map (impassable, passable, etc)
		X add rooms (stationary cam, follow cam, doors)
		X add event tiles (button [standing], interactable [adjacent actionable])
		X add sprites

	other:
		- make actor class which gets assigned a sprite and defines sprite changing
		behavior (probably gets passed deltatime or current frame count)
		- make level editor
		- work on UI: dialog, inventory, party
		- sfx, music support
		- work on encounter mechanics
--]]

-- constants
local config 			= require("src.config")
local whiteTextColor 	= {1, 1, 1, 1}
local redTextColor 		= {1, (20 / 255), (20 / 255), 1}
local greenTextColor 	= {0, 1, (20 / 255), 1}
local blueTextColor 	= {(100 / 255), (100 / 255), (230 / 255), 1}
local cyanTextColor 	= {0, 1, 1, 1}
local collectionMode 	= "count"

-- variables
local showDebugInfo = false
local windowWidth, windowHeight = config.width, config.height

--classes
local tileset 		= require("src.tileset")
local tilemap 		= require("src.tilemap")
local player 		= require("src.player")
local character 	= require("src.character")
local collisionmap 	= require("src.collisionmap")
local room 			= require("src.room")
local eventmap		= require("src.eventmap")
local sprite		= require("src.sprite")

-- class singletons
local input = require("src.input")
local util = require("src.util")

-- variables to load
local loadTime
local startTime
local endTime
local finalTime

local tileset_1
local tilemap_1
local collisionmap_1
local canvas_1
local room_1
local eventmap_1
local sprite_1

local player_1
local character_1
local characterImage
local characterImageX, characterImageY

local function toggleDebugInfo()
	showDebugInfo = not showDebugInfo
end

local function printDebugInfo()
	local fps = math.floor(1 / timer.getDelta())
	local mem = math.floor(collectgarbage(collectionMode))

	graphics.print({whiteTextColor,
		"Current FPS: ",
		{(fps <= 45 and 1 or 0), (fps >= 30 and 1 or 0), (20 / 255), 1},
		fps}, 10, 10)

	graphics.print({whiteTextColor,
		"Average FPS: ",
		{(fps <= 45 and 1 or 0), (fps >= 30 and 1 or 0), (20 / 255), 1},
		timer.getFPS()}, 10, 25)

	graphics.print({whiteTextColor,
		"Memory (kB): ",
		blueTextColor,
		mem}, 10, 40)

	graphics.print({whiteTextColor,
		"Axis: ",
		cyanTextColor,
		player_1.dirX,
		whiteTextColor, ", ",
		cyanTextColor,
		player_1.dirY}, 10, 55)

	graphics.print({whiteTextColor,
		"AbsPos: ",
		cyanTextColor,
		character_1.absX,
		whiteTextColor, ", ",
		cyanTextColor,
		character_1.absY}, 10, 70)

	graphics.print({whiteTextColor,
		"MoveState: ",
		(character_1.moving and greenTextColor or whiteTextColor),
		(character_1.moving and "moving" or "still"),
		whiteTextColor, ", ",
		(character_1.running and greenTextColor or (character_1.moving and cyanTextColor or whiteTextColor)),
		(character_1.running and "running" or (character_1.moving and "N/A" or "N/A"))}, 10, 85)
	
	graphics.print({whiteTextColor,
		"LerpInfo: ",
		{1 - (character_1.elap), 1, 1 - (character_1.elap), 1},
		tostring(character_1.elap):sub(0,5),
		whiteTextColor, ", ",
		cyanTextColor,
		character_1.x,
		whiteTextColor, ", ",
		cyanTextColor,
		character_1.y}, 10, 100)

	graphics.print({whiteTextColor,
		"DiagonalInfo: ",
		cyanTextColor,
		tostring(character_1.player.diagonal),
		whiteTextColor, ", ",
		cyanTextColor,
		tostring(character_1.player.direction),
		whiteTextColor, ", ",
		cyanTextColor,
		character_1.player.ambiguity}, 10, 115)

	graphics.print({whiteTextColor,
		"ButtonState: ",
		(player_1.AButton and greenTextColor or whiteTextColor),
		"A",
		whiteTextColor, ", ",
		(player_1.BButton and redTextColor or whiteTextColor),
		"B"}, 10, 130)

	graphics.print({whiteTextColor,
		"LoadTime: ",
		greenTextColor,
		tostring(loadTime):sub(0,5),
		whiteTextColor,
		" seconds"}, 10, windowHeight - 35)

	graphics.print({whiteTextColor,
		"Version: ",
		cyanTextColor,
		config.version_major,
		whiteTextColor, ".",
		cyanTextColor,
		config.version_minor,
		whiteTextColor, ".",
		cyanTextColor,
		config.version_patch .. " ",
		greenTextColor, 
		config.version_suffix}, 10, windowHeight - 20)
end

function love.load()
	startTime = timer.getTime()

	graphics.setDefaultFilter("nearest", "nearest", 1) -- turn off anti-aliasing, this is a pixelated game :)

	input:addHookReleased("escape", event.quit)
	input:addHookReleased("f9", util.debugInform)

	-- create tileset from image
	tileset_1 = tileset.new("data/img/tileset_1.png", 32) -- each tile is 32 pixels wide in this tileset
	-- create quads to use
	tileset_1:createTile("gradient", 1, 0, tileset_1.scale, tileset_1.scale)
	tileset_1:createTile("black", 0, 0, tileset_1.scale, tileset_1.scale)
	tileset_1:createTile("white", 1, 1, tileset_1.scale, tileset_1.scale)

	-- create tilemap from tileset
	tilemap_1 = tilemap.new(tileset_1, 20, 15, tileset_1.tiles.gradient)

	collisionmap_1 = collisionmap.new(20, 15, true)

	collisionmap_1:setCollisionState(collisionmap.states.NONPASSABLE, 1, 2)
	collisionmap_1:setCollisionState(collisionmap.states.NONPASSABLE, 2, 3)
	collisionmap_1:setCollisionState(collisionmap.states.NONPASSABLE, 3, 2)

	tilemap_1:setTile(tileset_1.tiles.white, 1, 2)
	tilemap_1:setTile(tileset_1.tiles.white, 2, 3)
	tilemap_1:setTile(tileset_1.tiles.white, 3, 2)

	tilemap_1:setTile(tileset_1.tiles.black, 2, 2)

	eventmap_1 = eventmap.new(20, 15)

	eventmap_1:registerEvent("event_1",
		eventmap.types.BUTTON,
		eventmap.interactions.ACTION,
		(function(character, s)
			print(s)
		end),
		"Event triggered!")

	eventmap_1:setEvent("event_1", 2, 2)

	room_1 = room.new(tilemap_1, collisionmap_1, eventmap_1, 0, 0, 1.5, true)

	player_1 = player.new()

	characterImage = graphics.newImage("data/img/plr.png")
	character_1 = character.new(player_1, characterImage, room_1)

	characterImageX, characterImageY = character_1.character:getDimensions()

	player_1:registerControls()

	input:addHookReleased("f1", toggleDebugInfo) -- wait for the info to be loaded

	sprite_1 = sprite.new("data/img/spritesheet_1.png", 32, 32, 2, 0)
	sprite_1:createQuad("dark_red", 0, 1, sprite_1.scaleX, sprite_1.scaleY)
	sprite_1:setQuad("dark_red")

	endTime = timer.getTime()
	loadTime = endTime - startTime
	print("Finished loading in " .. loadTime .. " seconds.")
end

-- [[ testing for switching rooms: ]]

local _debug_switchedRooms = false

function _debug_switchRooms()
	if not _debug_switchedRooms then
		graphics.setColor(1, 1, 1, 1)
		local _tile = tilemap.new(tileset_1, 5, 5, tileset_1.tiles.gradient)
		local _collision = collisionmap.new(_tile.x, _tile.y, true)
		local _room = room.new(_tile, _collision, nil, 0, 2, 1.5, false)

		character_1:setRoom(_room)

		_debug_switchedRooms = true
	else
		character_1:setRoom(room_1)
		_debug_switchedRooms = false
	end
end

input:addHookReleased("e", _debug_switchRooms)

-- [[ testing for switching rooms ]]

function love.update(dt)
	if (character_1.player.inputting and not character_1.moving) or character_1.moving then
		local _x, _y = util.absToPixels(character_1.absX,
			character_1.absY,
			character_1,
			tilemap_1.tileset)
		character_1:move(_x, _y, dt)
	end
end

function love.resize(w, h)
	windowWidth = w
	windowHeight = h
end

function love.draw()
	graphics.setColor(1, 1, 1, 1)

	graphics.push() -- TODO: add support for scaling
		local _scale = character_1.currentRoom.scale
		-- scale
		graphics.scale(_scale or 1)

		-- translate
		if character_1.currentRoom.cameraMode then
			graphics.translate((-character_1.x + ((windowWidth / _scale) / 2) -
					characterImageX / (tilemap_1.tileset.scale / characterImageX)),
				(-character_1.y + ((windowHeight / _scale) / 2) -
					characterImageY / (tilemap_1.tileset.scale / characterImageY)) )
		else
			graphics.translate(((windowWidth / _scale) / 2) -
				((character_1.currentRoom.maps.tile.x *
					character_1.currentRoom.maps.tile.tileset.scale) / 2) +
						character_1.currentRoom.stationaryX,
				((windowHeight / _scale) / 2) -
					((character_1.currentRoom.maps.tile.y *
						character_1.currentRoom.maps.tile.tileset.scale) / 2) +
							character_1.currentRoom.stationaryY)
		end

		-- draw background image

		-- draw tiles
		graphics.draw(character_1.currentRoom.canvas)

		-- draw sprites
		-- TODO: make a better way to do this, such as a list of sprites to render per room.

		sprite_1:draw() -- TODO: figure out the cause of sprite drifting (I suspect it has to do with subpixel values during camera lerping)

		-- draw character
		graphics.draw(character_1.character, character_1.x, character_1.y)

	graphics.pop()

	if showDebugInfo then
		printDebugInfo()
	end
end

-- local finals = {}

function love.quit()
	-- do something with finals

	finalTime = timer.getTime() - startTime
	print("Final uptime: " .. finalTime)
end
