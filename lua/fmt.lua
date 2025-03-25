---@diagnostic disable: unicode-name

λ = λ or 'λ'

function hsvANSI(h, s, v)
	if h ~= h then h = 0 end
	h = h * 6
	local r = (1+s*(math.min(math.max(math.abs((h+0)%6-3)-1, 0), 1)-1)) * v
	local g = (1+s*(math.min(math.max(math.abs((h+4)%6-3)-1, 0), 1)-1)) * v
	local b = (1+s*(math.min(math.max(math.abs((h+2)%6-3)-1, 0), 1)-1)) * v

	return ("[38;2;%d;%d;%dm"):format(r*255, g*255, b*255)
end

function intPart(x)
	local b = 2^math.floor(math.log(x, 2))
	local b1 = 2^math.floor(math.log(x, 2)+1)
	local ret = (1/b1 + x%b/b)
	return ret
end

function lambdaToString(l, d)
	d = d or -1
	if d > 20 then return "!!!" end
	if type(l) == "table" then
		if l[1] == λ then
			local col = hsvANSI(intPart(d+1), 0.8, 0.9)
			return ('%sλ%s.%s%s'):format(col, string.char((d + 1) % 26 + 97), lambdaToString(l[2], d+1), col)
		end
		local col = hsvANSI(intPart(d), 0.8, 0.9)
		return ('%s(%s%s %s%s)'):format(col, lambdaToString(l[1], d), col, lambdaToString(l[2], d), col)
	end
	if not l then return "[31mNIL" end
	return hsvANSI(intPart(d-l), 0.8, 0.9) .. string.char((d-l) % 26 + 97)
end

io.write("[2J[H")
for i = 0, 2^7 do
	io.write(hsvANSI(intPart(i), 0.8, 0.9).."█")
end
print()
