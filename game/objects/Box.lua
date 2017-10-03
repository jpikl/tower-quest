-- Dependencies
local Entity = require("game.objects.Entity")

-- Box class
local Box = Entity:derive("Box")

-- Constructor
function Box:Box(x, y)
    self:Entity(x, y)      -- Superclass constructor
    self.weight = 1        -- Weight
    self.sinkable = true   -- Can be sink
    self.wooden = true     -- Is made from wood
    self.explosive = true -- Can explode
end

-- Tests if object collide with another one
function Box:collideWith(object)
    return not object:is("Dynamite")
end

-- Draws box
function Box:draw()
    self:drawSprite(11)
end

return Box
