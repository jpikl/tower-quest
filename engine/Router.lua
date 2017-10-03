-- Dependencies
local Class  = require("engine.Class")
local Table  = require("engine.Table")

-- Router class
local Router = Class("Router")

-- Constructor
function Router:Router()
    self.listeners = Table()
end

-- Adds listener of events
function Router:addListener(listener)
    self.listeners:insert(listener)
end

-- Removes listener of events
function Router:removeListener(listener)
    self.listeners:delete(listener)
end

-- Generates event for all listeners
function Router:fireEvent(name, ...)
    self:fireSourceEvent(nil, name, ...)
end

-- Generates event for all listeners except the source
function Router:fireSourceEvent(source, name, ...)
    for listener in self.listeners:iterator() do
        if listener ~= source then
            local callback = listener[name]
            if callback then
                callback(listener, ...)
            end
        end
    end
end
