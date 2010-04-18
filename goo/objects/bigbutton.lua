-- BIG BUTTON
goo.bigbutton = class('goo big button', goo.object)
goo.bigbutton.image = {}
goo.bigbutton.image.right = love.graphics.newImage(goo.skin..'bigbutton_left.png')
goo.bigbutton.image.middle = love.graphics.newImage(goo.skin..'bigbutton_middle.png')
goo.bigbutton.image.left = love.graphics.newImage(goo.skin..'bigbutton_right.png')
function goo.bigbutton:initialize(parent)
	super.initialize(self,parent)
	self.checkState = 'unchecked'
	self:exitHover()
end
function goo.bigbutton:enterHover()
	self.buttonColor = self.style.buttonColorHover
	self.textColor = self.style.textColorHover
end
function goo.bigbutton:exitHover()
	self.buttonColor = self.style.buttonColor
	self.textColor = self.style.textColor
end
function goo.bigbutton:draw(x,y)
	local w = self.image.left:getWidth() - 5
	
	love.graphics.setColor( unpack(self.buttonColor) )
	love.graphics.draw( self.image.right, x, y )
	love.graphics.draw( self.image.middle, x+w, y, 0, self.w, 1)
	love.graphics.draw( self.image.left, x+self.w+w, y )
	
	love.graphics.setColor( unpack(self.textColor) )
	love.graphics.setFont( unpack(self.style.font) )
	love.graphics.printf( self.text, x+(self.w/2)-250+17, y+30, 500, "center" )
end
function goo.bigbutton:updateBounds()
	local imgH	  = goo.bigbutton.image.left:getHeight()
	local imgW	  = goo.bigbutton.image.left:getWidth()
	local x, y = self:getAbsolutePos()
	self.bounds.x1 = x
	self.bounds.y1 = y
	self.bounds.x2 = x + self.w + (imgW*2)
	self.bounds.y2 = y + imgH
end

return goo.bigbutton