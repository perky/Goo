-- Filename: goo.lua
-- Author: Luke Perkin
-- Date: 2010-02-25

-- Initialization
local goo = {}
--goo.animation = require 'goo.animation.animation'

goo.skin = 'goo/skins/default/'
GOO_SKINPATH = goo.skin
goo.style, goo.fonts = require( goo.skin .. 'style')

function goo:setSkin( skin_name )
	skin_name = skin_name or 'default'
	goo.skin = 'goo/skins/' .. skin_name .. '/'
	GOO_SKINPATH = goo.skin
	goo.style, goo.fonts = require( goo.skin .. 'style' )
end

function goo:setSkinAllObjects( skin_name )
	self:setSkin( skin_name )
	for k,v in pairs(self.objects) do
		v:setSkin()
	end
	for k,v in pairs(self.BASEOBJECT.children) do
		v:resetStyle()
	end
end

goo.base = class('goo')
function goo.base:initialize()
	self.visible = true
	self.parent = self
	self.children = {}
	self.x, self.y = 0, 0
	self.xscale, self.yscale = 1, 1
	self.mousehover = nil
end
function goo.base:update() 
	if self.mousehover then
		if not self.mousehover.hoverState then self.mousehover:enterHover() end
		self.mousehover.hoverState = true
	end
	self.mousehover = self 
end
function goo.base:draw() end
function goo.base:mousepressed() end
function goo.base:mousereleased() end
function goo.base:keypressed() end
function goo.base:keyreleased() end
function goo.base:getAbsolutePos() return 0,0 end
function goo.base:getRelativePos() return 0,0 end
function goo.base:getAbsoluteScale() return 1,1 end
function goo.base:getRelativeScale() return 1,1 end
function goo.base:enterHover() end
function goo.base:exitHover() end
function goo.base:setSkin() end

goo.object = class('goo object')
goo.objects = {}
function goo.object:initialize(parent)
	if parent then
		table.insert(parent.children,self)
		self.parent = parent
	else
		table.insert( goo.BASEOBJECT.children, self )
		self.parent = goo.BASEOBJECT
	end
	self.z = #self.parent.children
	
	if goo.style[self.class.name] then
		self.style = goo.style[self.class.name]
	end
	self.x = 0
	self.y = 0
	self.h = 0
	self.w = 0
	self.xscale = 1
	self.yscale = 1
	self.lastX = 0
	self.lastY = 0
	self.bounds = {x1=0,y1=0,x2=0,y2=0}
	self.color  = {255,255,255,255}
	self.children = {}
	self.visible = true
	self.hoverState = true
end

--- Destroys the object.
-- @class table
function goo.object:destroy()
	if self.parent then
		for k,v in pairs(self.parent.children) do
			if v == self then table.remove(self.parent.children,k) end
		end
	end
	for i,child in ipairs(self.children) do
		child:destroy()
	end
	self = nil
	return
end
function goo.object:update(dt)
	if self:inBounds( love.mouse.getPosition() ) then 
		goo.BASEOBJECT.mousehover = self
	else
		if self.hoverState then self:exitHover() end
		self.hoverState = false
	end
	
	if love.mouse.isDown('l') then
		-- Left mouse button pressed
	else
		if self.dragState then
			self.dragState = false
			self:recurse('children', 'updateBounds')
		end
	end
	
	if self.x ~= self.lastX or self.y ~= self.lastY then
		self:recurse('children', 'updateBounds')
	end
	
	self.lastX = self.x
	self.lastY = self.y
end
function goo.object:draw(x,y) 
	--love.graphics.push()
	--love.graphics.scale( self.xscale, self.yscale )
	--love.graphics.translate(x,y)
end
function goo.object:mousepressed(x,y,button)
	if self.hoverState and self.onClick then
		self:onClick(x,y,button)
	end
end
function goo.object:mousereleased(x,y,button)
	
end
function goo.object:keypressed() end
function goo.object:keyreleased() end
function goo.object:setPos( x, y )
	self.x = x or 0
	self.y = y or 0
	self:updateBounds()
end
function goo.object:setSize( w, h )
	self.w = w or self.w
	self.h = h or self.h
	self:updateBounds()
