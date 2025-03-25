---@diagnostic disable: unicode-name

λ = λ or 'λ'
l = λ

require 'defs'
require 'fmt'

local function copyTable(t)
	if type(t) ~= "table" then return t end
	local ret = {}
	for k, v in pairs(t) do
		ret[k] = copyTable(v)
	end
	return ret
end



local function apply(l, v, d)
	d = d or -1
	--print("applying to", l)
	if type(l) == "table" then
		if l[1] == λ then
			l[2] = copyTable(apply(l[2], v, d + 1))
			return d == -1 and l[2] or l
		end
		l[1] = apply(l[1], v, d)
		l[2] = apply(l[2], v, d)
		return l
	end
	if l == d then
		return v
	end
	return l
end

function reduce(l)
	if type(l) == "table" then
		local s
		if l[1] == λ then
			l[2], s = reduce(l[2])
			return l, s
		end
		if type(l[1]) == "table" and l[1][1] == λ then
			return apply(l[1], l[2]), true
		end
		l[2], s = reduce(l[2])
		if s then return l, true end
		l[1], s = reduce(l[1])
		if s then return l, true end
		return l, false
	end
	return l, false
end

local expr = {ADD, N(5)}

function eval(expr, showSteps, step)
	local cont = true
	while cont do
		if showSteps then
			print(lambdaToString(expr))
		end
		if step then
			io.read("L")
		end
		expr, cont = reduce(expr)
	end
end

while true do
	io.write("[0mλua > ")
	eval(load("return "..io.read("L"))(), true)
end
