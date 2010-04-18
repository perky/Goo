-------------------------------------------------------------
------ COLOR PICKER.
-------------------------------------------------------------
goo.colorpick = class('goo color picker', goo.object)
goo.colorpick.image = {}

function goo.colorpick:initialize(parent)
	super.initialize(self,parent)
	self.w = goo.colorpick.image.colorbox:getWidth()
	self.h = goo.colorpick.image.colorbox:getHeight()
	self.selectedColor = nil
	self:updateBounds()
end
function goo.colorpick:setSkin()
	goo.colorpick.image.colorboxData = love.image.newImageData( goo.skin..'colorbox.png' )
	goo.colorpick.image.colorbox = love.graphics.newImage( goo.colorpick.image.colorboxData )
end
function goo.colorpick:draw()
	super.draw(self)
	local mx,my = love.mouse.getX(), love.mouse.getY()
	local x,y = self:getAbsolutePos()
	love.graphics.setColor(50,50,50,self:getOpacity())
	love.graphics.rectangle( 'fill', -5, -5, self.w+10, self.h+10)
	love.graphics.setColor(255,255,255,self:getOpacity())
	love.graphics.draw( self.image.colorbox, 0, 0 )
	if mx >= x and mx <= x+self.w and my >= y and my <= y+self.h then
		local r,g,b,a = self.image.colorboxData:getPixel( mx-x, my-y )
		love.graphics.setColor(50,50,50,self:getOpacity())
		love.graphics.rectangle( 'fill', mx-x-22, my-y-22, 24, 24)
		love.graphics.setColor(r,g,b,self:getOpacity())
		love.graphics.rectangle( 'fill', mx-x-20, my-y-20, 20, 20)
	end
	if self.selectedColor then
		love.graphics.setColor(40,40,40,self:getOpacity())
		love.graphics.rectangle( 'fill', self.selectedColor.x-22, self.selectedColor.y-22, 24, 24)
		love.graphics.setColor(self.selectedColor.r,self.selectedColor.g,self.selectedColor.b,self:getOpacity())
		love.graphics.rectangle( 'fill', self.selectedColor.x-20, self.selectedColor.y-20, 20, 20)
	end
end
function goo.colorpick:mousepressed(x,y,button)
	super.mousepressed(self,x,y,button)
	if not self.hoverState then return end
	local sx,sy = self:getAbsolutePos()
	local iw,ih = self.image.colorboxData:getWidth(), self.image.colorboxData:getHeight()
	--if x <= sx or y <= sy or x >= sx+iw or x >= sy+ih then return end
	local r,g,b = self.image.colorboxData:getPixel( x-sx, y-sy )
	self.selectedColor = {r=r,g=g,b=b,x=x-sx,y=y-sy}
end
function goo.colorpick:getColor()
	if not self.selectedColor then return 0,0,0 end
	return self.selectedColor.r, self.selectedColor.g, self.selectedColor.b
end
function goo.colorpick:clearSelected()
	self.selectedColor = nil
end

return goo.colorpick