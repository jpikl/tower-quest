-- Dependencies
local Entity = require("game.objects.Entity")

-- Barrel class
local Barrel = Entity:derive("Barrel")

-- Constructor
function Barrel:Barrel(x, y)
    self:Entity(x, y)      -- Superclass constructor
    self.weight = 1        -- Weight
    self.sinkable = true   -- Can be sink
    self.wooden = true     -- Is made from wood
    self.explosive = true -- Can explode
end

-- Tests if object collide with another one
function Barrel:collideWith(object)
    return not object:is("Dynamite")
end

-- Draws barrel
function Barrel:draw()
    self:drawSprite(12)
end

return Barrel
