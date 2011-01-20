-- PANEL
goo.panel = class('goo panel', goo.object)
goo.panel.image = {}

function goo.panel:initialize(parent)
	super.initialize(self,parent)
	self.title = "title"
	self.close = goo.close:new(self)
	self.dragState = false
	self.draggable = true
end
function goo.panel:setSkin()
	goo.panel.image.corner = love.graphics.newImage(goo.skin..'box_corner.png')
	goo.panel.image.edge = love.graphics.newImage(goo.skin..'box_edge.png')
end
function goo.panel:update(dt)
	super.update(self,dt)
	if self.dragState and self.draggable then
		self.x = love.mouse.getX() - self.dragOffsetX
		self.y = love.mouse.getY() - self.dragOffsetY
		--self:updateBounds()
	end
end
function goo.panel:drawbox(x,y)
	local cornerH = self.image.corner:getHeight()
	local cornerW = self.image.corner:getWidth()
	local edgeH	  = self.image.edge:getHeight()
	local edgeW	  = self.image.edge:getWidth()
	self:setColor( self.style.borderColor )
	love.graphics.draw( self.image.corner, -cornerH, -cornerH )
	love.graphics.draw( self.image.corner, self.w+cornerH, -cornerH, math.pi/2 )
	love.graphics.draw( self.image.corner, self.w+cornerH, self.h+cornerH, math.pi )
	love.graphics.draw( self.image.corner, -cornerH, self.h+cornerH, 3*math.pi/2 )
	
	love.graphics.draw( self.image.edge, 0, -edgeH, 0, self.w, 1)
	love.graphics.draw( self.image.edge, self.w+edgeH, 0, math.pi/2, self.h, 1)
	love.graphics.draw( self.image.edge, self.w, self.h+edgeH, math.pi, self.w, 1)
	love.graphics.draw( self.image.edge, -edgeH, self.h, 3*math.pi/2, self.h, 1)
	
	self:setColor( self.style.backgroundColor )
	love.graphics.rectangle('fill', 0, 0, self.w, self.h)
end
function goo.panel:draw( x, y )
	super.draw(self)
	self:drawbox()
	self:setColor( self.style.seperatorColor )
	love.graphics.setLine(1, 'smooth')
	love.graphics.line( 0, 8, self.w, 8)
	self:setColor( self.style.titleColor )
	love.graphics.setFont( self.style.titleFont )
	love.graphics.print( self.title, 0, 5)
end
function goo.panel:mousepressed(x,y,button)
	super.mousepressed(self,x,y,button)
	if self.hoverState then
		if not self.dragState then
			self.dragOffsetX = x - self.x
			self.dragOffsetY = y - self.y
		end
		self.dragState = true
		
		-- Move to top.
		if self.z < #self.parent.children then
			self:removeFromParent()
			self:addToParent( self.parent )
		end
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
	local a = self.image.edge:getHeight()/2
	self.close:setPos( self.w - 4, -a + 2 )
end
function goo.panel:setDraggable( draggable )
	self.draggable = draggable
end
function goo.panel:showCloseButton( bool )
	self.close:setVisible(bool)
end
function goo.panel:updateBounds()
	local edgeH	  = goo.panel.image.edge:getHeight()/2
	local x, y = self:getAbsolutePos()
	self.bounds.x1 = x - edgeH
	self.bounds.y1 = y - edgeH
	self.bounds.x2 = x + self.w + edgeH
	self.bounds.y2 = y + self.h + edgeH
end


return goo.panel