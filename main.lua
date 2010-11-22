require 'goo/goo'

function love.load()
	goo.load()
	
	myBox = goo.box:new()
	myBox:setpos( 50, 50 )
	myBox:setsize( 50, 50 )
	
	myButton = goo.button:new( myBox )
	myButton:sizetotext()
	function myButton:onClick( x, y, button )
		print('click')
	end
end

function love.update(dt)
	goo.update(dt)
end

function love.draw()
	goo.draw()
end

function love.mousepressed(x,y,button)
	goo.mousepressed(x,y,button)
end

function love.mousereleased(x,y,button)
	goo.mousereleased(x,y,button)
end