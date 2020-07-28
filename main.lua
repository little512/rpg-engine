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
		- add rooms (stationary cam, follow cam, doors)
		- add tile states (interactable)
		- add sprites

	other:
		- make level editor
		- work on UI: dialog, inventory, party
		- work on encounter mechanics
		- sfx, music
		- event triggers
--]]

-- constants
local config = require("src.config")
local whiteTextColor = {1, 1, 1, 1}
local blueTextColor = {(100 / 255), (100 / 255), (230 / 255), 1}
local cyanTextColor = {0, 1, 1, 1}
local collectionMode = "count"

-- variables
local showDebugInfo = false
local windowWidth, windowHeight = config.width, config.height

--classes
local tileset = require("src.tileset")
local tilemap = require("src.tilemap")
local player = require("src.player")
local character = require("src.character")
local collisionmap = require("src.collisionmap")

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
end

function love.load()
	startTime = timer.getTime()

	graphics.setDefaultFilter("nearest", "nearest", 1) -- turn off anti-aliasing, this is a pixelated game :)

	input:addHookReleased("escape", event.quit)
	input:addHookReleased("f1", toggleDebugInfo)
	input:addHookReleased("f9", util.debugInform)

	-- create tileset from image
	tileset_1 = tileset.new("data/img/tileset_1.png", 32) -- each tile is 32 pixels wide in this tileset
	-- create quads to use
	tileset_1:createTile("gradient", 1, 0, tileset_1.scale, tileset_1.scale)
	tileset_1:createTile("white", 1, 1, tileset_1.scale, tileset_1.scale)

	-- create tilemap from tileset
	tilemap_1 = tilemap.new(tileset_1, 20, 15)
	-- fill with gradient tile
	for i = 1, (20 * 15) do
		tilemap_1.map[i] = tileset_1.tiles.gradient
	end

	collisionmap_1 = collisionmap.new(20, 15, true)

	collisionmap_1:setCollisionState(collisionmap.states.NONPASSABLE, 1, 2)
	collisionmap_1:setCollisionState(collisionmap.states.NONPASSABLE, 2, 3)
	collisionmap_1:setCollisionState(collisionmap.states.NONPASSABLE, 3, 2)

	tilemap_1:setTile(tileset_1.tiles.white, 1, 2) -- set this tile to nil so this tile isn't drawn indicating a void (non passable)
	tilemap_1:setTile(tileset_1.tiles.white, 2, 3)
	tilemap_1:setTile(tileset_1.tiles.white, 3, 2)

	-- TODO: create a function in tilemap which automates the process of creating a
	-- canvas and drawing to it (probably tilemap:getCanvas())

	canvas_1 = graphics.newCanvas(20 * 32, 15 * 32) -- create canvas for our tiles

	graphics.setCanvas(canvas_1)

		tilemap_1:draw() -- draw tiles to the canvas
	
	graphics.setCanvas()

	player_1 = player.new()

	characterImage = graphics.newImage("data/img/plr.png")
	character_1 = character.new(player_1, characterImage)

	local _x, _y = character_1.character:getDimensions()

	characterImageX = _x
	characterImageY = _y

	character_1.x = characterImageX / (tilemap_1.tileset.scale / characterImageX)
	character_1.y = characterImageY / (tilemap_1.tileset.scale / characterImageY)

	player_1:registerControls()

	endTime = timer.getTime()
	loadTime = endTime - startTime
	print("Finished loading in " .. loadTime .. " seconds.")
end

local function movement(dt, collision)
	character_1:move(
		(character_1.absX * tilemap_1.tileset.scale) +
			characterImageX / (tilemap_1.tileset.scale / characterImageX),
		(character_1.absY * tilemap_1.tileset.scale) +
			characterImageY / (tilemap_1.tileset.scale / characterImageY),
		dt,
		collision)
end

function love.update(dt) -- TODO: make this function cleaner
	if character_1.player.inputting and not character_1.moving then
		movement(dt, collisionmap_1)
	elseif character_1.moving then
		movement(dt, collisionmap_1)
	end
end

function love.resize(w, h)
	windowWidth = w
	windowHeight = h
end

function love.draw()
	graphics.setColor(1, 1, 1, 1)

	graphics.push()

		graphics.translate(-character_1.x + (windowWidth / 2) -
				characterImageX / (tilemap_1.tileset.scale / characterImageX), 
			-character_1.y + (windowHeight / 2) -
				characterImageY / (tilemap_1.tileset.scale / characterImageY))
		graphics.draw(canvas_1)

		-- TODO: have two states for rooms; one follows the character, one stays stationary
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
