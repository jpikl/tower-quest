-- Dependencies
local Table = require("engine.Table")

-- Math module
local Math = {}

-- Unpacks array of numbers from table in case they are not already unpacked
local function packNumbers(first, ...)
    if type(first) == "table" then
        return first
    else
        return { first, ... }
    end
end

-- Packs array of numbers into table in case they are not already packed
local function unpackNumbers(first, ...)
    if type(first) == "table" then
        return unpack(first)
    else
        return first, ...
    end
end

-- Returns value inside the specified range
function Math.fit(value, low, high)
    if value < low then
        return low
    elseif value > high then
        return high
    else
        return value
    end
end

-- Sums all values
function Math.sum(...)
    return Table.reduce(packNumbers(...), 0, function(sum, i, value)
        return sum + value
    end)
end

-- Returns minimum of all values
function Math.min(...)
    return math.min(unpackNumbers(...))
end

-- Returns maximum of all values
function Math.max(...)
    return math.max(unpackNumbers(...))
end

return setmetatable(Math, { __index = math })
