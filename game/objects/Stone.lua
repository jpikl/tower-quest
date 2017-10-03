-- Dependencies
local Entity = require("game.objects.Entity")

-- Stone class
local Stone = Entity:derive("Stone")

-- Constructor
function Stone:Stone(x, y)
    self:Entity(x, y)      -- Superclass constructor
    self.weight = 2        -- Weight
    self.sinkable = true   -- Can be sink
    self.explosive = true -- Can explode
end

-- Tests if object collide with another one
function Stone:collideWith(object)
    return not object:is("Dynamite")
end

-- Draws box
function Stone:draw()
    self:drawSprite(13)
end

return Stone
