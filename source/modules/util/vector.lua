local VECTOR = {}
VECTOR.__index = VECTOR

function isvector(vec)
	return vec and type(vec) == "table" and vec.x and vec.y and vec.z
end

function vector(x, y, z)
	return setmetatable({ x = x or 0, y = y or 0, z = z or 0 }, VECTOR)
end

function VECTOR:__tostring()
	return ("[vector][%d, %d, %d]"):format(self.x, self.y, self.z)
end

function VECTOR:__add(vec)
	return vector(self.x + vec.x, self.y + vec.y, self.z + vec.z)
end

function VECTOR:__div(num)
	return vector(self.x / num, self.y / num, self.z / num)
end

function VECTOR:__eq(vec)
	return self.x == vec.x and self.y == vec.y and self.z == vec.z
end

function VECTOR:__mul(vec) --Multiply a vector by a number, or multiply a vector by a vector
	if isvector(self) and isvector(vec) then
		return vector(self.x * vec.x, self.y * vec.y, self.z * vec.z)
	elseif type(self) == "number" then
		return vector(self * vec.x, self * vec.y, self * vec.z)
	else
		return vector(self.x * vec, self.y * vec, self.z * vec)
	end
end

function VECTOR:__sub(vec)
    return vector(self.x - vec.x, self.y - vec.y,  self.z - vec.z)
end

function VECTOR:Cross(vec)
    return vector(self.y * vec.z - self.z * vec.y, self.z * vec.x - self.x * vec.z, self.x * vec.y - self.y * vec.x)
end

function VECTOR:Distance(vec) --The distance between two vectors
	return (self - vec):Length()
end

function VECTOR:DistToSqr(vec)
	return (self.x - vec.x)^2 + (self.y - vec.y)^2 + (self.z - vec.z)^2
end

function VECTOR:Dot(vec) --The dot product of two vectors
	return vec.x * self.x + vec.y * self.y + vec.z * self.z
end

function VECTOR:DotProduct(vec) --Duplicate of Dot
	return vec.x * self.x + vec.y * self.y + vec.z * self.z
end

function VECTOR:GetNormalized() --Gets the normal of two vectors
	local length = self:Length()
	return vector(self.x / length, self.y / length, self.z / length)
end

function VECTOR:GetNormal() --Duplicate of GetNormalized
	local length = self:Length()
	return vector(self.x / length, self.y / length, self.z / length)
end

function VECTOR:WithinAABox(mins, maxs)
	if self.x < mins.x or self.y < mins.y or self.z < mins.z or self.x > maxs.x or self.y > maxs.y or self.z > maxs.z then
		return false
	end
	return true
end

--[[function VECTOR:IsEqualTol(vec, tol)
	
end]]

function VECTOR:IsZero(vec)
	return vec.x == 0 and vec.y == 0 and vec.z == 0
end

function VECTOR:Length2D()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

function VECTOR:Length() --The length of a vector
	return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function VECTOR:Normalize() --Directly modifies the vector you pass it
	local length = self:Length()
	self.x = self.x / length
	self.y = self.y / length
	self.z = self.z / length
end

--[[function VECTOR:Rotate(ang) --Rotate a vector by degrees
	ang = math.rad(ang)
	return vector(self.x * math.cos(ang) - self.y * math.sin(ang), self.x * math.sin(ang) + self.y * math.cos(ang))
end]]

function VECTOR:Add(vec)
	self.x = self.x + vec.x
	self.y = self.y + vec.y
	self.z = self.z + vec.z
end

function VECTOR:Set(vec)
	self.x = vec.x
	self.y = vec.y
	self.z = vec.z
end

function VECTOR:Mul(scale)
	self.x = self.x * scale
	self.y = self.y * scale
	self.z = self.z * scale
end

function VECTOR:Zero() --Not sure why this would ever be needed, but hey who cares.. (taken from the garrysmod library)
	self.x = 0
	self.y = 0
	self.z = 0
end

function VECTOR:RayQuadIntersect(vDirection, vPlane, vX, vY)
	local vp = vDirection:Cross(vY)

	local d = vX:DotProduct(vp)

	if (d <= 0.0) then return end

	local vt = self - vPlane
	local u = vt:DotProduct(vp)
	if (u < 0.0 or u > d) then return end

	local v = vDirection:DotProduct(vt:Cross(vX))
	if (v < 0.0 or v > d) then return end

	return vector(u / d, v / d, 0)
end

function VECTOR:IsInFront(vec, normal)
	return (normal:Dot((vec - self):GetNormalized()) < 0)
end

function VECTOR:Clamp(min, max)
	self.x = math.Clamp(self.x, min, max)
	self.y = math.Clamp(self.y, min, max)
	self.z = math.Clamp(self.z, min, max)
	return self
end

function VECTOR:Project(vec)
	return self:Dot(vec) / vec:Dot(vec) * vec
end