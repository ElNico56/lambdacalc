-- eval.lua

local L = L or {} -- unique symbol

local incFree
incFree = function(expr, v, d)
	if type(expr) == "table" and expr[1] == L then
		-- if abstraction
		d = d or 0
		return {L, incFree(expr[2], v, d + 1)}
	elseif type(expr) == "table" then
		-- if application
		return {incFree(expr[1], v, d), incFree(expr[2], v, d)}
	else
		-- if variable
		if expr > (d or 0) then
			return expr + v - 1
		end
		return expr
	end
end


local substitute
substitute = function(expr, v, d)
	if type(expr) == "table" and expr[1] == L then
		-- if abstraction
		if d then
			return {L, substitute(expr[2], v, d + 1)}
		else
			return substitute(expr[2], v, 1)
		end
	elseif type(expr) == "table" then
		-- if application
		return {substitute(expr[1], v, d)
		, substitute(expr[2], v, d)}
	else
		-- if variable
		if expr == d then
			return incFree(v, d)
		end
		if expr > d then
			return expr - 1
		end
		return expr
	end
end

local reduce
---@param expr table|number
---@return table|number reduced_expr
---@return boolean reduced
reduce = function(expr)
	if type(expr) == "table" and expr[1] == L then
		-- if abstraction
		local res, s = reduce(expr[2])
		return {L, res}, s
	elseif type(expr) == "table" then
		-- if application
		if type(expr[1]) == "table" and expr[1][1] == L then
			return substitute(expr[1], expr[2]), true
		end
		local v, s = reduce(expr[1])
		if s then return {v, expr[2]}, true end
		v, s = reduce(expr[2])
		if s then return {expr[1], v}, true end
		return expr, false
	else
		-- if variable
		return expr, false
	end
end

return reduce
