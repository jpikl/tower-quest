-- Class module
local Class = {}

-- Derives new subclass of this class
function Class:derive(name, body)
    local subclass = body or {}
    subclass.__name = name
    subclass.__index = subclass
    subclass.__call = Class.new
    return setmetatable(subclass, self)
end

-- Extends this class from parent class
function Class:extend(superclass)
    if type(superclass) == "string" then
        superclass = require(superclass)
    end
    return setmetatable(self, superclass)
end

-- Creates new instance of this class
function Class:new(...)
    local instance = setmetatable({}, self)
    while self do
        local constructor = self[self.__name]
        if constructor then
            return instance, constructor(instance, ...)
        else
            self = getmetatable(self)
        end
    end
    return instance
end

-- Tests if object is instance of a class
function Class:is(target)
    while self do
        if self == target or self.__name == target then
            return true
        else
            self = getmetatable(self)
        end
    end
    return false
end

-- Creates shallow copy of object
function Class:clone()
    return setmetatable({}, { __index = self })
end

-- Bootstrap
return Class.derive({ __call = Class.derive }, "Class", Class)
