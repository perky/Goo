---------------
--  TEXT INPUT
---------------
goo.textinput = class('goo text input', goo.object)
function goo.textinput:initialize( parent )
	super.initialize(self,parent)
	self.text = ''
	self.textXoffset = 0
	self.focus = false
	self.blink = false
	self.blinkRate = self.style.blinkRate
	self.blinkTime = love.timer.getTime() + self.blinkRate
	self.font = self.style.textFont
	self.fontH = self.font:getHeight()
	self.caretPos = 1
	self.lines = {}
	self.lines[1] = ''
	self.linePos = 1
	self.leading = self.style.leading
	self.multiline = false
	love.keyboard.setKeyRepeat( 500, 50 )
end
function goo.textinput:update(dt)
	super.update(self,dt)
	if love.timer.getTime() > self.blinkTime then
		self.blink = not self.blink
		self.blinkTime = love.timer.getTime() + self.blinkRate
	end
	if love.mouse.isDown('l') and not self.hoverState then self.focus = false end
	self.textXoffset = self.font:getWidth( self.lines[self.linePos]:sub(1,self.caretPos) ) - self.w + 15
	if self.textXoffset < 0 then self.textXoffset = 0 end
	if self.caretPos < 1 then self.caretPos = 1 end
end
function goo.textinput:draw(x,y)
	local x,y = self:getAbsolutePos()
	if self.style.textFont then
		love.graphics.setFont( self.style.textFont )
	else
		love.graphics.setFont( 12 )
	end
	self.font = love.graphics.getFont()
	self.fontH = self.font:getHeight()
	
	local w = self.style.borderWidth
	
	self:setColor( self.style.borderColor )
	love.graphics.rectangle('fill',-w,-w,self.w+(w*2),self.h+(w*2))
	self:setColor( self.style.backgroundColor )
	love.graphics.rectangle('fill',0,0,self.w,self.h)
	love.graphics.setScissor( x, y-1, self.w, self.h+1 )
	
	for i,txt in ipairs(self.lines) do
		self:setColor( self.style.textColor )
		love.graphics.print( txt, 5-self.textXoffset, (self.fontH)+(self.leading*(i-1)))
	end
	if self.blink and self.focus then
		self:setColor( self.style.cursorColor )
		local w = self.font:getWidth( self.lines[self.linePos]:sub(1,self.caretPos-1) )
		w = math.min( w, self.w - 15 )
		love.graphics.rectangle('fill', w+5, 2+(self.leading*(self.linePos-1)), self.style.cursorWidth, self.fontH)
	end
	love.graphics.setScissor()
end
function goo.textinput:keypressed(key,unicode)
	if not self.focus then return false end
	if key == 'backspace' then
		self:keyBackspace()
	elseif key == 'return' then
		self:keyReturn()
	elseif key == 'left' then
		self:keyLeft()
	elseif key == 'right' then
		self:keyRight()
	elseif key == 'up' then
		self:keyUp()
	elseif key == 'down' then
		self:keyDown()
	elseif unicode ~= 0 and unicode < 1000 then
		self:keyText(key,unicode)
	end
	if self.onKeypressed then self:onKeypressed( key, unicode ) end
	return true
end
function goo.textinput:keyText(key,unicode)
	self:insert(string.char(unicode), self.caretPos)
	self.caretPos = self.caretPos + 1
end
function goo.textinput:keyReturn()
	if self.onkeyReturn then self:onKeyReturn() end
	if not self.multiline then return end
	if self.caretPos > self.lines[self.linePos]:len() then
		self.linePos = self.linePos + 1
		self.caretPos = 1
		self:newline( self.linePos )
	else
		self:newlineWithText( self.caretPos, self.linePos )
	end
end
function goo.textinput:keyBackspace()
	if self.caretPos == 1 and self.linePos > 1 then
		if not self.multiline then return end
		self:backspaceLine( self.linePos )
	else
		self:remove(self.caretPos,1)
		self.caretPos = self.caretPos - 1
	end
end
function goo.textinput:keyLeft()
	if self.caretPos > 1 then
		self.caretPos = self.caretPos - 1
		if self.caretPos < 1 then self.caretPos = 1 end
	else
		if self.linePos > 1 then
			if not self.multiline then return end
			self.linePos = self.linePos - 1
			self.caretPos = self.lines[self.linePos]:len()+1
		end
	end
end
function goo.textinput:keyRight()
	if self.caretPos <= self.lines[self.linePos]:len() then
		self.caretPos = self.caretPos + 1
	else
		if not self.multiline then return end
		if self.linePos < #self.lines then
			self.linePos = self.linePos+1
			self.caretPos = 1
		end
	end
end
function goo.textinput:keyUp()
	if not self.multiline then return end
	if self.linePos == 1 then return end
	self.linePos = self.linePos - 1
end
function goo.textinput:keyDown()
	if not self.multiline then return end
	if self.linePos == #self.lines then return end
	self.linePos = self.linePos + 1
end
function goo.textinput:insert(text,pos)
	local txt = self.lines[self.linePos]
	local part1 = txt:sub(1,pos-1)
	local part2 = txt:sub(pos)
	self.lines[self.linePos] = part1 .. text .. part2
end
function goo.textinput:remove(pos,length)
	if pos == 1 then return end
	local txt = self.lines[self.linePos]
	local part1 = txt:sub(1,pos-2)
	local part2 = txt:sub(pos+length-1)
	self.lines[self.linePos] = part1 .. part2
end
function goo.textinput:newline(pos)
	local pos = pos or nil
	table.insert(self.lines,pos,'')
end
function goo.textinput:removeline(pos)
	local pos = pos or #self.lines
	table.remove(self.lines,pos)
end
function goo.textinput:backspaceLine()
	local _line = self.lines[self.linePos]
	self:removeline( self.linePos )
	self.linePos = self.linePos - 1
	self.caretPos = self.lines[self.linePos]:len()+1
	self.lines[self.linePos] = self.lines[self.linePos] .. _line
end
function goo.textinput:newlineWithText(pos,pos2)
	local part1 = self.lines[self.linePos]:sub(1,pos-1)
	local part2 = self.lines[self.linePos]:sub(pos)
	self.lines[pos2] = part1
	self:newline(self.linePos+1)
	self.linePos = self.linePos + 1
	self.caretPos = 1
	self.lines[self.linePos] = part2
end
function goo.textinput:mousepressed( x, y, button )
	self.focus = true
end
function goo.textinput:getText()
	local text = ''
	for i,v in ipairs(self.lines) do
		text = text .. v .. '\n'
	end
	return text
end
function goo.textinput:setText( text )
	self.lines = {}
	if not self.multiline then
		local str = text:gsub('\n','')
		self.lines[1] = str
		self.caretPos = str:len()+1
	else
		local count = 1
		for line in string.match( text, '(.*)\n' ) do
			self.lines[ count ] = line
			count = count + 1
		end
	end
end

-- Getters Setters
goo.textinput:getterSetter( 'multiline', false )
goo.textinput:getterSetter( 'linePos', 1 )
goo.textinput:getterSetter( 'caretPos', 1 )

return goo.textinput