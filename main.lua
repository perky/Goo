-- Filename: main.lua
-- Author: Luke Perkin
-- Date: 2010-02-25

-- Initialization
log = require 'scrlog'
require 'goo.goo'
require 'MiddleClass'
require 'MindState'
love.graphics.setFont('oldsansblack.ttf')

function love.load()
	goo.load()
	testPanel = goo.panel:new()
	testPanel:setPos( 50, 50 )
	testPanel:setSize( 200, 100 )
	testPanel:setTitle( "This is a test panel." )

	testText = goo.text:new( testPanel )
	testText:setPos( 20, 40 )
	testText:setText( 'hello' )

	btn = goo.button:new( testPanel )
	btn:setPos( 20, 60)
	btn:sizeToContents()
	btn:setBorderColor({255,255,25,255})
	function btn:onClick( button )
		self:setBorderColor({0,255,0,255})
	end
	
	button = goo.button:new()
	button:setPos( 100, 300 )
	button:setText('blah')
	button:sizeToContents()

	local anim = goo.animation
	local a1 = anim:new{
		table	= button,
		key		= 'x',
		finish	= 300,
		time	= 4,
		style	= anim.style.elastic,
		stylevars = {0.02,2}
	}
	local a2 = anim:new{
		table	= button,
		key		= 'y',
		finish	= 100,
		time	= 3,
		style	= anim.style.elastic,
		stylevars = {0.02,2}
	}
	a1:play()
	a2:play()
	
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
	if key == 'a' then
		chainAnimation:pause()
		print(chainAnimation:getState())
	end
	if key == 's' then
		chainAnimation:play()
	end
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