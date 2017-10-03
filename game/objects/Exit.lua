-- Dependencies
local Assets = require("engine.Assets")
local Player = require("game.objects.Player")
local Wall   = require("game.objects.Wall")
local Game   = require("game.states.Game")
local Room   = require("game.Room")

-- Exit class
local Exit = Wall:derive("Exit")

-- Common sprites
Exit.sprites = Assets.sprites.objects

-- Variables
local exitSound = Assets.sounds.exit

-- Constructor
function Exit:Exit(x, y)
    self:Object(x, y)    -- Superclass constructor
    self.opened = false  -- Is opened?
    self.used = false    -- Was used by the player?
end

-- Tests if object collide with another one
function Exit:collideWith(object)
    return not (Room.keyObtained and object == Player.instance)
end

-- Updates exit
function Exit:update(delta)
    if (not self.opened) and Room.keyObtained then
        exitSound:play()
        self.opened = true
    end

    if self.opened and not self.used and self:intersects(Player.instance, 6) then
        Game.completeRoom()
        self.used = true
    end
end

return Exit
