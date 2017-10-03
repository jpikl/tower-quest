-- Dependencies
local Assets = require("engine.Assets")
local Object = require("game.objects.Object")

-- Ground class
local Ground = Object:derive("Ground")

-- Common sprites
Ground.sprites = Assets.sprites.background

-- Constructor
function Ground:Ground(...)
    self:Object(...)
end

return Ground