end
function goo.object:setScale( x, y )
	self.xscale = x or 1
	self.yscale = y or self.xscale
end
function goo.object:setVisible( bool )
	self.visible = bool
end
function goo.object:inBounds( x, y )
	local ax, ay = self:getAbsolutePos()
	if x > ax and x < ax + self.w and y > ay and y < ay + self.h then
		return true
	else
		return false
	end
end
-- DELETE:
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
function goo.object:enterHover() end
function goo.object:exitHover() end
function goo.object:updateBounds()
	local x, y = self:getAbsolutePos()
	local xs, ys = self:getAbsoluteScale()
	local xoff, yoff = self.xoffset or 0, self.yoffset or 0
	self.bounds.x1 = x + xoff
	self.bounds.y1 = y + yoff
	self.bounds.x2 = x + (self.w + xoff)*xs
	self.bounds.y2 = y + (self.h + yoff)*ys
end
function goo.object:recurse(key,func,...)
	local _tbl = arg or {}
	self[func](self, ...)
	for k,v in pairs(self.children) do
		v:recurse(key,func,...)
	end
end
function goo.object:setText( text )
	self.text = text
	self:updateBounds()
end
function goo.object:getAbsolutePos( x, y )
	local x, y = x or self.x, y or self.y
	local _x, _y = self.parent:getAbsolutePos()
	return _x+(x*self.parent.xscale), _y+(y*self.parent.yscale)
end
function goo.object:getAbsoluteScale( xscale, yscale )
	local xscale, yscale = xscale or self.xscale, yscale or self.yscale
	local _x, _y = self.parent:getAbsoluteScale()
	return _x*xscale, _y*yscale
end
function goo.object:getRelativePos( x, y )
	local x = x or 0
	local y = y or 0
	return (x-self.x), (y-self.y)
end
function goo.object:getRelativeScale( xscale, yscale )
	local xscale, yscale = xscale or 1, yscale or 1
	return xscale*self.xscale, yscale*self.yscale
end
function goo.object:sizeToContents()
	local _font = love.graphics.getFont()
	self.w = _font:getWidth(self.text) + (self.spacing or 0)
	self.h = _font:getHeight() + (self.spacing or 0)
	self.yoffset = -self.h
	self:updateBounds()
end
function goo.object:setStyle(style)
	local _style = self.style
	self.style = {}
	for k,v in pairs(_style) do
		self.style[k] = v
	end
	if type(style) == 'table' then
		for k,v in pairs(style) do
			self.style[k] = v
		end
		if self.styleDidUpdate then self:styleDidUpdate() end
		return true
	elseif type(style) == 'string' then
		for k,v in pairs(goo.style[style]) do
			self.style[k] = v
		end
		if self.styleDidUpdate then self:styleDidUpdate() end
		return true
	end
	return false
end
-- Resets the style.
function goo.object:resetStyle()
	self.style = goo.style[self.class.name]
	self:enterHover()
	self:exitHover()
end

function goo.object:removeFromParent()
	local size = #self.parent.children
	local tbl = self.parent.children
	tbl[self.z] = nil
	for i=self.z, size-1 do
		tbl[i] = tbl[i+1]
		tbl[i].z = i
	end
	tbl[size] = nil
end
function goo.object:addToParent( parent )
	self.parent = parent
	table.insert(parent.children,self)
	self.z = #self.parent.children
end

function goo.object:getOpacity()
	return self.opacity or self.parent.opacity or 255
end
function goo.object:setOpacity( opacity )
	self.opacity = opacity
end
function goo.object:setColor( a, b, c, d )
	if type(a) == 'table' then
		local op
		if a[4] then
			op = a[4]
		else
			op = self.opacity or self.parent.opacity or 255
		end
		love.graphics.setColor( a[1], a[2], a[3], op )
	else
		if d then
			love.graphics.setColor( a, b, c, d )
		else
			love.graphics.setColor( a, b, c )
		end
	end
end
function goo.object:setSkin()
end
--[[
function goo.object:setColor2(r,g,b,a)
	self.color = {r or self.color[1], g or self.color[2], b or self.color[3], a or self.color[4]}
end]]--

