-- Dependencies
local Assets = require("engine.Assets")
local Object = require("game.objects.Object")
local Player = require("game.objects.Player")
local Room   = require("game.Room")

-- Chest class
local Chest = Object:derive("Chest")

-- Variables
local sound = Assets.sounds.chest

-- Constructor
function Chest:Chest(x, y)
    self:Object(x, y)     -- Superclass constructor
    self.opened = false   -- Is opened?
    Chest.instance = self -- Current instance
end

-- Tests if object collide with another one
function Chest:collideWith(object)
    return not object:is("Dynamite")
end

-- Draws chest
function Chest:draw()
    if Room.keyObtained then
        self:drawSprite(5)
    elseif self.opened then
        self:drawSprite(4)
    else
        self:drawSprite(3)
    end
end

-- Updates chest
function Chest:update()
    -- Open chest when there are no diamonds
    if not self.opened and Room.diamondsCount == 0 then
        self.opened = true
        sound:play()
    end
    -- Check if player can grab the key
    local player = Player.instance
    if self.opened and not Room.keyObtained and self:intersects(player, -1) then
        if player.x == self.x then
            -- Player is in the same column
            Room.keyObtained = player.y < self.y and player.state == "down"
                            or player.y > self.y and player.state == "up"
        elseif player.y == self.y then
            -- Player is in the same row
            Room.keyObtained = player.x < self.x and player.state == "right"
                            or player.x > self.x and player.state == "left"
        end
    end
end

return Chest
