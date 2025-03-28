-- fmt.lua

local max, min, abs = math.max, math.min, math.abs
local floor, log = math.floor, math.log
local char = string.char
local L = L or {} -- unique symbol

local function hsvANSI(h, s, v)
	if h ~= h then h = 0 end
	h = h * 6
	local r = (1 + s * (min(max(abs((h + 0) % 6 - 3) - 1, 0), 1) - 1)) * v
	local g = (1 + s * (min(max(abs((h + 4) % 6 - 3) - 1, 0), 1) - 1)) * v
	local b = (1 + s * (min(max(abs((h + 2) % 6 - 3) - 1, 0), 1) - 1)) * v

	return ("[38;2;%d;%d;%dm"):format(r * 255, g * 255, b * 255)
end

local function intPart(x)
	local b = 2 ^ floor(log(x, 2))
	local b1 = 2 ^ floor(log(x, 2) + 1)
	local ret = (1 / b1 + x % b / b)
	return ret
end

local reset = "[0m"
function LambdaToString(expr, depth)
	depth = depth or 0
	if depth > 20 then return "!!!" end
	if type(expr) == "table" then
		if expr[1] == L then
			local col = hsvANSI(intPart(depth), 0.8, 0.9)
			local v = col..char((depth) % 26 + 97)..reset
			local a = LambdaToString(expr[2], depth + 1)
			return ("\\%s.%s"):format(v, a)
		end
		local left = LambdaToString(expr[1], depth)
		local right = LambdaToString(expr[2], depth)
		return ("(%s %s)"):format(left, right)
	end
	if not expr then return "[31mNIL[0m" end
	local col = hsvANSI(intPart(depth - expr), 0.8, 0.9)
	if depth < expr then
		col = ("[38;2;%d;%d;%dm"):format(255 / (expr - depth), 255 / (expr - depth), 255 / (expr - depth))
	end
	return col..char((depth - expr) % 26 + 97)..reset
end

local function _str(expr, depth)
	if not expr then return "NIL" end
	if depth > 20 then return "!!!" end
	if type(expr) == "table" then
		if expr[1] == L then
			local v = char(depth % 26 + 97)
			local a = _str(expr[2], depth + 1)
			return ('L%s.%s'):format(v, a)
		end
		local left = _str(expr[1], depth)
		local right = _str(expr[2], depth)
		return ("(%s %s)"):format(left, right)
	else
		return char((depth - expr) % 26 + 97)
	end
end

function Stringify(expr, color)
	if color then
		return (_str(expr, 0):gsub("[a-z]", function(letter)
			local value = string.byte(letter) - string.byte"a"
			return hsvANSI(intPart(value), 0.8, 0.9)..letter..reset
		end))
	end
	return _str(expr, 0)
end
