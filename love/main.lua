require "eval"
require "render"
require "defs"
require "fmt"

local expr = {{EXP, N(4)}, N(2)}

expr[1][1].color = {0.1, 0.9, 1.0}

local hist = {}

print(lambdaToString(expr))

function love.draw()
	local lw, lh = computeSize(expr)
	local ww, wh = love.graphics.getDimensions()
	ww, wh = ww-20, wh-20
	local s = math.min(ww/lw, wh/lh)
	love.graphics.scale(1, -1)
	render(expr, 10/s, -10/s - lh, s)
end

function love.mousepressed(_, _, button)
	if button == 1 then
		table.insert(hist,expr)
		expr = reduce(expr)
		print(lambdaToString(expr))
	elseif button == 2 then
		expr = table.remove(hist) or expr
	end
end
