-- NULL OBJECT
goo.null = class('goo null', goo.object)
function goo.null:initialize( parent )
	super.initialize(self)
end

return goo.null