--
--
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--
-- Load
function goo:load()
	self.graphics = {}
	self.graphics.roundrect = require 'goo/graphics/roundrect'
	-- Baseobject is the master parent for all objects.
	self.BASEOBJECT = self.base:new()
	-- Load all objects
	local object_list = love.filesystem.enumerate( 'goo/objects' )
	for k,v in pairs( object_list ) do
		goo.objects[v] = require( 'goo/objects/'..v )
		if goo.objects[v] and goo.objects[v].setSkin then goo.objects[v]:setSkin() end
	end
end

-- Logic
function goo:update( dt, object )
	local object = object or self.BASEOBJECT
	object:update(dt)
	for k,child in pairs(object.children) do
		if child.visible then self:update(dt,child) end
	end
end

-- Scene Drawing
function goo:draw( x, y, object )
	local object = object or self.BASEOBJECT
	local x,y = x or 0, y or 0
	love.graphics.push()
	love.graphics.translate( x, y )
	love.graphics.scale( object.xscale, object.yscale )
		object:draw()
	
	for i,child in ipairs(object.children) do
		if child.visible then self:draw(child.x,child.y,child) end
	end
	
	love.graphics.pop()
end

function goo:debugdraw()
	local mx,my = love.mouse.getPosition( )
	local obj = self.BASEOBJECT.mousehover
	local x,y = obj:getAbsolutePos()
	local style = self.style['goo debug']
	
	local offx,offy = 10,10
	if mx > love.graphics.getWidth()-120 then offx = -(offx+100) end
	if my > love.graphics.getHeight()-65 then offy = -(offy+65) end
	
	love.graphics.setFont(style.textFont)
	love.graphics.setColor(unpack(style.backgroundColor))
	love.graphics.rectangle( 'fill', mx+offx-5, my+offy-15, 118,80)
	love.graphics.setColor(unpack(style.textColor))
	love.graphics.print( obj.class.name, mx+offx, my+offy )
	love.graphics.print( 'mouse: '..mx..', '..my, mx+offx, my+offy+20 )
	love.graphics.print( 'position: '..obj.x..', '..obj.y, mx+offx, my+offy+32 )
	love.graphics.print( 'relative: '..mx-x..', '..my-y, mx+offx, my+offy+44 )
	love.graphics.print( 'parent: '..mx-obj.parent.x..', '..my-obj.parent.y, mx+offx, my+offy+56 )
end

-- Input
function goo:keypressed( key, unicode, object )
	local object = object or self.BASEOBJECT
	local ret = false
	if object.visible then ret = object:keypressed(key, unicode) end
	for i,child in ipairs(object.children) do
		ret = self:keypressed(key, unicode, child)
	end
	return ret
end

function goo:keyreleased( key, unicode, object )
	local object = object or self.BASEOBJECT
	if object.visible then ret = object:keyreleased(key, unicode) end
	for i,child in ipairs(object.children) do
		local ret = self:keyreleased(key, unicode, child)
	end
	return ret
end

function goo:mousepressed( x, y, button )
	local object = self.BASEOBJECT.mousehover
	if object.visible then object:mousepressed( x, y, button ) end
end

function goo:mousereleased( x, y, button )
	local object = self.BASEOBJECT.mousehover
	if object.visible then object:mousereleased( x, y, button ) end
end

--Misc funcs
function goo.gradientRectangle(x1,y1,x2,y2,color1,color2)
	local _lines = y2-y1
	local _col = {}
	love.graphics.setLine(2,'smooth')
	for i=0, _lines do
		_col = lerpColor(color1,color2,i/_lines)
		love.graphics.setColor( unpack(_col) )
		love.graphics.line(x1,y1+i,x2,y1+i)
	end
end

function goo.lerpColor(color1,color2,t)
	local r = (color2[1] - color1[1]) * t + color1[1]
	local g = (color2[2] - color1[2]) * t + color1[2]
	local b = (color2[3] - color1[3]) * t + color1[3]
	local a = (color2[4] - color1[4]) * t + color1[4]
	return {r,g,b,a}
end

return goo