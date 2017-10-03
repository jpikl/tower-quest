-- Dependencies
local Assets = require("engine.Assets")
local Abyss  = require("game.objects.Abyss")
local Player = require("game.objects.Player")

-- Trap class
local Trap = Abyss:derive("Trap")

-- Constructor
function Trap:Trap(x, y)
    self:Abyss(x, y)                                -- Superclass constructor
    self.triggered = false                          -- Is trap triggered?
    self.opened = false                             -- Is hole opened?
    self.animation = Assets.animations.trap:clone() -- Hole opening animation
end

-- Tests if object collide with another one
function Trap:collideWith(object)
    -- When trap is not activated, no collisions
    if not self.triggered then
        return false
    -- Trap was activated, but player is still standing on it
    elseif not self.opened then
        return Abyss.collideWith(self, object) and object ~= Player.instance
    -- Trap is opened
    else
        return Abyss.collideWith(self, object)
    end
end

-- Draws trap
function Trap:draw()
    if not self.triggered then
        self:drawSprite(13)
    elseif not self.animation:isFinished() then
        self.animation:draw(self.x, self.y)
    else
        Abyss.draw(self)
    end
end

-- Updates trap
function Trap:update(delta)
    if not self.triggered then
        -- Trigger trap when player steps in
        if self:intersects(Player.instance, 3) then
            self.triggered = true
            Assets.sounds.trap:play()
        end
    elseif not self.opened then
        -- Open hole when player steps away
        if not self:intersects(Player.instance, 1) then
            self.opened = true
            self.animation:play()
        end
    else
        self.animation:update(delta)
        Abyss.update(self, delta)
    end
end

return Trap
