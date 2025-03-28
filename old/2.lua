require "classy"

L = {}

TRUE = {L,0,{L,1,0}}
FALSE = {L,0,{L,1,0}}

THREE = {L,{L,{1,{1,{1,0}}}}}
local fac_part = {L,4,{L,5,{{3,4},{4,5}}}}
FAC =
{L,
	{L,
		{
			{
				{1,
					{L,
						{L,
							{
								0,
								{
									1,
									{L,
										{L,
											{
												{
													2,
													1
												},
												{
													1,
													0
												}
											}
										}
									}
								}
							}
						}
					}
				},
				{L,
					1
				}
			},
			{L,
				0
			}
		}
	}
}

local scale = 16

class ("Lambda", {
	parent = nil;
	depth = 0;

	getSize = function (self)
		error("Lambda.getSize is abstract and has not been implemented")
	end;
	render = function (self, x, y)
		local col = self:getInheritVal("color") or {1, 1, 1}
		love.graphics.setColor(col)
	end;
	cascadeFunc = function (self, func)
		error("Lambda.cascadeFunc is abstract and has not been implemented")
	end;

	getMultVal = function (self, field)
		return self.parent:getMultVal(field) * (self[field] or 1)
	end;
	getInheritVal = function (self, field)
		return self[field] or parent and self.parent:getInheritVal(field)
	end;

})

class ("Abstraction", {
	body = nil; --Lambda
	var = nil;

	__tostring = function (self)
		return ("λ%s.%s"):format(string.char(self.depth + 97), self.body)
	end;

	getSize = function (self)
		local w, h = self.body:getSize()
		return w, h + 2
	end;

	render = function (self, x, y)
		Lambda.render(self, x, y)
		local mw, mh = self:getSize()
		local w, h = self.body:getSize()
		self.body:render(x, y + mh - h - 2)
		love.graphics.rectangle("fill", (x) * scale, (y+mh-1) * scale, (mw-1) * scale, scale)
	end;

	apply = function (self, operand)
		local ret = Application:new{func = self, operand = operand}
		self.parent = ret
		operand.parent = ret
		return ret
	end;

	cascadeFunc = function (self, func)
		return func(Abstraction:new{
			body = self.body:cascadeFunc(func),
		})
	end;

}):extend(Lambda)

class ("Application", {
	func = nil; --Lambda
	operand = nil; --Lambda

	__tostring = function (self)
		return ("(%s%s)"):format(self.func, self.operand)
	end;

	getSize = function (self)
		local w1, h1 = self.func:getSize()
		local w2, h2 = self.operand:getSize()
		return w1 + w2, math.max(h1, h2) + 2
	end;

	render = function (self, x, y)
		Lambda.render(self, x, y)
		local mw, mh = self:getSize()
		local w1, h1 = self.func:getSize()
		local w2, h2 = self.operand:getSize()
		self.func:render(x, y + mh - h1)
		self.operand:render(x + w1, y + mh - h2)
		love.graphics.rectangle("fill", (x+1) * scale, y * scale, scale, mh * scale)
		love.graphics.rectangle("fill", (x+1) * scale, (y+2) * scale, (mw-w2) * scale, scale)
		love.graphics.rectangle("fill", (x+1+w1) * scale, (y+2) * scale, scale, (mh-h2-1) * scale)
	end;

	cascadeFunc = function (self, func)
		return func(Application:new{
			func = self.func:cascadeFunc(func),
			operand = self.operand:cascadeFunc(func)
		})
	end;

	reduce = function (self)
		if self.func:is(Application) then
			self.func = self.func:reduce()
			return self
		end
		return self.func.body:cascadeFunc(function (l)
			print(l, l.def, self.func)
			if l.def == self.func then
				return self.operand
			end
			return l
		end)
	end;

	colorReduction = function (self, color)
		local ret = self:cascadeFunc(function (l)
			print(l, l.def, self.func)
			if l.def == self.func then
				l.color = color
			end
			return l
		end)
		ret.operand.color = color
		ret.color = {0.8, 0, 1.0}
		return ret
	end;

}):extend(Lambda)

class ("Variable", {
	def = nil; --Abstraction
	jumps = nil; --Int

	__tostring = function (self)
		return ("%s"):format(string.char(self.def.depth + 97))
	end;

	getSize = function (self)
		return 4, 1
	end;

	render = function (self, x, y)
		Lambda.render(self, x, y)
		love.graphics.rectangle("fill", (x+1) * scale, y * scale, scale, 2 * (self.jumps) * scale)
	end;

	cascadeFunc = function (self, func)
		return func(Variable:new{def = self.def, jumps = self.jumps})
	end;

}):extend(Lambda)

function parseLambda(l, parent)
	if type(l) == "table" then
		if l[1] == L then
			local ret = Abstraction:new{parent = parent, depth = parent and parent.depth+1 or 0}
			ret.body = parseLambda(l[2], ret)
			return ret
		end
		local ret = Application:new{parent = parent, depth = parent and parent.depth or -1}
		ret.func = parseLambda(l[1], ret)
		ret.operand = parseLambda(l[2], ret)
		return ret
	end
	local p = parent
	local i = l
	while l > 0 do
		if p:is(Abstraction) then
			l = l - 1
		end
		p = p.parent
	end
	print("jumps:", i)

	return Variable:new{
		parent = parent,
		def = p,
		depth = parent.depth,
		jumps = i + 1
	}
end

local expr = parseLambda({{{L,{L,0}},{L,0}},{L,{0,0}}})

print(expr, expr:getSize())

function love.draw()
	local w, h = love.graphics.getDimensions()
	love.graphics.scale(1, -1)
	expr:render(0, -h / scale)
end

function love.mousepressed()
	expr = expr:reduce()
end
