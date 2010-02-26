-- Filename: goo.lua
-- Author: Luke Perkin
-- Date: 2010-02-25

-- Initialization
goo = {}
require 'MiddleClass'
require 'MindState'
require 'goo.animation.animation'

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
	
	if love.mouse.isDown('l') then
	else
		if self.dragState then
			self.dragState = false
			self:recurse('children',goo.object.updateBounds)
		end
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
function goo.object:updateBoundsRecursive()
	self:updateBounds()
	for k,v in pairs(self.children) do
		v:updateBoundsRecursive()
	end
end
function goo.object:recurse(key,func,...)
	local _tbl = arg or {}
	func(self, unpack(_tbl))
	for k,v in pairs(self[key]) do
		v:recurse(key,func,...)
	end
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
	self.dragState = false
end
function goo.panel:update(dt)
	super.update(self,dt)
	if self.dragState then
		self.x = love.mouse.getX() - self.dragOffsetX
		self.y = love.mouse.getY() - self.dragOffsetY
		self:updateBounds()
	end
end
function goo.panel:draw()
	love.graphics.setColor(80,80,80,255)
	goo.graphics.roundrect( 'fill', self.x, self.y, self.w, self.h, 10, 10 )
	love.graphics.setColor(255,255,255,255)
	love.graphics.print( self.title, self.x + 10, self.y + 15 )
	love.graphics.line( self.x, self.y + 20, self.x + self.w, self.y + 20)
end
function goo.panel:mousepressed(x,y,button)
	if x > self.bounds.x1 and x < self.bounds.x2 and y > self.bounds.y1 and y < self.bounds.y1+15 then
		if not self.dragState then
			self.dragOffsetX = x - self.x
			self.dragOffsetY = y - self.y
		end
		self.dragState = true
	end
end
function goo.panel:mousereleased(x,y,button)
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
function goo.close:mousepressed(x,y,button)
	if button == 'l' then self.parent:destroy() end
end
function goo.close:updateBounds()
	local x, y = self:getRelativePos()
	self.bounds.x1 = x
	self.bounds.y1 = y-10
	self.bounds.x2 = x+10
	self.bounds.y2 = y
end

-- BUTTON
goo.button = class('goo button', goo.object)
function goo.button:initialize( parent )
	super.initialize(self)
	if parent then
		table.insert(parent.children,self)
		self.parent = parent
	end
	self.text = "button"
	self.borderStyle = 'line'
	self.backgroundColor = {0,0,0,255}
	self.borderColor = {255,255,255,255}
	self.textColor = {255,255,255,255}
	self.spacing = 5
end
function goo.button:draw()
	local x, y = self:getRelativePos()
	love.graphics.setColor( unpack(self.backgroundColor) )
	love.graphics.rectangle( 'fill', x-2, y, self.w, self.h)
	love.graphics.setColor( unpack(self.borderColor) )
	love.graphics.rectangle( 'line', x-2, y, self.w, self.h)
	love.graphics.setColor( unpack(self.textColor) )
	love.graphics.print( self.text, x, y+self.h-self.spacing)
end
function goo.button:enterHover()
	self.backgroundColor = {0,200,50,255}
end
function goo.button:exitHover()
	self.backgroundColor = {0,0,0,255}
end
function goo.button:setText( text )
	self.text = text
	self:updateBounds()
end
function goo.button:sizeToContents()
	local _font = love.graphics.getFont()
	self.w = _font:getWidth(self.text) + self.spacing
	self.h = _font:getHeight() + self.spacing
	self:updateBounds()
end
function goo.button:mousepressed(x,y,button)
	if self.onClick then self:onClick(button) end
end
goo.button:getterSetter('backgroundColor')
goo.button:getterSetter('borderColor')
goo.button:getterSetter('textColor')

function goo.load()
	goo.graphics = {}
	goo.graphics.roundrect = require 'goo.graphics.roundrect'
end

-- Logic
function goo.update(dt)
	for k,v in ipairs( goo.objects ) do
		if v.visible then v:update(dt) end
	end
	
	for k,v in ipairs( goo.animation.list ) do
		v:update(dt)
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
	for i=#goo.objects, 1, -1 do
		local v = goo.objects[i]
		if not v then return false end
		if v.visible and v.hoverState then 
			v:mousepressed(x, y, button)
			print(tostring(v.class))
			break
		end
	end
end

function goo.mousereleased( x, y, button )
	for i=#goo.objects, 1, -1 do
		local v = goo.objects[i]
		if not v then return false end
		if v.visible and v.hoverState then 
			v:mousereleased(x, y, button)
			break
		end
	end
end
