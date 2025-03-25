local L = {}

TRUE = {L,0,{L,1,0}}
FALSE = {L,0,{L,1,0}}

THREE = {L,0,{L,1,{0,{0,{0,1}}}}}
local fac_part = {L,4,{L,5,{{3,4},{4,5}}}}
fac_part.color = {0, 0.9, 1}
fac_part.scaley = 1
FAC = {L,0,{L,1,{{{0,{L,2,{L,3,{3,{2,fac_part}}}}},{L,2,1}},{L,2,2}}}}

function computeSize(l)
	if type(l) == "table" then
		if l[1] == L then
			local w, h = computeSize(l[3])
			return w, h + 2
		end
		local w1, h1 = computeSize(l[1])
		local w2, h2 = computeSize(l[2])
		return w1 + w2, math.max(h1, h2) + 2
	else
		return 4, 1
	end
end
local scale = 16

function render(l, x, y, c)
	local mw, mh = computeSize(l)
	if type(l) == "table" then
		local prevColor
		if l.color then
			prevColor = {love.graphics.getColor()}
			love.graphics.setColor(l.color)
		end
		if l[1] == L then
			local w, h = computeSize(l[3])
			render(l[3], x, y + mh - h - 2, c + 1)
			love.graphics.rectangle("fill", (x) * scale, (y+mh-1) * scale, (mw-1) * scale, scale)
		else
			local w1, h1 = computeSize(l[1], x + 0, y)
			local w2, h2 = computeSize(l[2], x + 4, y)
			render(l[1], x, y + mh - h1, c)
			render(l[2], x + w1, y + mh - h2, c)
			love.graphics.rectangle("fill", (x+1) * scale, y * scale, scale, mh * scale)
			love.graphics.rectangle("fill", (x+1) * scale, (y+2) * scale, (mw-w2) * scale, scale)
			love.graphics.rectangle("fill", (x+1+w1) * scale, (y+2) * scale, scale, (mh-h2-1) * scale)
		end
		if l.color then love.graphics.setColor(prevColor) end
	else
		love.graphics.rectangle("fill", (x+1) * scale, y * scale, scale, 2 * (c - l) * scale)
	end

end

function raiseVars(l, amt)
	if type(l) == "table" then
		if l[1] == L then
			print("scanning func")
			l[3] = raiseVars(l[3], amt)
		else
			print("scanning app")
			l[1] = replace(l[1], amt)
			l[2] = replace(l[2], amt)
		end
	else
		print("checking var", l, var)
		if l == var then
			print("replace")
			return expr
		end
	end
	return l
end

function replace(l, var, expr)
	if type(l) == "table" then
		if l[1] == L then
			print("scanning func")
			l[3] = replace(l[3], var, expr)
		else
			print("scanning app")
			l[1] = replace(l[1], var, expr)
			l[2] = replace(l[2], var, expr)
		end
	else
		print("checking var", l, var)
		if l == var then
			print("replace")
			return expr
		end
	end
	return l
end

function reduce(l)
	if type(l) == "table" then
		if l[1] == L then

		else
			print("reducing app")
			if l[1][1] == L then
				replace(l[1][3], l[1][2], l[2])
			end
		end
	end
end

local t = 0

local expr = FAC

print(computeSize(FAC))

function love.update(dt)
	t = t + dt
end

function love.draw()
	love.graphics.scale(1, -1)
	fac_part.scaley = math.sin(t) / 2 + 0.5
	fac_part.scalex = fac_part.scaley
	render(expr, 0, -30, 0)
end

function love.mousepressed()
	reduce(expr)
end
