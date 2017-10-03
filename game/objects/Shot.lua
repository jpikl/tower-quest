-- Dependencies
local Assets = require("engine.Assets")
local Entity = require("game.objects.Entity")
local Room   = require("game.Room")

-- Shot class
local Shot = Entity:derive("Shot")

-- Variables
local sound = Assets.sounds.shot
local particleImage = Assets.images.particle

function Shot:Shot(x, y, direction)
    self:Entity(x, y, 3, 8, 8)
    self.flying = true     -- Is flying
    self.explosive = true -- Can explode

    -- Movement
    local dx, dy = Entity.createVector(direction, 1000)
    self:moveTo(dx, dy, 200)
end

-- Tests if object collide with another one
function Shot:collideWith(object)
    return false
end

-- Draws shot
function Shot:draw()
    self:drawSprite(16)
end

-- Updates shot
function Shot:update(delta)
    Entity.update(self, delta)

    -- Check for enemy collisions
    for obj in Room.getObjectsIterator(self) do
        if obj:is("Enemy") and self:intersects(obj, 2) then
            obj:petrify(5)
            self.destroyed = true
            return
        end
    end

    -- Check for collisions with other objects
    if Room.isCollision(self, 1) then
        self.destroyed = true
        sound:play()

        -- Create particles
        local particles = love.graphics.newParticleSystem(particleImage, 16)
        particles:setPosition(self.w / 2, self.h / 2)
        particles:setEmissionRate(1000)
        particles:setSpread(1)
        particles:setParticleLifetime(1)
        particles:setDirection(-math.pi / 2)
        particles:setLinearAcceleration(0, 150, 0, 150)
        particles:setSpeed(50, 60)
        particles:setSizes(0.5)
        particles:setColors(255, 0, 0, 255, 255, 0, 0, 0)
        Room.drawParticles(particles, self.x, self.y, 1)
    end
end

return Shot
