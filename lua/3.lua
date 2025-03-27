---@diagnostic disable: unicode-name

L = L or function (l)
	return {L,l}
end
l = L

require 'fmt'

DEBUG = true

local _print = print
local function print(...)
	if DEBUG then
		_print(...)
	end
end

function copyTable(t)
	if type(t) ~= "table" then return t end
	local ret = {}
	for k, v in pairs(t) do
		ret[k] = copyTable(v)
	end
	return ret
end

local function incFree(l, d)

	d = d or -1
	--print("applying to", l)
	if type(l) == "table" then
		if l[1] == L then
			l[2] = incFree(l[2], d + 1)
			return l
		end
		l[1] = incFree(l[1], d)
		l[2] = incFree(l[2], d)
		return l
	end
	if l > d then
		print("extending free? binding", l, d)
		return l + 1
	end
	return l
end

local function apply(l, v, d)
	d = d or -1
	--print("applying to", l)
	if type(l) == "table" then
		if l[1] == L then
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
	if l > d then
		return l - 1
	end
	return l
end

function reduce(l)
	if type(l) == "table" then
		local s
		if l[1] == L then
			l[2], s = reduce(l[2])
			if s then print("reduce body") end
			return l, s
		end
		if type(l[1]) == "table" and l[1][1] == L then
			print(("applying %s onto %s"):format(lambdaToString(l[1]), lambdaToString(l[2])))
			return apply(l[1], incFree(l[2])), true
		end
		l[1], s = reduce(l[1])
		if s then
			print("reduce func")
			return l, true
		end
		l[2], s = reduce(l[2])
		if s then
			print("reduce arg")
			return l, true
		end
		return l, false
	end
	return l, false
end

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
