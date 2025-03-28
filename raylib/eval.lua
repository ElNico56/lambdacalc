-- eval.lua

local L = L or {} -- unique symbol

local incFree
incFree = function(expr, value, depth)
	if type(expr) == "table" and expr[1] == L then
		-- if abstraction
		depth = depth or 0
		return {L, incFree(expr[2], value, depth + 1)}
	elseif type(expr) == "table" then
		-- if application
		local left = incFree(expr[1], value, depth)
		local right = incFree(expr[2], value, depth)
		return {left, right}
	else
		-- if variable
		if expr > (depth or 0) then
			return expr + value - 1
		end
		return expr
	end
end


local substitute
substitute = function(expr, value, depth)
	if type(expr) == "table" and expr[1] == L then
		-- if abstraction
		if depth then
			return {L, substitute(expr[2], value, depth + 1)}
		else
			return substitute(expr[2], value, 1)
		end
	elseif type(expr) == "table" then
		-- if application
		return {substitute(expr[1], value, depth)
		, substitute(expr[2], value, depth)}
	else
		-- if variable
		if expr == depth then
			return incFree(value, depth)
		end
		if expr > depth then
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
