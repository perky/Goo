-- IMAGE OBJECT
goo.image = class('goo image', goo.object)
function goo.image:initialize( parent )
	super.initialize(self,parent)
	self.image = nil
	self.rotation = 0
end
function goo.image:updateBounds(x,y)
	
end
function goo.image:setImage( image )
	self.image = image
end
function goo.image:getImage()
	return self.image
end
function goo.image:loadImage( imagename )
	self.image = love.graphics.newImage( imagename )
end
function goo.image:draw( x, y )
	if self.image then
		self:setColor( self.style.imageTint )
		love.graphics.draw( self.image, x, y, self.rotation )
	end
end
goo.image:getterSetter( 'rotation', 0 )

return goo.image