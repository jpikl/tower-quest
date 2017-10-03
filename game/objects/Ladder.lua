-- Dependencies
local Assets = require("engine.Assets")
local Exit   = require("game.objects.Exit")

-- Ladder class
local Ladder = Exit:derive("Ladder")

-- Draws ladder
function Ladder:draw()
    if self.opened then
        self:drawSprite(15)
    else
        self:drawSprite(14)
    end
end

return Ladder
