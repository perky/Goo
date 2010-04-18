--[[	Animation library.
		This is an animation library.
		@name anim
		@release 2010-02-26 version 1
		@usage <pre>test</pre>
]]

local anim = {}
anim.animation = class('goo animation', StatefulObject)
anim.style = require 'anim.style'
anim.list = {}
anim.lastTime = 0

function anim:new(...)
	return self.animation:new(...)
end

--[[ Updates all animations, use inside love.update().
	@param dt delta time
]]
function anim:update(dt)
	for k,v in pairs(self.list) do
		v:update(dt)
	end
end

function anim.animation:initialize(arg)
	super.initialize(self)
	table.insert(anim.list,self)
	self.table   = arg.table or {}
	self.key     = arg.key
	self.start   = arg.start or self.table[self.key]
	self.finish  = arg.finish or self.table[self.key]
	self.time    = arg.time or 1
	self.delay   = arg.delay or 0
	self.relative 	= arg.relative or false
	self.current 	= self.start
	self.startTime 	= nil
	self.style 		= anim.style[arg.style] or anim.style.linear
	self.styleargs 	= arg.styleargs or {}
	self:gotoState('pause')
end
function anim.animation:update(dt)
end
function anim.animation:getState()
	return self.state.name
end

--[[ Reverse the animation instance.
	<br/> Reverses the animation, going from finish to start.
	@name anim:reverse
]]
function anim.animation:reverse()
	if self.start then
		self.start, self.finish = self.finish, self.start
	else
		local _tmp  = self.table[self.key]
		self.table[self.key] = self.finish
		self.finish = _tmp
	end
end

-- PLAY STATE
local play = anim.animation:addState('play')
function play:enterState()
	if not self.startTime then
			self:startAnim()
	else
		self.playTime = love.timer.getMicroTime()
		self.startTime = self.startTime + (self.playTime-self.pauseTime)
	end
end
function play:startAnim()
	self.startTime = love.timer.getMicroTime()
	if not self.start then
		self.start = self.table[self.key]
	end
	if self.relative then
		self.start = self.table[self.key]
		self.finish = self.table[self.key] + self.finish
	end
end
function play:update(dt)
	local _timeElapsed = love.timer.getMicroTime() - self.startTime
	
	if _timeElapsed < self.time then
		self.current = self.style( _timeElapsed, self.start, self.finish - self.start, self.time, unpack(self.styleargs) )
		self.table[self.key] = self.current
	else
		self:gotoState('finished')
	end
end

--[[ Plays or resumes the animation instance.
	@name anim:play
	@usage <pre class="example">
	new_anim = anim:new{}
	new_anim:play()
	</pre>
]]
function anim.animation:play()
	self:gotoState('delay')
end

-- DELAY STATE
local delay = anim.animation:addState('delay')
function delay:enterState()
	if self.delay and self.delay > 0 then
		self.startDelay = love.timer.getMicroTime()
	else
		self:gotoState('play')
	end
end
function delay:update(dt)
	local _delayElapsed = love.timer.getMicroTime() - self.startDelay
	
	if self.delay and _delayElapsed > self.delay then
		self:gotoState('play')
	end
end

-- PAUSE STATE
local pause = anim.animation:addState('pause')
function pause:enterState()
	self.pauseTime = love.timer.getMicroTime()
end

--[[ Pause the animation instance.
	@name anim:pause
]]
function anim.animation:pause()
	self:gotoState('pause')
end

-- FINISHED STATE
local finished = anim.animation:addState('finished')
function finished:enterState()
	self.startTime = nil
	self.table[self.key] = self.finish
	if self.onFinish then self:onFinish() end
	if self.parentChain then self.parentChain:animFinished() end
	if self.parentGroup then self.parentGroup:animFinished() end
end

--[[ Finishes the animation instance, going instantly to the finish value.
	@name anim:finish
]]
function anim.animation:finish()
	self:gotoState('finished')
end

-- ANIMATION GROUP
anim.group = class('goo animation group', StatefulObject)
local group = anim.group
function group:initialize(...)
	super.initialize(self)
	self.anims = {}
	self.count = 0
	self.state = 'pause'
	for k,v in ipairs(arg) do
		if type(v) == 'table' then
		if instanceOf(anim,v) or instanceOf(group, v) then
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
	log.print(self)
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
anim.chain = class('goo animation chain')
local chain = anim.chain
function chain:initialize(...)
	super.initialize(self)
	self.anims = {}
	self.pos = 1
	self.state = 'pause'
	for k,v in ipairs(arg) do
		if type(v) == 'table' then
		if instanceOf(anim.animation,v) or instanceOf(group,v) or instanceOf(chain,v) then
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
	--self:reverseorder( self.anims )
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
	anim.table[anim.key] = anim.start
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
function chain:reverseorder(t)
	local tn = #t
	local count = math.floor((tn/2)-1)
	for i=0,count do
		t[1+i], t[tn-i] = t[tn-i], t[1+i]
	end
end

function anim:moveTo( object, x, y, time, style, delay )
	local time = time or 1
	local xAnim = self:new{
		table 	= object,
		key		= 'x',
		finish  = x,
		time	= time,
		style	= style,
		delay	= delay
	}
	local yAnim = self:new{
		table 	= object,
		key		= 'y',
		finish  = y,
		time	= time,
		style	= style,
		delay	= delay
	}
	local group = self.group:new(xAnim,yAnim)
	group:play()
	return group
end

function anim:easy( table, key, start, finish, time, style )
	local _anim = self.animation:new{
		table = table,
		key = key,
		start = start,
		finish = finish,
		time = time,
		style = style
	}
	_anim:play()
	return _anim
end

return anim