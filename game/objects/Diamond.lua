-- Dependencies
local Assets = require("engine.Assets")
local Chest  = require("game.objects.Chest")
local Object = require("game.objects.Object")
local Player = require("game.objects.Player")
local Room   = require("game.Room")

-- Diamond module
local Diamond = Object:derive("Diamond")

-- Variables
local sound = Assets.sounds.diamond
local particleImage = Assets.images.particle

-- Constructor
function Diamond:Diamond(x, y, sprite, powerUp)
    self:Object(x, y)      -- Superclass constructor
    self.obtained = false  -- Is obtained?
    self.sprite = sprite   -- Sprite number
    self.powerUp = powerUp -- Type of power-up
    self.timeout = 1       -- Timeout to destroy

    -- Particles
    local color = Player.powerUpColors[self.powerUp]
    local r, g, b = color[1], color[2], color[3]
    self.particles = love.graphics.newParticleSystem(particleImage, 8)
    self.particles:setEmissionRate(3)
    self.particles:setParticleLifetime(2)
    self.particles:setLinearAcceleration(0, -15, 0, -15)
    self.particles:setSizes(0.5, 0.5, 0.1)
    self.particles:setColors(r, g, b, 192, r, g, b, 192, r, g, b, 0)
    self.particles:setPosition(self.w / 2, self.h / 2)
    self.particles:setAreaSpread("normal", self.w / 5, self.h / 5)
    self.particles:setInsertMode("random")

    Room.diamondsCount = Room.diamondsCount + 1
end

-- Tests if object collide with another one
function Diamond:collideWith(object)
    -- No collisions when diamond is already obtained
    return not (self.obtained or object:is("Player") or object:is("Dynamite"))
end

-- Draws diamond
function Diamond:draw()
    if self.obtained then
        love.graphics.setColor(255, 255, 255, 255 * self.timeout)
        self:drawSprite(self.sprite)
        love.graphics.setColor(255, 255, 255)
    else
        self:drawSprite(self.sprite)
        Room.drawParticles(self.particles, self.x, self.y)
    end
end

-- Updates diamond
function Diamond:update(delta)
    if self.obtained then
        -- Update destroy timeout when diamond is obtained
        self.timeout = self.timeout - delta
        if self.timeout <= 0 then
            self.destroyed = true
            Room.diamondsCount = Room.diamondsCount - 1
        end
    else
        -- Update particles
        self.particles:update(delta)
        -- Check if player can obtain diamond
        if self:intersects(Player.instance, 6) then
            self.obtained = true
            self.particles:stop()
            sound:play()
            Player.instance:setPowerUp(self.powerUp)
            Room.drawParticles(self.particles, self.x, self.y, 2)
        end
    end
end

-- Restores diamond particles after restoring object from memento
function Diamond:restored()
    if not self.obtained then
        self.particles:start()
    end
end

return Diamond
