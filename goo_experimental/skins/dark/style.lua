-- Filename: goo.lua
-- Author: Luke Perkin
-- Date: 2010-02-26
-- Desc: 

local style = {}
local fonts = {}
fonts.default24 = love.graphics.newFont(24)
fonts.oldsans12 = love.graphics.newFont('oldsansblack.ttf')
fonts.oldsans24 = love.graphics.newFont('oldsansblack.ttf',24)
fonts.oldsans32 = love.graphics.newFont('oldsansblack.ttf',32)

style['goo big button'] = {
	buttonColor = {255,255,255,255},
	buttonColorHover = {200,150,255,255},
	textColor = {0,0,0,255},
	textColorHover = {0,0,0,255},
	font = {'oldsansblack.ttf', 12}
}

style['goo text input'] = {
	borderColor = {0,0,0},
	backgroundColor = {255,255,255},
	textColor = {0,0,0},
	cursorColor = {0,0,0},
	cursorWidth = 2,
	borderWidth = 2,
	textFont = fonts.oldsans12,
	blinkRate = 0.5,
	leading = 35
}

style['goo progressbar'] = {
	backgroundColor = {255,255,255},
	fillMode		= 'fill'
}

style['goo image'] = {
	imageTint = {255,255,255}
}

style['goo debug'] = {
	backgroundColor = {0,0,0,170},
	textColor = {255,255,255,255},
	textFont = fonts.oldsans12
}

style['goo close button'] = {
	color = {255,255,255},
	colorHover = {255,0,0}
}

style['goo button'] = {
	backgroundColor = {255,255,255},
	backgroundColorHover = {203,131,21},
	borderColor = {0,0,0,255},
	borderColorHover = {0,0,0},
	textColor = {0,0,0},
	textColorHover = {0,0,0},
	textFont = fonts.oldsans12
}

style['goo panel'] = {
	backgroundColor = {0,0,0},
	borderColor = {255,255,255},
	titleColor = {255,255,255},
	titleFont = fonts.oldsans12,
	seperatorColor = {100,100,100}
}

return style, fonts

