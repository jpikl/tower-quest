-- Dependencies
local Assets = require("engine.Assets")
local Enemy  = require("game.objects.Enemy")

-- Red slime class
local RedSlime = Enemy:derive("RedSlime")

-- Constructor
function RedSlime:RedSlime(x, y)
    self:Enemy(x, y, false) -- Superclass constructor

    -- Slime animation
    self.animation = Assets.animations.redSlime:clone()
    self.animation:setFrame(love.math.random(1, 2)):play()
end

-- Draws red slime
function RedSlime:draw()
    self.animation:draw(self.x, self.y - 3)
end

-- Updates red slime
function RedSlime:update(delta)
    self.animation:update(delta)
end

return RedSlime
