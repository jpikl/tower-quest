-- Dependencies
local Assets = require("engine.Assets")
local Exit   = require("game.objects.Exit")

-- Door class
local Door = Exit:derive("Door")

-- Draws door
function Door:draw()
    if self.opened then
        self:drawSprite(2)
    else
        self:drawSprite(1)
    end
end

return Door
