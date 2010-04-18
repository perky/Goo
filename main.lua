-- Filename: main.lua
-- Author: Luke Perkin
-- Date: 2010-02-25

-- Initialization
require 'middleclass'
require 'mindstate'
goo = require 'goo/goo'
anim = require 'anim/anim'

panels = {}
panels.name = { 'Open panel with button', 'Slide in panel with checkbox', 'Zoom in panel with textinput and colorpick', 'using the null object', 'Change skin'}

function love.load()
	goo:load()
	love.graphics.setBackgroundColor(255,255,255)
	
	createButtons()
end

-- Logic
function love.update(dt)
	goo:update(dt)
	anim:update(dt)
end

-- Scene Drawing
function love.draw()
	goo:draw()
end

-- Input
function love.keypressed( key, unicode )
	goo:keypressed( key, unicode )
end

function love.keyreleased( key, unicode )
	goo:keyreleased( key, unicode )
end

function love.mousepressed( x, y, button )
	goo:mousepressed( x, y, button )
end

function love.mousereleased( x, y, button )
	goo:mousereleased( x, y, button )
end

function createButtons()
	for i,v in ipairs( panels ) do
		local button = goo.button:new()
		button:setPos( -350, i*25 )
		button:setText( panels.name[i] )
		button:sizeToText()
		button.onClick = function(self,button)
			if button == 'l' then
				panels[i]()
			end
		end
		anim:new{ table = button, key = 'x', finish = 10, style = 'quartOut', delay = (i-1)/2 }:play()
	end
end

-- Open panel with button.
panels[1] = function()
	local panel = goo.panel:new()
	panel:setPos( 10, 10 )
	panel:setSize( 200, 200 )
	panel:setTitle( 'I am a panel' )

	local button = goo.button:new( panel )
	button:setPos( 10, 20 )
	print( button:getAbsolutePos() ) -- 20, 30
	button:setText( 'Click me' )
	button:sizeToText()
	button.onClick = function( self, button )
		print( 'I have been clicked' )
	end
	
	local redButton = goo.button:new( panel )
	redButton:setPos( 10, 100 )
	redButton:setText( 'My style has been overridden' )
	redButton:sizeToText( 10 )
	
	local redStyle = {
		backgroundColor = {255,0,0},
		backgroundColorHover = {125,0,0},
		borderColor = {0,0,0,0},
		borderColorHover = {0,0,0,0},
	}
	redButton:setStyle( redStyle )
end

-- Slide in panel with checkbox.
panels[2] = function()
	local panel = goo.panel:new()
	panel:setPos( 10, 50 )
	panel:setSize( 200, 200 )
	panel:setTitle( 'I am a panel' )

	local checkbox = goo.checkbox:new( panel )
	checkbox:setPos( 10, 20 )
	function checkbox:onClick( button )
		print( self.class.name .. ' has been clicked' )
	end
	function checkbox:enterHover()
		print( self.class.name .. ' enter hover')
	end
	
	local slideIn = anim:new{
		table	=	panel,
		key		=	'x',
		start	=	-250,
		finish	=	350,
		time	=	2,
		style	=	'expoOut'
	}
	slideIn:play()
	function slideIn:onFinish()
		checkbox:setChecked( true )
	end
	
end

-- Zoom in panel with textinput and colorpick
panels[3] = function()
	local testPanel = goo.panel:new()
	testPanel:setPos( 100, 50 )
	testPanel:setSize( 370, 500 )
	testPanel:setTitle( "This is a Color Panel." )
	testPanel:setOpacity( 10 )
	
	local colorPicker = goo.colorpick:new( testPanel )
	colorPicker:setPos(0,20)
	
	local input = goo.textinput:new( testPanel )
	input:setPos(3,486)
	input:setSize(360,20)
	input:setText('hello!')
	
	function colorPicker:onClick()
		local r,g,b = self:getColor()
		local str = string.format( 'Red = %i, Green = %i, Blue = %i', r,g,b)
		input:setText( str )
	end
	
	anim:easy( testPanel, 'xscale', 0, 1, 3, 'elastic')
	anim:easy( testPanel, 'yscale', 0.9, 1, 3, 'elastic')
	anim:easy( testPanel, 'opacity', 0, 255, 0.5, 'quadInOut')
end

-- Using the null object.
panels[4] = function()
	local group = goo.null()
	group:setPos( 300, 300 )
	local n = 1
	function group:update(dt)
		self:setPos( 300 + n, 300 )
		n=n+1
		self:recurse('children','updateBounds')
	end
	
	local panel_style = {
		titleColor = {0,0,0,0},
		seperatorColor = {0,0,0,0}
	}
	
	local p1 = goo.panel:new( group )
	p1:setPos( 0, 0 )
	p1:setSize( 50, 50 )
	p1:showCloseButton( false )
	p1:setStyle( panel_style )
	p1:setDraggable( false )
	
	local p2 = goo.panel:new( group )
	p2:setPos( 75, 0 )
	p2:setSize( 50, 50 )
	p2:setStyle( panel_style )
	p2:setDraggable( false )
end

-- Changing the style
panels[5] = function()
	local panel = goo.panel:new()
	panel:setPos( 100, 100 )
	panel:setSize( 200, 100 )
	
	local button = goo.button:new( panel )
	button:setPos( 15, 15 )
	button:setText( 'toggle theme' )
	button:sizeToText( 15 )
	
	themeSwitch = true
	function button:onClick()
		if themeSwitch then
			goo:setSkinAllObjects( 'dark' )
			themeSwitch = not themeSwitch
		else
			goo:setSkinAllObjects( 'default' )
			themeSwitch = not themeSwitch
		end
	end
end