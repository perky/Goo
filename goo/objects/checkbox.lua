-- CHECKBOX
goo.checkbox = class('goo checkbox', goo.object)
goo.checkbox.image = {}

function goo.checkbox:initialize(parent)
	super.initialize(self,parent)
	self:setSkin()
	self.checkState = 'unchecked'
	self.w = 16
	self.h = 16
end
function goo.checkbox:setSkin()
	goo.checkbox.image.unchecked = love.graphics.newImage( goo.skin..'checkbox_unchecked.png' )
	goo.checkbox.image.checked = love.graphics.newImage( goo.skin..'checkbox_checked.png' )
end
function goo.checkbox:draw(x,y)
	self:setColor( 255,255,255 )
	love.graphics.draw(self.image[self.checkState], x, y)
end
function goo.checkbox:mousepressed(x,y,button)
	super.mousepressed(self,x,y,button)
	if self.checkState == 'checked' then
		self.checkState = 'unchecked'
	else
		self.checkState = 'checked'
	end
end
function goo.checkbox:isChecked()
	if self.checkState == 'checked' then return true else return false end
end
function goo.checkbox:setChecked(bool)
	if bool then self.checkState = 'checked' else self.checkState = 'unchecked' end
end
function goo.checkbox:updateBounds()
	local x,y = self:getAbsolutePos()
	self.bounds.x1 = x
	self.bounds.y1 = y
	self.bounds.x2 = self.image[self.checkState]:getWidth() + x
	self.bounds.y2 = self.image[self.checkState]:getHeight() + y
end

return goo.checkbox