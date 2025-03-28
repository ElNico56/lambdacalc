-- raymain.lua

local rl = rl ---@diagnostic disable-line undefined-global
L = {} -- unique symbol

local reduce = require"eval"
local render = require"render"
require"defs"
require"fmt"

local expr
expr = {M, M}              -- Omega
expr = {{EXP, N(3)}, N(2)} -- 3 ^ 2
expr = {{MUL, N(2)}, N(3)} -- 2 * 3
expr = {{{S, K}, K}}       -- Identity
expr = {I, 0}

-- expr[1][1].color = {0.1, 0.9, 1.0}

local hist = {}

print(lambdaToString(expr))

-- Initialization
local screenWidth = 1280
local screenHeight = 720

rl.SetConfigFlags(rl.FLAG_VSYNC_HINT)
rl.InitWindow(screenWidth, screenHeight, "Tromp diagram renderer")

-- Load bunny texture

-- Main game loop
while not rl.WindowShouldClose() do
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT) then
		local nextexpr, reduced = reduce(expr)
		if reduced then
			table.insert(hist, expr)
			expr = nextexpr
		end
		print(lambdaToString(expr))
	end
	if rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT) then
		expr = table.remove(hist) or expr
	end

	rl.BeginDrawing()
	do
		rl.ClearBackground(rl.BLACK)
		local e_w, e_h = render.computeSize(expr)
		local s_w, s_h = rl.GetScreenWidth(), rl.GetScreenHeight()
		s_w, s_h = s_w - 20, s_h - 20
		local s = math.min(s_w / e_w, s_h / e_h)
		-- render.render(expr, 10 / s, -10 / s - e_h, math.floor(s / 2))
		render.render(expr, 5, 5, 10)
	end
	rl.EndDrawing()
end
rl.CloseWindow()
