require "assets.player.player"
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 360
function love.load()
	camera = require "assets.camera.camera"
	anim8 = require 'assets.animations.anim8'
	cam = camera()
	love.window.setMode(SCREEN_WIDTH,SCREEN_HEIGHT,{vsync = true,fullscreen = false})
	sti = require 'assets.gameworld.sti'
	gameMap = sti('assets/gameworld/maps/testing.lua')

	player.LOAD()
end

function love.update(dt)
	player.UPDATE(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	cam:lookAt(player.x,player.y)
end

function love.draw()	
	cam:attach()
		gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
    	player.DRAW()
	cam:detach()
end