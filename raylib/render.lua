-- rayrender.lua

local rl = rl ---@diagnostic disable-line undefined-global
local L = L or {} -- unique symbol

local function computeSize(expr)
	if type(expr) == "table" then
		if expr[1] == L then
			local w, h = computeSize(expr[2])
			return w, h + 2
		end
		local w1, h1 = computeSize(expr[1])
		local w2, h2 = computeSize(expr[2])
		return w1 + w2, math.max(h1, h2) + 2
	else
		return 4, 1
	end
end

---@param expr table|number
---@param x number
---@param y number
---@param scale number
local function render(expr, x, y, scale)
	local mw, mh = computeSize(expr)
	if type(expr) == "table" then
		if expr[1] == L then
			local w, h = computeSize(expr[2])
			render(expr[2], x, y + mh - h - 2, scale)
			rl.DrawRectangle(
				x * scale, (y + mh - 1) * scale,
				(mw - 1) * scale, scale, rl.RAYWHITE)
		else
			local w1, h1 = computeSize(expr[1])
			local w2, h2 = computeSize(expr[2])
			render(expr[1], x, y + mh - h1, scale)
			render(expr[2], x + w1, y + mh - h2, scale)

			rl.DrawRectangle(
				(x + 1) * scale, y * scale,
				scale, (mh - h1) * scale, rl.RAYWHITE)
			rl.DrawRectangle(
				(x + 1) * scale, (y + 2) * scale,
				(mw - w2) * scale, scale, rl.RAYWHITE)
			rl.DrawRectangle(
				(x + 1 + w1) * scale, (y + 2) * scale,
				scale, (mh - h2 - 1) * scale, rl.RAYWHITE)
		end
	else
		rl.DrawRectangle(
			(x + 1) * scale, y * scale,
			scale, 2 * (expr) * scale, rl.RAYWHITE)
	end
	-- rl.DrawRectangleLines(
	-- 	x * scale + 1, y * scale + 1,
	-- 	mw * scale - 2, mh * scale - 2, rl.RAYWHITE)
end

return {computeSize = computeSize, render = render}
