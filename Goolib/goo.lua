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
	--table.insert(super.children, self)
	self.x = 0
	self.y = 0
	self.h = 0
	self.w = 0
	self.bounds = {x1=0,y1=0,x2=0,y2=0}
	self.color  = {255,255,255,255}
	self.children = {}
	self.visible = true
	self.hoverState = false
end
function goo.object:update(dt)
	if self:isMouseHover() then
		if not self.hoverState then self:enterHover() end
		self.hoverState = true
	else
		if self.hoverState then self:exitHover() end
		self.hoverState = false
	end
end
function goo.object:mousepressed()
end
function goo.object:mousereleased()
end
function goo.object:keypressed()
end
function goo.object:keyreleased()
end
function goo.object:setPos( x, y )
	self.x = x or 0
	self.y = y or 0
	self:updateBounds()
end
function goo.object:setSize( w, h )
	self.w = w or 0
	self.h = h or 0
	self:updateBounds()
end
function goo.object:setVisible( bool )
	self.visible = bool
end
function goo.object:setColor(r,g,b,a)
	self.color = {r or self.color[1], g or self.color[2], b or self.color[3], a or self.color[4]}
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
function goo.object:isMouseHover()
	if not self.bounds then return false end
	local x, y = love.mouse.getPosition()
	local x1, y1, x2, y2 = self.bounds.x1, self.bounds.y1, self.bounds.x2, self.bounds.y2
	if x > x1 and x < x2 and y > y1 and y < y2 then
		return true
	else
		return false
	end
end
function goo.object:enterHover()
end
function goo.object:exitHover()
end
function goo.object:updateBounds()
	local x, y = self:getRelativePos()
	self.bounds.x1 = x
	self.bounds.y1 = y
	self.bounds.x2 = x + self.w
	self.bounds.y2 = y + self.h
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
function goo.panel:mousepressed(x,y,button)
	print('panel clicked')
end
function goo.panel:setTitle( title )
	self.title = title
end
function goo.panel:setPos( x, y )
	super.setPos(self, x, y)
	self:setClosePos()
	self:updateBounds()
end
function goo.panel:setSize( w, h )
	super.setSize(self, w, h)
	self:setClosePos()
	self:updateBounds()
end
function goo.panel:setClosePos()
	self.close:setPos( self.w - 15, 15 )
end
function goo.panel:destroy()
	for k,v in pairs(self.children) do
		v:destroy()
	end
	super.destroy(self)
end
-- STATIC TEXT
goo.text = class('goo static text', goo.object)
function goo.text:initialize( parent )
	super.initialize(self)
	table.insert(parent.children, self)
	self.parent = parent
	self.text = "no text"
end
function goo.text:draw()
	local x, y = self:getRelativePos()
	love.graphics.setColor( unpack(self.color) )
	love.graphics.print( self.text, x, y )
end
function goo.text:setText( text )
	self.text = text or ""
end
-- CLOSE BUTTON
goo.close = class('goo close button', goo.object)
function goo.close:initialize( parent )
	super.initialize(self)
	table.insert(parent.children, self)
	self.parent = parent
end
function goo.close:enterHover()
	self.color = {255,0,0,255}
end
function goo.close:exitHover()
	self.color = {255,255,255,255}
end
function goo.close:draw()
	local x, y = self:getRelativePos()
	love.graphics.setColor( unpack(self.color) )
	love.graphics.print('x', x, y)
end
function goo.close:mousereleased(x,y,button)
	print("click")
	self.parent:destroy()
end
function goo.close:updateBounds()
	local x, y = self:getRelativePos()
	self.bounds.x1 = x
	self.bounds.y1 = y-10
	self.bounds.x2 = x+10
	self.bounds.y2 = y
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
	for k,v in ipairs_back( goo.objects ) do
		if v.visible and v:isMouseHover() then 
			v:mousepressed(x, y, button)
			break
		end
	end
end

function goo.mousereleased( x, y, button )
	for k,v in ipairs_back( goo.objects ) do
		if v.visible and v:isMouseHover() then 
			v:mousereleased(x, y, button)
			break
		end
	end
end

function ipairs_back(a)
	return ipairs_back_iter, a, #a
end
function ipairs_back_iter(a,i)
	i = i - 1
	local v = a[i]
	if v then
		return i, v
	end
end
