-- Dependencies
local Assets    = require("engine.Assets")
local Entity    = require("game.objects.Entity")
local FakeStone = require("game.objects.FakeStone")
local Player    = require("game.objects.Player")
local Smoke     = require("game.objects.Smoke")
local Room      = require("game.Room")

-- Enemy class
local Enemy = Entity:derive("Enemy")

-- Common sprites
Enemy.sprites = Assets.sprites.enemies

-- Constructor
function Enemy:Enemy(x, y, mortal)
    self:Entity(x, y)      -- Superclass constructor
    self.mortal = mortal   -- Can kill player
    self.explosive = true -- Can explode
end

-- Tests if object collide with another one
function Enemy:collideWith(object)
    -- No collision for objects that can petrify/destroy enemy
    -- No collision between player and mortal enemies
    return not (object:is("Shot") or object:is("Dynamite") or (self.mortal and object:is("Player")))
end

-- Updates enemy
function Enemy:update(delta)
    Entity.update(self, delta)
    -- Kill player on contact when enemy is mortal
    if self.mortal and self:intersects(Player.instance, 3) then
        Player.instance:kill()
    end
end

-- Destroys enemy
function Enemy:destroy()
    Room.addObject(Smoke(self)) -- Add smoke effect
    Entity.destroy(self)
end

-- Petrifies enemy for a specified time
function Enemy:petrify(time)
    Room.addObject(FakeStone(self, time))
    self:destroy()
end

return Enemy
