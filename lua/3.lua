---@diagnostic disable: unicode-name

local function copyTable(t)
	if type(t) ~= "table" then return t end
	local ret = {}
	for k, v in pairs(t) do
		ret[k] = v
	end
	return ret
end


local λ = 'λ'

local Ω = {{λ,{0,0}},{λ,{0,0}}}

local succ = {λ,{λ,{λ,{1,{{2,1},0}}}}}
local add = {λ,{λ,{{1, succ}, 0}}}

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
		return copyTable(v)
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
		l[1], s = reduce(l[1])
		if not s then
			l[2], s = reduce(l[2])
		end
		return l, s
	end
	return l, false
end

function lambdaToString(l, d)
	d = d or -1
	if type(l) == "table" then
		if l[1] == λ then
			return ('λ%s.%s'):format(string.char((d + 1) % 26 + 97), lambdaToString(l[2], d+1))
		end
		return ('{%s %s}'):format(lambdaToString(l[1], d), lambdaToString(l[2], d))
	end
	return string.char((d-l) % 26 + 97)
end


local expr = {copyTable(succ),{λ,{λ,{1,{1,{1,0}}}}}}
local cont = true

while cont do
	print(lambdaToString(expr))
	io.read("L")
	expr, cont = reduce(expr)
end

