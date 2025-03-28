-- defs.lua

local L = L or {} -- unique symbol

local function _num(n)
	if n == 0 then
		return 1
	end
	return {2, _num(n - 1)}
end

function N(n)
	return {L, {L, _num(n)}}
end

-- Combinator Birds

M = {L, {1, 1}}                     -- Mockingbird
S = {L, {L, {L, {{3, 1}, {2, 1}}}}} -- Starling
K = {L, {L, 2}}                     -- Kestrel
KI = {L, {L, 1}}                    -- Kite
I = {L, 1}                          -- Idiot
O = {L, {L, {1, {2, 1}}}}           -- Owl

Lark = {L, {L, {2, {1, 1}}}}        -- Lark
Y = {{S, Lark}, Lark}
Y = {L, {{L, {2, {1, 1}}}, {L, {2, {1, 1}}}}}
Theta = {Y, O}

I1 = {L, {L, {2, 1}}}
I2 = {L, {L, {L, {{3, 2}, 1}}}}
I3 = {L, {L, {L, {L, {{{4, 3}, 2}, 1}}}}}
I4 = {L, {L, {L, {L, {L, {{{{5, 4}, 3}, 2}, 1}}}}}}

-- Arithmetic

MUL = {L, {L, {L, {2, {3, 1}}}}}
EXP = {L, {L, {1, 2}}}
