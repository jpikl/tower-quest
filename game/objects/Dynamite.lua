-- Dependencies
local Assets = require("engine.Assets")
local Smoke  = require("game.objects.Smoke")
local Entity = require("game.objects.Entity")
local Room   = require("game.Room")

-- Dynamite class
local Dynamite = Entity:derive("Dynamite")

-- Variables
local explosionSound = Assets.sounds.death

-- Constructor
function Dynamite:Dynamite(x, y, type)
    self:Entity(x, y)      -- Superclass constructor
    self.weight = 1        -- Weight
    self.type = type       -- Type (small/big)
    self.explosive = true -- Can explode
    self.sinkable = true   -- Can be sink
end

-- Tests if object collide with another one
function Dynamite:collideWith(object)
    -- Collision only for living entities
    return object:is("Enemy") or object:is("Player")
end

-- Draws dynamite
function Dynamite:draw()
    self:drawSprite(self.type == "small" and 19 or 20)
end

-- Updates dynamite
function Dynamite:update(delta)
    self.z = self.moving and 2 or 0 -- Moving dynamite has higher rendering order
    Entity.update(self, delta)

    -- There is timeout for explosion
    if self.explodeTimeout then
        self.explodeTimeout = self.explodeTimeout - delta
        if self.explodeTimeout <= 0 then
            self:explode()
            return
        end
    end

    -- Check for collision
    for obj in Room.getObjectsIterator(self) do
        if not obj.surface and not obj:is("Smoke") and
           self:intersects(obj, 5) then -- Must be 5 (precisely computed)
            self:explode() -- No timeout, explode immediately
            return
        end
    end
end

-- Destroys dynamite
function Dynamite:destroy(cause)
    -- Nearby explosion causes immediate destruction
    if cause and self:intersects(cause, 5) then
        self:explode()
    -- Distant explosion causes delayed destruction
    elseif not self.explodeTimeout then
        self.explodeTimeout = 0.25
    end
end

-- Explodes dynamite
function Dynamite:explode()
    self.destroyed = true

    -- Destroy nearby objects
    local explosionBorder = self.type == "small" and 1 or -5  -- Must be 1 and -5 (precisely computed)
    for obj in Room.getObjectsIterator(self) do
        if obj.explosive and not obj.destroyed and
           self:intersects(obj, explosionBorder) then
            obj:destroy(self)
            Room.addObject(Smoke(obj)) -- Smoke effect
        end
    end

    -- Add additional smoke effects
    Room.addObject(Smoke(self))
    if self.type == "big" then
        Room.addObject(Smoke(self, -16, -16))
        Room.addObject(Smoke(self,   0, -16))
        Room.addObject(Smoke(self,  16, -16))
        Room.addObject(Smoke(self, -16,   0))
        Room.addObject(Smoke(self,  16,   0))
        Room.addObject(Smoke(self, -16,  16))
        Room.addObject(Smoke(self,   0,  16))
        Room.addObject(Smoke(self,  16,  16))
    end

    -- Explosion sound
    explosionSound:stop()
    explosionSound:play()
end

return Dynamite
