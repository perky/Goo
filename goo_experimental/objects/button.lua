local button = goo.newobject( 'button' )
button.backgroundState = {
	['off'] = 'backgroundColor',
	['over'] = 'backgroundColorHover',
	['click'] = 'backgroundColorClick'
}
button.textState = {
	['off'] = 'textColor',
	['over'] = 'textColorHover',
	['click'] = 'textColorHover'
}

function button:init()
	self:setbounds( 10, 10, 50, 50 )
	self.text = "Click me please."
end

function button:update(dt)
	self.base.update( self )
end

function button:setcolor( type, state )
	local colorpack = goo.skin[ self.name ][ button[ type ][ state ] ]
	if colorpack then love.graphics.setColor( unpack(colorpack) ) end
end

function button:draw()
	local font = self:getskinvar( 'textFont' )
	local fontH = self:getskinvar( 'textFont' ):getHeight()
	love.graphics.setFont( font )
	
	self:setcolor( 'backgroundState', self.hoverstate )
	love.graphics.rectangle( 'fill', 0, 0, self.w, self.h )
	self:setcolor( 'textState', self.hoverstate )
	love.graphics.printf( self.text, 0, (self.h/2)-fontH, self.w, 'center' )
end

function button:sizetotext( padding )
	local padding = padding or 5
	local font = self:getskinvar( 'textFont' )
	self.w = font:getWidth( self.text ) + ( padding*5 )
	self.h = font:getHeight() + ( padding*5 )
	self:updatebounds()
end

function button:mousepressed(x,y,button)
	self.hoverstate = 'click'
	self:onClick( x, y, button )
end

function button:onClick() end