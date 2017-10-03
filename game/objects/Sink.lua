-- Dependencies
local Ground = require("game.objects.Ground")
local Room   = require("game.Room")

-- Sink class
local Sink = Ground:derive("Sink")

-- Constructor
function Sink:Sink(x, y)
    self:Ground(x, y, -1) -- Superclass constructor
    self.surface = true   -- Is surface object
end

-- Tests if object collide with another one
function Sink:collideWith(object)
    -- No collision for sinkable of flying objects
    return not (object.sinkable or object.flying)
end

-- Sinks object (subclass should implement it)
function Sink:sinkObject(object)
end

-- Updates sink
function Sink:update(delta)
    -- Look for an object that is to be sink
    for obj in Room.getObjectsIterator(self) do
        if obj.sinkable and self:intersects(obj, 7) then
            obj.destroyed = true
            self:sinkObject(obj)
        end
    end
end

return Sink
