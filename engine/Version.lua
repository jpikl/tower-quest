-- Dependencies
local Class = require("engine.Class")

-- Version class
local Version = Class("Version")

-- Creates version from string value
function Version:Version(value, precision)
    for number in (value or "0"):gmatch("(%d+)%.?") do
        self[#self + 1] = tonumber(number)
        if precision and #self >= precision then
            break
        end
    end
end

-- Compares version with another one, using three-way comparison
function Version:compare(other)
    for i = 1, math.max(#self, #other) do
        local selfNumber = self[i] or 0
        local otherNumber = other[i] or 0
        if selfNumber ~= otherNumber then
            return selfNumber - otherNumber
        end
    end
    return 0
end

-- Tests if version is equal to another one
function Version:__eq(other)
    return self:compare(other) == 0
end

-- Tests if version is lower than another one
function Version:__lt(other)
    return self:compare(other) < 0
end

-- Tests if version is lower or equal to another one
function Version:__le(other)
    return self:compare(other) <= 0
end

-- Converts version to string
function Version:__tostring()
    return table.concat(self, ".")
end

return Version
