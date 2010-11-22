local base = {}

function base:new( parent )
	local instance = {}
	setmetatable( instance, self.meta )
	instance:setparent( parent )
	instance.visible = true
	instance.children = {}
	instance.AABB = {0,0,0,0}
	instance.x = 0
	instance.y = 0
	instance.w = 0
	instance.h = 0
	instance.hoverstate = 'off'
	goo.newinstance( instance, parent )
	instance:init( parent )
	return instance
end

function base:setparent( parent )
	if not parent then return end
	if self.parent then self.parent:removechild( self ) end
	self.parent = parent
	self.parent:addchild( self )
end

function base:addchild( child )
	table.insert( self.children, child )
end

function base:removechild( child )
	for k, existing_child in ipairs( self.children ) do
		if existing_child == child then table.remove( self.children, k ) end
	end
end

function base:init()
end

function base:update(dt)
	self:updatebounds()
	local mx, my = love.mouse.getPosition()
	local m_left = love.mouse.isDown('l')
	if self:inbounds( mx, my ) then
		if self.hoverstate ~= 'click' then
			self.hoverstate = 'over'
		end
	else
		self.hoverstate = 'off'
	end
end

function base:draw() end
function base:drawall()
	self:draw()
	for k, child in ipairs( self.children ) do
		child:drawall()
	end
end

function base:mousepressed()  self.hoverstate = 'click' end
function base:mousereleased() self.hoverstate = 'off'   end
function base:keypressed()  end
function base:keyreleased() end

function base:inbounds( x, y )
	local ax, ay = self.AABB[1], self.AABB[2]
	local bx, by = self.AABB[3], self.AABB[4]
	if x > ax and x < bx and y > ay and y < by then
		return true
	else	
		return false
	end
end

function base:setbounds( ax, ay, bx, by )
	self.AABB = {ax,ay,bx,by}
	self.x = ax
	self.y = ay
	self.w = bx-ax
	self.h = by-ay
end

function base:updatebounds()
	local ax, ay = self.x, self.y
	local bx, by = self.x + self.w, self.y + self.h
	self.AABB = {ax,ay,bx,by}
end

function base:setpos( x, y )
	self.x = x
	self.y = y
end

function base:setsize( w, h )
	self.w = w
	self.h = h
end

function base:setcolor( colorname )
	love.graphics.setColor( unpack( goo.skin[ self.name ][ colorname ] ) )
end

function base:getskinvar( varname )
	return goo.skin[ self.name ][ varname ]
end

return base