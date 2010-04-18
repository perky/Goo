-- Filename: style.lua
-- Author: Luke Perkin
-- Date: 2010-02-26
-- Desc: 

local style = {}

function style.linear( t, b, c, d )
	return b + c*t/d
end

function style.quadIn( t, b, c, d )
	local p = t/d
	return c*p*p + b
end

function style.quadOut( t, b, c, d )
	local p = t/d
	return -c*p*(p-2) + b
end

function style.quadInOut( t, b, c, d )
	local p = t/(d/2)
	if p < 1 then return c/2*p*p + b end
	return -c/2 * ((p-1)*(p-3)-1) + b
end

function style.quartIn( t, b, c, d )
	local p = t/d
	return c*p*p*p*p + b
end

function style.quartOut( t, b, c, d )
	local p = t/d-1
	return -c*(p*p*p*p-1) + b
end

function style.quartInOut( t, b, c, d )
	local p = t/(d/2)
	if p < 1 then return c/2*p*p*p*p + b end
	return -c/2 * ((p-2)*(p-2)*(p-2)*(p-2)-2) + b
end

function style.expoIn( t, b, c, d )
	return t==0 and b or c * math.pow(2, 10*(t/d-1)) + b
end

function style.expoOut( t, b, c, d )
	return t==d and b+c or c * (-math.pow(2, -10*t/d)+1) + b
end

function style.expoInOut( t, b, c, d )
	if t==0 then return b end
	if t==d then return b+c end
	local p = t/(d/2)
	if p < 1 then return c/2 * math.pow(2, 10*(p-1)) + b end
	return c/2 * (-math.pow(2, -10*(p-1))+2) + b
end

function style.elastic( t, b, c, d, a, p )
	if t==0 then return b end
	local t2 = t/d
	
	if t2==1 then return b+c end
	if not p then p = d * 0.3 end
	if not a or a < math.abs(c) then
		a = c
		s = p/4
	else
		s = p/(2*math.pi) * math.asin( c/a )
	end
	return a*math.pow(2, -10*t2) * math.sin((t2*d-s)*(2*math.pi)/p) + c + b
end

return style