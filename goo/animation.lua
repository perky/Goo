-- Filename: animation.lua
-- Author: Luke Perkin
-- Date: 2010-02-26

function ANIM_LINEAR( t, b, c, d )
	return b + c*t/d
end

function ANIM_QUAD_INOUT( t, b, c, d )
	local p = t/(d/2)
	if p < 1 then return c/2*p*p + b end
	return -c/2 * ((p-1)*(p-3)-1) + b
end

goo.animation = class('goo animation', StatefulObject)
goo.animation.list = {}
goo.animation.lastTime = 0
function goo.animation:initialize(arg)
	super.initialize(self)
	table.insert(goo.animation.list,self)
	self.table   = arg.table or {}
	self.key     = arg.key
	self.start   = arg.start
	self.finish  = arg.finish or self.table[self.key]
	self.time    = arg.time or 1
	self.relative = arg.relative or false
	self.current = self.start
	self.startTime = nil
	self:gotoState('pause')
end
function goo.animation:update(dt)
end
function goo.animation:getState()
	return self.state.name
end
function goo.animation:reverse()
	if self.start then
		self.start, self.finish = self.finish, self.start
	else
		local _tmp  = self.table[self.key]
		self.table[self.key] = self.finish
		self.finish = _tmp
	end
end

-- PLAY STATE
local play = goo.animation:addState('play')
function play:enterState()
	if not self.startTime then 
		self.startTime = love.timer.getMicroTime()
		if not self.start then
			self.start = self.table[self.key]
		end
		if self.relative then
			self.start = self.table[self.key]
			self.finish = self.table[self.key] + self.finish
		end
	else
		self.playTime = love.timer.getMicroTime()
		self.startTime = self.startTime + (self.playTime-self.pauseTime)
	end
end
function play:update(dt)
	local _timeElapsed = love.timer.getMicroTime() - self.startTime
	
	if _timeElapsed < self.time then
		self.current = ANIM_QUAD_INOUT( _timeElapsed, self.start, self.finish - self.start, self.time )
		self.table[self.key] = self.current
	else
		self:gotoState('finished')
	end
end
function goo.animation:play()
	self:gotoState('play')
end

-- PAUSE STATE
local pause = goo.animation:addState('pause')
function pause:enterState()
	self.pauseTime = love.timer.getMicroTime()
end
function goo.animation:pause()
	self:gotoState('pause')
end

-- FINISHED STATE
local finished = goo.animation:addState('finished')
function finished:enterState()
	self.startTime = nil
	self.table[self.key] = self.finish
	if self.onFinish then self:onFinish() end
	if self.parentChain then self.parentChain:animFinished() end
	if self.parentGroup then self.parentGroup:animFinished() end
end

-- ANIMATION GROUP
goo.animation.group = class('goo animation group')
local group = goo.animation.group
function group:initialize(...)
	super.initialize(self)
	self.anims = {}
	self.count = 0
	self.state = 'pause'
	for k,v in ipairs(arg) do
		if type(v) == 'table' then
		if instanceOf(goo.animation,v) or instanceOf(group, v) then
			table.insert(self.anims, v)
			v.parentGroup = self
		end
		end
	end
end
function group:play()
	self.count = 0
	self.state = 'play'
	for k,v in pairs(self.anims) do
		v:play()
	end
end
function group:pause()
	self.state = 'pause'
	for k,v in pairs(self.anims) do
		v:pause()
	end
end
function group:reverse()
	for k,v in pairs(self.anims) do
		v:reverse()
	end
end
function group:animFinished( anim )
	self.count = self.count + 1
	if self.count >= #self.anims then
		self:finished()
	end
end
function group:finished()
	self.state = 'finished'
	if self.onFinish then self:onFinish() end
	if self.parentChain then self.parentChain:animFinished() end
	if self.parentGroup then self.parentGroup:animFinished() end
end
function group:setTime(time)
	for k,v in pairs(self.anims) do
		v.time = time
	end
end
function group:getState()
	return self.state
end

-- ANIMATION CHAIN
goo.animation.chain = class('goo animation chain')
local chain = goo.animation.chain
function chain:initialize(...)
	super.initialize(self)
	self.anims = {}
	self.pos = 1
	self.state = 'pause'
	for k,v in ipairs(arg) do
		if type(v) == 'table' then
		if instanceOf(goo.animation,v) or instanceOf(group,v) or instanceOf(chain,v) then
			table.insert(self.anims,v)
			v.parentChain = self
		end
		end
	end
end
function chain:play()
	self.state = 'play'
	self.anims[self.pos]:play()
end
function chain:pause()
	self.state = 'pause'
	self.anims[self.pos]:pause()
end
function chain:reverse()
	local _fin
	local _lastFin = {}
	for k,v in ipairs(self.anims) do
		if instanceOf(group,v) then
			for k2,v2 in ipairs(v.anims) do
				self:reverseB(_lastFin,v2)
			end
		else
			self:reverseB(_lastFin,v)
		end
	end
end
function chain:reverseB(lastFin,anim)
	if not anim.start then
		if not lastFin[anim.key] then
			lastFin[anim.key] = anim.table[anim.key]
		else
			local _tmp = anim.finish
			anim.finish = lastFin[anim.key]
			lastFin[anim.key] = _tmp
		end
		anim.table[anim.key] = lastFin[anim.key]
	else
		anim:reverse()
	end
end
function chain:animFinished(anim)
	self.pos = self.pos + 1
	if self.pos > #self.anims then
	 	self:finished()
	else
		self:play()
	end
end
function chain:finished()
	self.state = 'finished'
	if self.onFinish then self:onFinish() end
end
function chain:getState()
	return self.state
end


function goo.animation:moveTo( object, x, y, time )
	local time = time or 1
	local xAnim = self:new{
		table 	= object,
		key		= 'x',
		finish  = x,
		time	= time
	}
	local yAnim = self:new{
		table 	= object,
		key		= 'y',
		finish  = y,
		time	= time
	}
	local group = self.group:new(xAnim,yAnim)
	return group
end

-- Initialization
--[[
function love.load()

end

-- Logic
function love.update(dt)

end

-- Scene Drawing
function love.draw()

end

-- Input
function love.keypressed( key, unicode )

end

function love.keyreleased( key, unicode )

end

function love.mousepressed( x, y, button )

end

function love.mousereleased( x, y, button )

end

function joystickpressed( joystick, button )
end

function joystickreleased( joystick, button )
end
]]--