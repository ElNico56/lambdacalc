-- defs.lua


local function _num(n)
	if n == 0 then
		return 1
	end
	return {2, _num(n - 1)}
end


function N(n)
	return {{_num(n)}}
end

-- Combinator Birds

M = {{1, 1}}               -- Mockingbird
S = {{{{{3, 1}, {2, 1}}}}} -- Starling
K = {{2}}                  -- Kestrel
KI = {{1}}                 -- Kite
I = {1}                    -- Idiot
O = {{{1, {2, 1}}}}        -- Owl

Y = {{{{2, {1, 1}}}, {{2, {1, 1}}}}}
Theta = {Y, O}

-- Arithmetic

MUL = {{{{3, {2, 1}}}}}
EXP = {{{1, 2}}}
