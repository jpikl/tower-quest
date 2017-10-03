-- Dependencies
local Entity = require("game.objects.Entity")

-- Rock class
local Rock = Entity:derive("Rock")

-- Constructor
function Rock:Rock(x, y)
    self:Entity(x, y)      -- Superclass constructor
    self.weight = 4        -- Weight
    self.sinkable = true   -- Can be sink
    self.explosive = true -- Can explode
end

-- Tests if object collide with another one
function Rock:collideWith(object)
    return not object:is("Dynamite")
end

-- Draws rock
function Rock:draw()
    self:drawSprite(25)
end

return Rock
