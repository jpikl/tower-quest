-- Dependencies
local Assets = require("engine.Assets")
local Entity = require("game.objects.Entity")
local Player = require("game.objects.Player")
local Room   = require("game.Room")

-- Sword class
local Sword = Entity:derive("Sword")

-- Variables
local sprites = Assets.sprites.enemies
local particleImage = Assets.images.particle

-- Constructor
function Sword:Sword(x, y, direction, creator)
    -- Initialize object for the specified direction
    if direction == "up" then
        self:Entity(x - 3, y - 12, 2, 6, 12)
        self.sprite = 10
    elseif direction == "down" then
        self:Entity(x - 3, y, 2, 6, 12)
        self.sprite = 11
    elseif direction == "right" then
        self:Entity(x, y - 3, 2, 12, 6)
        self.sprite = 12
    else
        self:Entity(x - 12, y - 3, 2, 12, 6)
        self.sprite = 13
    end

    self.creator = creator -- Creator of this sword
    self.flying = true     -- Is flying
    self.explosive = true -- Can explode

    -- Movement
    local dx, dy = Entity.createVector(direction, 1000)
    self:moveTo(dx, dy, 300)
end

-- Tests if object collide with another one
function Sword:collideWith(object)
    return false
end

-- Draws sword
function Sword:draw()
    sprites[self.sprite]:draw(self.x, self.y)
end

-- Updates sword
function Sword:update(delta)
    Entity.update(self, delta)

    -- Check for player collisions
    if self:intersects(Player.instance, 2) then
        Player.instance:kill()
    end

    -- Check for collisions with other objects
    if Room.isCollision(self, 1) then
        self.destroyed = true
        -- Create particles
        local particles = love.graphics.newParticleSystem(particleImage, 6)
        particles:setPosition(self.w / 2, self.h / 2)
        particles:setEmissionRate(1000)
        particles:setSpread(1)
        particles:setParticleLifetime(1)
        particles:setDirection(-math.pi / 2)
        particles:setLinearAcceleration(0, 150, 0, 150)
        particles:setSpeed(50, 60)
        particles:setSizes(0.5)
        particles:setColors(36, 48, 47, 255, 36, 48, 47, 0)
        Room.drawParticles(particles, self.x, self.y, 1)
    end
end

return Sword
