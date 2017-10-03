-- Dependencies
local Class = require("engine.Class")
local Table = require("engine.Table")

-- Memento class
local Memento = Class("Memento")

-- Constructor
function Memento:Memento(source)
    local data = {}
    local lookup = {}

    -- Copy data from another memento if it exists
    if source then
        data = Table.copy(rawget(source, "__data"), lookup)
    end

    -- Initialize memento
    rawset(self, "__data", data)
    rawset(self, "__lookup", lookup)
end

-- Retrieves value from memento
function Memento:__index(key)
    return rawget(self, "__data")[key]
end

-- Copies value into memento
function Memento:__newindex(key, value)
    rawget(self, "__data")[key] = Table.copy(value, rawget(self, "__lookup"))
end

return Memento
