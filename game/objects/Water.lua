-- Dependencies
local Assets = require("engine.Assets")
local Sink   = require("game.objects.Sink")
local Room   = require("game.Room")

-- Water class
local Water = Sink:derive("Water")

-- Variables
local sound = Assets.sounds.water
local particleImage = Assets.images.particle

-- Constructor
function Water:Water(x, y)
    self:Sink(x, y) -- Superclass constructor
end

-- Tests if object collide with another one
function Water:collideWith(object)
    -- Collision for non-sinkable objects when there is no other object in water yet
    return not self.content and Sink.collideWith(self, object)
end

-- Throws object into the water
function Water:sinkObject(object)
    -- Make wooden thins float
    if object.wooden then
        self.content = object
    end

    -- Play water splash sound
    sound:play()

    -- Create water splash particles
    local particles = love.graphics.newParticleSystem(particleImage, 32)
    particles:setPosition(0.5 * self.w, 0.75 * self.h)
    particles:setEmissionRate(1000)
    particles:setSpread(0.75)
    particles:setParticleLifetime(1)
    particles:setDirection(-math.pi / 2)
    particles:setLinearAcceleration(0, 150, 0, 150)
    particles:setSpeed(40, 50)
    particles:setSizes(0.4)
    particles:setColors(26, 69, 126, 255, 26, 69, 126, 0)
    Room.drawParticles(particles, self.x, self.y, 1)
end

-- Returns number of a sprite which is drawn as background
function Water.getBackgroundSprite(classes)
    if classes.tc:is("Water") then
        return Water.sprites[26]
    else
        return Water.sprites[25]
    end
end

-- Draws water
function Water:draw()
    -- Draw object inside if exists
    if self.content then
        if self.content:is("Box") then
            self.content.sprites[17]:draw(self.x, self.y)
        elseif self.content:is("Barrel") then
            self.content.sprites[18]:draw(self.x, self.y)
        end
    end
end

-- Updates water
function Water:update(delta)
    if not self.content then
        Sink.update(self, delta)
    end
end

return Water
