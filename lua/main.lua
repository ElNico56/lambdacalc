require"eval"
require"render"
require"defs"
require"fmt"

local expr
expr = {M, M}              -- Omega
expr = {{EXP, N(3)}, N(2)} -- 3 ^ 2
expr = {{S, K}, K}         -- Identity
expr = {{MUL, N(2)}, N(3)} -- 2 * 3

-- expr[1][1].color = {0.1, 0.9, 1.0}

local hist = {}

print(lambdaToString(expr))

function love.draw()
	local lw, lh = computeSize(expr)
	local ww, wh = love.graphics.getDimensions()
	ww, wh = ww - 20, wh - 20
	local s = math.min(ww / lw, wh / lh)
	love.graphics.scale(1, -1)
	render(expr, 10 / s, -10 / s - lh, math.floor(s / 2))
end

function love.mousepressed(_, _, button)
	if button == 1 then
		local nextexpr, reduced = reduce(expr)
		if reduced then
			table.insert(hist, expr)
			expr = nextexpr
		end
		print(lambdaToString(expr))
	elseif button == 2 then
		expr = table.remove(hist) or expr
	end
end
