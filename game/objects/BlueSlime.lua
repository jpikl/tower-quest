-- Dependencies
local Assets = require("engine.Assets")
local Enemy  = require("game.objects.Enemy")
local Player = require("game.objects.Player")

-- Blue slime class
local BlueSlime = Enemy:derive("BlueSlime")

-- Variables
local slimeSpeed = 20 -- Slime speed (pixels per second)

-- Constructor
function BlueSlime:BlueSlime(x, y)
    self:Enemy(x, y, false) -- Superclass constructor

    -- Setup animation
    self.animation = Assets.animations.blueSlime:clone()
    self.animation:setFrame(love.math.random(1, 3)):play()
end

-- Draws red slime
function BlueSlime:draw()
    self.animation:draw(self.x, self.y - 3)
end

-- Updates red slime
function BlueSlime:update(delta)
    Enemy.update(self, delta)
    self.animation:update(delta)

    local player = Player.instance
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dir1 = (dx ~= 0) and (dx > 0 and "right" or "left")
    local dir2 = (dy ~= 0) and (dy > 0 and "down" or "up")

    if math.abs(dy) > math.abs(dx) then
        dir1, dir2 = dir2, dir1
    end
    if dir1 and not self:move(dir1, slimeSpeed) then
        if dir2 then
            self:move(dir2, slimeSpeed)
        end
    end
end

return BlueSlime
