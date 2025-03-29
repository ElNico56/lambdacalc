-- fmt.lua


local max, min, abs = math.max, math.min, math.abs
local floor, log = math.floor, math.log
local char = string.char


local function hsvANSI(h, s, v)
	if h ~= h then h = 0 end
	h = h * 6
	local r = (1 + s * (min(max(abs((h + 0) % 6 - 3) - 1, 0), 1) - 1)) * v
	local g = (1 + s * (min(max(abs((h + 4) % 6 - 3) - 1, 0), 1) - 1)) * v
	local b = (1 + s * (min(max(abs((h + 2) % 6 - 3) - 1, 0), 1) - 1)) * v

	return ("\x1b[38;2;%d;%d;%dm"):format(r * 255, g * 255, b * 255)
end


local function intPart(x)
	local b = 2 ^ floor(log(x, 2))
	local b1 = 2 ^ floor(log(x, 2) + 1)
	local ret = (1 / b1 + x % b / b)
	return ret
end


local function _str(expr, depth)
	if not expr then return "NIL" end
	if depth > 20 then return "!!!" end
	if type(expr) == "table" then
		if #expr == 1 then
			local v = char(depth % 26 + 97)
			local a = _str(expr[1], depth + 1)
			return ('(L%s.%s)'):format(v, a)
		end
		local left = _str(expr[1], depth)
		local right = _str(expr[2], depth)
		return ("(%s%s)"):format(left, right)
	else
		return char((depth - expr) % 26 + 97)
	end
end


function Stringify(expr, color)
	local str = _str(expr, 0)
	while str ~= str:gsub("([a-z])%.L([a-z])", "%1%2") do
		str = str:gsub("([a-z])%.L([a-z])", "%1%2")
	end
	if color then
		return (str:gsub("[a-z]", function(letter)
			local value = string.byte(letter) - string.byte"a"
			return hsvANSI(intPart(value), 0.5, 0.9)..letter.."\x1b[0m"
		end))
	end
	return str
end
