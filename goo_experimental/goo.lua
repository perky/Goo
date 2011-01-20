goo = {}
goo.instances = {}
goo.fathers = {}
GOO_PATH = 'goo/'

function goo.newobject( name, base )
	local object = {}
	local base = base or 'base'
	object.name = name
	object.base = goo[base]
	object.state = nil
	object.meta = { __index = object }
	setmetatable( object, { __index = goo[base] } )
	goo[name] = object
	return object
end

function goo.newinstance( instance, parent )
	table.insert( goo.instances, instance )
	if not parent then table.insert( goo.fathers, instance ) end
end

function goo.newstate( name )
	return {}
end

function goo.load()
	-- Load the base object
	goo.base = require( GOO_PATH .. 'base' )
	
	-- Load all objects
	local object_list = love.filesystem.enumerate( 'goo/objects' )
	for k,v in pairs( object_list ) do
		local name = v:gsub( '.lua', '' )
		require( GOO_PATH .. 'objects/'..v )
	end
	
	-- Set skin
	goo.setskin( 'default' )
end

function goo.setskin( skinname )
	GOO_SKINPATH = string.format( '%s/skins/%s/', GOO_PATH, skinname )
	goo.skin, goo.fonts = require( GOO_SKINPATH .. 'style.lua' )
end

function goo.update(dt)
	for k, instance in ipairs( goo.instances ) do instance:update(dt) end
end

function goo.draw()
	for k, father in ipairs( goo.fathers ) do 
		love.graphics.push()
		love.graphics.translate( father.x, father.y )
			father:drawall()
		love.graphics.pop()
	end
end

function goo.mousepressed(x,y,button)
	for i = #goo.instances, 1, -1 do
		local instance = goo.instances[i]
		if instance.hoverstate == 'over' then instance:mousepressed(x,y,button) end
	end
end

function goo.mousereleased(x,y,button)
	for i = #goo.instances, 1, -1 do
		local instance = goo.instances[i]
		instance:mousereleased(x,y,button)
	end
end

function goo.keypressed(key,unicode)
	for k, instance in ipairs( goo.instances ) do instance:keypressed(key,unicode) end
end

function goo.keyreleased(key,unicode)
	for k, instance in ipairs( goo.instances ) do instance:keyreleased(key,unicode) end
end
