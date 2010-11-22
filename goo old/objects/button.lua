-- BUTTON
goo.button = class('goo button', goo.object)
function goo.button:initialize( parent )
	super.initialize(self,parent)
	self.text = "button"
	self.borderStyle = 'line'
	self.backgroundColor = {0,0,0,255}
	self.borderColor = {255,255,255,255}
	self.textColor = {255,255,255,255}
	self.spacing = 5
	self.border = true
	self.background = true
end
function goo.button:draw()
	if self.background then
		self:setColor( self.backgroundColor )
		love.graphics.rectangle( 'fill', 0, 0, self.w , self.h )
	end
	if self.border then
		love.graphics.setLine( 1, 'rough' )
		self:setColor( self.borderColor )
		love.graphics.rectangle( 'line', 0, 0, self.w+2, self.h )
	end
	
	self:setColor( self.textColor )
	love.graphics.setFont( self.style.textFont )
	local fontW,fontH = self.style.textFont:getWidth(self.text or ''), self.style.textFont:getHeight()
	local ypos = ((self.h - fontH)/2)+(fontH*0.8)
	local xpos = ((self.w - fontW)/2)
	love.graphics.print( self.text, xpos, ypos )
end
function goo.button:enterHover()
	self.backgroundColor = self.style.backgroundColorHover
	self.borderColor = self.style.borderColorHover
	self.textColor = self.style.textColorHover
end
function goo.button:exitHover()
	self.backgroundColor = self.style.backgroundColor
	self.borderColor = self.style.borderColor
	self.textColor = self.style.textColor
end
function goo.button:mousepressed(x,y,button)
	if self.onClick then self:onClick(button) end
	self:updateBounds( 'children', self.updateBounds )
end
function goo.button:setText( text )
	self.text = text or ''
end
function goo.button:sizeToText( padding )
	local padding = padding or 5
	local _font = self.style.textFont or love.graphics.getFont()
	self.w = _font:getWidth(self.text or '') + (padding*2)
	self.h = _font:getHeight()  + (padding*2)
	self:updateBounds()
end
goo.button:getterSetter('border')
goo.button:getterSetter('background')

return goo.button