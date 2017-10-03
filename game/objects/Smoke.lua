-- Dependencies
local Assets = require("engine.Assets")
local Object = require("game.objects.Object")

-- Smoke class
local Smoke = Object:derive("Smoke")

-- Constructor
function Smoke:Smoke(target, xOffset, yOffset)
    -- Smoke animation
    self.animation = Assets.animations.smoke:clone()
    self.animation:play()

    -- Location
    local width = self.animation.sprites[1].width
    local height = self.animation.sprites[1].height
    local x = target.x + (width - target.w) / 4 + (xOffset or 0)
    local y = target.y + (height - target.h) / 4 + (yOffset or 0)

    self:Object(x, y, 3) -- Superclass constructor
    self.flying = true   -- Is flying

    -- Play sound
    Assets.sounds.smoke:play()
end

-- Tests if object collide with another one
function Smoke:collideWith(object)
    return false
end

-- Draws smoke
function Smoke:draw()
    self.animation:draw(self.x - 2, self.y - 8)
end

-- Updates smoke animation
function Smoke:update(delta)
    self.animation:update(delta)
    self.destroyed = self.animation:isFinished()
end

return Smoke
