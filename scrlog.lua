local scrlog = {}
scrlog.lines = {}
scrlog.lineNum = 0

scrlog.showLines = 10
scrlog.scroll = 0

scrlog.transparency = 220

scrlog.textxOffset = 2
scrlog.bghOffset = 2

scrlog.font = love.graphics.newFont("oldsansblack.ttf", 12)
scrlog.fontHeight = scrlog.font:getHeight()

scrlog.width = love.graphics.getWidth()

scrlog.hide = true
scrlog._alpha = 0

function scrlog.draw()
	local x, y = love.mouse.getPosition()
	
	if x < scrlog.width and y < scrlog.getHeight() then
		scrlog._alpha = math.min(scrlog._alpha + 5, 100)
	else
		scrlog._alpha = math.max(scrlog._alpha - 5, 0)
	end
	
	
	local text_alpha = scrlog.transparency + ((255-scrlog.transparency)*0.01) * scrlog._alpha
	local bg_alpha = scrlog.transparency * 0.01 * scrlog._alpha
	
	love.graphics.setColor(0, 0, 0, bg_alpha)
	love.graphics.rectangle( "fill", 0, 0, scrlog.width, scrlog.getHeight() )
	love.graphics.setColor(255, 255, 255, bg_alpha)
	love.graphics.rectangle( "fill", scrlog.width-5, (scrlog.scroll/(scrlog.lineNum - scrlog.getShowLines())*(scrlog.getHeight()-2)), 5, 2 )
	
	--Draw text log
	love.graphics.setFont(scrlog.font)
	love.graphics.setColor(255, 255, 255, text_alpha)
	for i = 1, scrlog.getShowLines() do
		if scrlog.lines[i + scrlog.scroll] then
			love.graphics.print(scrlog.lines[i + scrlog.scroll], scrlog.textxOffset, (i*scrlog.fontHeight))
		end
	end
end

function scrlog.config(t)
	for i, v in pairs(t) do
		if scrlog[i] then
			scrlog[i] = v
		end
	end
end

function scrlog.getHeight()
	return scrlog.fontHeight * scrlog.getShowLines() + scrlog.bghOffset;
end

function scrlog.getShowLines()
	return (scrlog.hide and 1 or scrlog.showLines);
end

function scrlog.maxScroll()
	return ((scrlog.lineNum >= scrlog.getShowLines()) and (scrlog.lineNum - scrlog.getShowLines()) or 0)
end

function scrlog.doScroll(n)
	scrlog.scroll = math.max(0, math.min(scrlog.scroll + n, scrlog.maxScroll()))
end

function scrlog.scrollToBottom()
	scrlog.scroll = scrlog.maxScroll()
end

function scrlog.toggle()
	scrlog.hide = not scrlog.hide
	scrlog.scrollToBottom()
end

scrlog.print = print
function print(...)
	--scrlog.print(...)
	
	local str = table.concat({...}, "    ")
	str = string.gsub(str, "\t", "    ")
	table.insert(scrlog.lines, str)
	scrlog.lineNum = scrlog.lineNum + 1
	
	scrlog.scrollToBottom()
end

function scrlog.mousepressed(x, y, mouse)
	if x > scrlog.width or y > scrlog.getHeight() then return end
	
	if (mouse == 'l') then
		scrlog.toggle()
	
	elseif (mouse == 'wu') then
		scrlog.doScroll(-1)
	
	elseif (mouse == 'wd') then
		scrlog.doScroll(1)
	
	end
end

return scrlog
