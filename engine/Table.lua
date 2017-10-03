-- Table module
local Table = {}

-----------------------------------------------------------
-- Array operations
-----------------------------------------------------------

-- Removes all occurrences of an element from array
function Table.delete(array, target)
    Table.filter(array, function(i, value)
        return value == target
    end)
end

-- Removes all array elements selected by the filter
function Table.filter(array, filter)
    for i = #array, 1, -1 do
        if filter(i, array[i]) then
            table.remove(array, i)
        end
    end
end

-- Returns iterator over all array elements
function Table.iterator(array)
    local i = 0
    return function(array)
        i = i + 1
        return array[i]
    end, array
end

-- Converts array to set
function Table.set(array)
    local set = {}
    for i, value in ipairs(array) do
        set[value] = true
    end
    return set
end

-----------------------------------------------------------
-- Table operations
-----------------------------------------------------------

-- Reduces table to a single value using operation
function Table.reduce(source, result, operation)
    for key, value in pairs(source) do
        result = operation(result, key, value)
    end
    return result
end

-- Returns table with inverted key-value pairs
function Table.invert(source)
    local inversion = {}
    for key, value in pairs(source) do
        inversion[value] = key
    end
    return inversion
end

-- Forward declarations
local copy = nil
local merge = nil
local getCopyParams = nil

-- Creates deep copy of a table or another object
-- Modes: 'clone'     - use clone method to copy objects when is available
--        'data'      - copy only data (ignore functions)
--        'metatable' - make also copies of metatables
function Table.copy(source, ...)
    return copy(source, getCopyParams(...))
end

-- Alias for Table.copy with 'clone' mode
function Table.clone(source, ...)
    return copy(source, getCopyParams(..., "clone"))
end

-- Merges table with another one using Table.copy function
-- Modes: same as for Table.copy
--        'keep' - do not override existing values in target table
function Table.merge(target, source, ...)
    return merge(target, source, getCopyParams(...))
end

-- Prepares copy/merge function parameters
getCopyParams = function(first, ...)
    local lookup, modes
    if type(first) == "table" then
        -- Parameters: lookup, mode1, mode2, ...
        lookup = first
        modes = Table.set { ... }
    else
        -- Parameters: mode1, mode2, ...
        lookup = {}
        modes = Table.set { first, ... }
    end
    return lookup, modes
end

-- Internal copy function
copy = function(source, lookup, modes)
    if type(source) == "function" and modes["data"] then
        return nil
    elseif type(source) ~= "table" then
        return source
    elseif lookup[source] ~= nil then
        return lookup[source]
    elseif type(source.clone) == "function" and modes["clone"] then
        return source:clone()
    else
        local target = {}
        local metatable = getmetatable(source)
        merge(target, source, lookup, modes)
        if metatable and modes["metatable"] then
            metatable = copy(metatable, lookup, modes)
        end
        return setmetatable(target, metatable)
    end
end

-- Internal merge function
merge = function(target, source, lookup, modes)
    lookup[source] = target
    for key, value in pairs(source) do
        if  (key ~= nil and value ~= nil)
        and (not modes["data"] or type(key) ~= "function" and type(value) ~= "function")
        and (not modes["keep"] or target[key] == nil) then
            key = copy(key, lookup, modes)
            value = copy(value, lookup, modes)
            target[key] = value
        end
    end
    return target
end

-----------------------------------------------------------
-- OOP operations
-----------------------------------------------------------

-- Creates new table
function Table:new(source)
    return setmetatable(source or {}, self)
end

-- Allow to use table as a class
Table.__index = Table
return setmetatable(Table, { __index = table, __call = Table.new })
