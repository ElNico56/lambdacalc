---@diagnostic disable: unicode-name

L = L or "L"

local function _num(n)
	if n == 0 then
		return 1
	end
	return {2, _num(n-1)}
end

function N(n)
	return {L,{L,_num(n)}}
end

Ω = {{L,{1,1}},{L,{1,1}}}
MUL = {L,{L,{L,{2,{3,1}}}}}
EXP = {L,{L,{1,2}}}
