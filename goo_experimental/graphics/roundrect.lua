-- Filename: roundrect.lua
-- Author: Luke Perkin
-- Date: 2010-02-25
-- Desc: Draws a round rectangle
-- Thanks to Robin for the draw code.

local function roundrect(mode, x, y, width, height, xround, yround)
	local points = {}
	local precision = (xround + yround) * .1
	local tI, hP = table.insert, .5*math.pi
	if xround > width*.5 then xround = width*.5 end
	if yround > height*.5 then yround = height*.5 end
	local X1, Y1, X2, Y2 = x + xround, y + yround, x + width - xround, y + height - yround
	local sin, cos = math.sin, math.cos
	for i = 0, precision do
		local a = (i/precision-1)*hP
		tI(points, X2 + xround*cos(a))
		tI(points, Y1 + yround*sin(a))
	end
	for i = 0, precision do
		local a = (i/precision)*hP
		tI(points, X2 + xround*cos(a))
		tI(points, Y2 + yround*sin(a))
	end
	for i = 0, precision do
		local a = (i/precision+1)*hP
		tI(points, X1 + xround*cos(a))
		tI(points, Y2 + yround*sin(a))
	end
	for i = 0, precision do
		local a = (i/precision+2)*hP
		tI(points, X1 + xround*cos(a))
		tI(points, Y1 + yround*sin(a))
	end
	love.graphics.polygon(mode, unpack(points))
end

return roundrect