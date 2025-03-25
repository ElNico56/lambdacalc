---@diagnostic disable: unicode-name

λ = λ or 'λ'

local function _num(n)
	if n == 0 then
		return 0
	end
	return {1, _num(n-1)}
end

function N(n)
	return {λ,{λ,_num(n)}}
end

Ω = {{λ,{0,0}},{λ,{0,0}}}
SUCC = {λ,{λ,{λ,{1,{{2,1},0}}}}}
ADD = {λ,{λ,{{1,SUCC},0}}}
