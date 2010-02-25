-- Filename: goo.lua
-- Author: Luke Perkin
-- Date: 2010-02-25

-- Initialization
require 'MiddleClass'
require 'MindState'


goo = {}

goo.object = class('goo object')
goo.objects = {}
function goo.object:initialize()
	table.insert(goo.objects, self)
	self.x = 0
	self.y = 0
	self.h = 0
	self.w = 0
	self.visible = true
end
function goo.object:setPos( x, y )
	self.x = x or 0
	self.y = y or 0
end
function goo.object:setSize( w, h )
	self.w = w or 0
	self.h = h or 0
end
function goo.object:setVisible( bool )
	self.visible = bool
end
function goo.object:getRelativePos( x, y )
	local _x, _y
	local x, y = self.x or x, self.y or y
	if self.parent then
		_x, _y = self.parent.x, self.parent.y
	else
		_x, _y = 0, 0
	end
	return _x+x, _y+y
end
function goo.object:destroy()
	for k,v in pairs( goo.objects ) do
		if v == self then
			table.remove(goo.objects, k)
			self = nil
			return
		end
	end
end
-- PANEL
goo.panel = class('goo panel', goo.object)
function goo.panel:initialize()
	super.initialize(self)
	self.title = "title"
	self.close = goo.close:new(self)
end
function goo.panel:draw()
	love.graphics.setColor(80,80,80,255)
	goo.graphics.roundrect( 'fill', self.x, self.y, self.w, self.h, 10, 10 )
	love.graphics.setColor(255,255,255,255)
	love.graphics.print( self.title, self.x + 10, self.y + 15 )
	love.graphics.line( self.x, self.y + 20, self.x + self.w, self.y + 20)
end
function goo.panel:setTitle( title )
	self.title = title
end
function goo.panel:setPos( x, y )
	super.setPos(self, x, y)
	self:setClosePos()
end
function goo.panel:setSize( w, h )
	super.setSize(self, w, h)
	self:setClosePos()
end
function goo.panel:setClosePos()
	self.close:setPos( self.w - 15, 15 )
end
-- STATIC TEXT
goo.text = class('goo static text', goo.object)
function goo.text:initialize( parent )
	super.initialize(self)
	self.parent = parent
	self.text = "no text"
end
function goo.text:draw()
	local x, y = self:getRelativePos()
	love.graphics.print( self.text, x, y )
end
function goo.text:setText( text )
	self.text = text or ""
end
-- CLOSE BUTTON
goo.close = class('goo close button', goo.object)
function goo.close:initialize( parent )
	super.initialize(self)
	self.parent = parent
end
function goo.close:update(dt)
end
function goo.close:draw()
	local x, y = self:getRelativePos()
	love.graphics.setColor(255,255,255,255)
	love.graphics.print('x', x, y)
end
function goo.close:mousereleased(x,y,button)
end

testPanel = goo.panel:new()
testPanel:setPos( 50, 50 )
testPanel:setSize( 200, 100 )
testPanel:setTitle( "This is a test panel." )

testText = goo.text:new( testPanel )
testText:setPos( 20, 40 )
testText:setText( 'hello' )


function goo.load()
	goo.graphics = {}
	goo.graphics.roundrect = require 'goolib/parts/roundrect'
end

-- Logic
function goo.update(dt)
	for k,v in ipairs( goo.objects ) do
		if v.visible then v:update(dt) end
	end
end

-- Scene Drawing
function goo.draw()
	for k,v in ipairs( goo.objects ) do
		if v.visible then v:draw() end
	end
end

-- Input
function goo.keypressed( key, unicode )
	for k,v in ipairs( goo.objects ) do
		if v.visible then v:keypressed(key, unicode) end
	end
end

function goo.keyreleased( key, unicode )
	for k,v in ipairs( goo.objects ) do
		if v.visible then v:keypressed(key, unicode) end
	end
end

function goo.mousepressed( x, y, button )
	for k,v in ipairs( goo.objects ) do
		if v.visible then v:mousepressed(x, y, button) end
	end
end

function goo.mousereleased( x, y, button )
	for k,v in ipairs( goo.objects ) do
		if v.visible then v:mousepressed(x, y, button) end
	end
end