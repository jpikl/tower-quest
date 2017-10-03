-- Dependencies
local Ground = require("game.objects.Ground")

-- Arrow class
local Arrow = Ground:derive("Arrow")

-- Variables
local oppositeDirections = {
    left = "right",
    right = "left",
    up = "down",
    down = "up"
}

local typeToSpriteNumber = {
    left = 21,
    right = 22,
    up = 23,
    down = 24
}

-- Constructor
function Arrow:Arrow(x, y, direction)
    self:Ground(x, y, -1)                                  -- Superclass constructor
    self.blockingDirection = oppositeDirections[direction] -- Direction in which movement is blocked
    self.surface = true                                    -- Is surface object
end

-- Tests if object collide with another one
function Arrow:collideWith(object)
    -- Collision in the blocking direction for non-flying objects
    return not object.flying and object.direction == self.blockingDirection
end

-- Returns number of a sprite which is drawn as background
function Arrow.getBackgroundSprite(classes, parameters)
    return Arrow.sprites[typeToSpriteNumber[parameters.cc[1]]]
end

return Arrow
