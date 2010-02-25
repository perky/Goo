-- Filename: main.lua
-- Author: Luke Perkin
-- Date: 2010-02-25

-- Initialization
log = require 'scrlog'
require 'Goolib/goo'
require 'MiddleClass'
require 'MindState'


function love.load()
	goo.load()
end

-- Logic
function love.update(dt)
	goo.update()
end

-- Scene Drawing
function love.draw()
	goo.draw()
	log.draw()
end

-- Input
function love.keypressed( key, unicode )
	goo.keypressed( key, unicode )
end

function love.keyreleased( key, unicode )
	goo.keyreleased( key, unicode )
end

function love.mousepressed( x, y, button )
	goo.mousepressed( x, y, button )
	log.mousepressed( x, y, button )
end

function love.mousereleased( x, y, button )
	goo.mousereleased( x, y, button )
end