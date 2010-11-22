-- CLOSE BUTTON
goo.close = class('goo close button', goo.object)
goo.close.image = {}

function goo.close:initialize( parent )
	super.initialize(self,parent)
	self.w = self.image.button:getWidth()
	self.h = self.image.button:getHeight()
end
function goo.close:setSkin()
	goo.close.image.button = love.graphics.newImage(goo.skin..'closebutton.png')
end
function goo.close:enterHover()
	self.color = self.style.colorHover
end
function goo.close:exitHover()
	self.color = self.style.color
end
function goo.close:draw()
	self:setColor( self.color )
	love.graphics.draw(self.image.button,0,0)
end
function goo.close:mousepressed(x,y,button)
	if button == 'l' then self.parent:destroy() end
end

return goo.close