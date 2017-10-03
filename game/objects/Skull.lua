-- Dependencies
local Assets = require("engine.Assets")
local Enemy  = require("game.objects.Enemy")
local Room   = require("game.Room")

-- Skull class
local Skull = Enemy:derive("Skull")

-- Variables
local skullSpeed = 60
local directions = {
    ["left"] = { "left", "down", "up", "right" },
    ["right"] = {  "right", "up", "down", "left" },
    ["up"] = { "up", "left", "right", "down" },
    ["down"] = { "down", "right", "left", "up" }
}

-- Constructor
function Skull:Skull(x, y)
    self:Enemy(x, y, false) -- Superclass constructor

    -- Movement animation
    self.animation = Assets.animations.skull:clone()
    self.animation:setSequence("stop")
end

-- Draws skull
function Skull:draw()
    self.animation:draw(self.x, self.y - 2)
end

-- Updates skull
function Skull:update(delta)
    Enemy.update(self, delta)
    self.animation:update(delta)

    if self.mortal then
        if Room.keyObtained then
            self:destroy()
        elseif not self.moving then
            local nextDirection = directions[self.direction]
            for i = 1, 4 do
                if self:move(nextDirection[i], skullSpeed) then
                    break
                end
            end
        end
    elseif Room.diamondsCount == 0 then
        self.mortal = true
        self.animation:setSequence("movement")
        self.animation:play()
    end
end

return Skull
