-- Dependencies
local Ground = require("game.objects.Ground")

-- Gravel class
local Gravel = Ground:derive("Gravel")

-- Constructor
function Gravel:Gravel(x, y)
    self:Ground(x, y)   -- Superclass constructor
    self.surface = true -- Is surface object
end

-- Tests if object collide with another one
function Gravel:collideWith(object)
    -- Collisions only for enemies
    return object:is("Enemy")
end

-- Returns number of a sprite which is drawn as background
function Gravel.getBackgroundSprite()
    return Gravel.sprites[9]
end

return Gravel
