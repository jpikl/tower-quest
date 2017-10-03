-- Dependencies
local Assets = require("engine.Assets")
local Config = require("engine.Config")
local Entity = require("game.objects.Entity")
local Shot   = require("game.objects.Shot")
local Room   = require("game.Room")

-- Player class
local Player = Entity:derive("Player")

-- Variables
local animation = Assets.animations.player -- Player animation
local deathSound = Assets.sounds.death     -- Death sound

-- Colors for each power-up
Player.powerUpColors = {
    none = { 226, 255, 136 },
    shot = { 241, 86, 24 },
    power =  { 63, 22, 1 },
    immortality = { 160, 167, 241 },
    speed = { 251, 237, 142 }
}

-- Constructor
function Player:Player(x, y)
    self:Entity(x, y, 2)               -- Superclass constructor
    self.alive = true                  -- Is player alive?
    self.power = 2                     -- Player power
    self.oddStep = false               -- Used for animation
    self.explosive = true             -- Can be killed by explosion
    self:setState("stop")              -- Set initial state
    self.animation = animation:clone() -- Player animation

    -- Current instance
    Player.instance = self
end

-- Tests if object collide with another one
function Player:collideWith(object)
    -- No collisions for flying objects and mortal enemies
    return not (object.flying or object.mortal)
end

-- Sets player state
function Player:setState(state)
    if self.state ~= state then
        self.state = state
        self.pushDelay = Config.pushDelay and 0.2 or 0
    end
end

-- Moves player left
function Player:moveLeft()
    self:setState("left")
end

-- Moves player right
function Player:moveRight()
    self:setState("right")
end

-- Moves player up
function Player:moveUp()
    self:setState("up")
end

-- Moves player down
function Player:moveDown()
    self:setState("down")
end

-- Stops player
function Player:stop()
    self.state = "stop"
end

-- Tries to destroy player
function Player:destroy()
    self:kill()
end

-- Tries to kill player
function Player:kill()
    if self.alive and self.powerUp ~= "immortality" then
        self.alive = false
        self.destroyTimeout = 0.5
        deathSound:play()
    end
end

-- Makes shot
function Player:shot()
    if self.powerUp == "shot" then
        local x = self.x + 4
        local y = self.y + 4
        Room.addObject(Shot(x, y, self.direction))
        self:resetPowerUp()
    end
end

-- Resets player power-up
function Player:resetPowerUp()
    self.powerUp = nil
    self.power = 2
end

-- Sets player power-up
function Player:setPowerUp(powerUp)
    if powerUp and powerUp ~= "none" then
        self:resetPowerUp()
        self.powerUp = powerUp
        self.powerUpTimeout = 10
        if powerUp == "power" then
            self.power = 4
        end
    end
end

-- Draws player
function Player:draw()
    -- Set animation sequence for current direction
    self.animation:setSequence(self.direction)

    -- Set alpha when player is dying
    if not self.alive then
        love.graphics.setColor(255, 255, 255, 255 * 2 * self.destroyTimeout)
    -- Blend color when player has power-up
    elseif self.powerUp then
        local timeout = self.powerUpTimeout
        local percentage = (timeout % 2 > 1) and (timeout % 1) or (1 - timeout % 1)
        local color = Player.powerUpColors[self.powerUp]
        local base = percentage * 255
        local r = base + (1 - percentage) * color[1]
        local g = base + (1 - percentage) * color[2]
        local b = base + (1 - percentage) * color[3]
        love.graphics.setColor(r, g, b)
        -- Add timeout to batch
        Room.drawTimeout(timeout, self.x, self.y)
    end

    -- Draw player
    self.animation:draw(self.x, self.y - 2)
    love.graphics.setColor(255, 255, 255)
end

-- Updates player
function Player:update(delta)
    -- Update destroy timeout when player is death
    if not self.alive then
        self.destroyTimeout = self.destroyTimeout - delta
        if self.destroyTimeout <= 0 then
            self.destroyed = true
        end
        return
    end

    -- Update power-up timeout
    if self.powerUp then
        self.powerUpTimeout = self.powerUpTimeout - delta
        if self.powerUpTimeout <= 0 then
            self:resetPowerUp()
        end
    end

    -- Update movement
    local moving = self.moving
    Entity.update(self, delta)

    -- Update walk animation
    if moving then
        self.animation:update(delta)
    end

    -- Setup new movement
    if self.state ~= "stop" and not self.moving then
        local speed = self.powerUp == "speed" and 60 or 40
        if not self:move(self.state, speed) then
            if self.pushDelay <= 0 then
                self:push(self.state, speed)
            else
                self.pushDelay = self.pushDelay - delta
            end
        end
    end

    -- Setup walk animation
    if moving ~= self.moving then
        if self.moving then
            self.animation:play():setFrame(self.oddStep and 4 or 2)
        else
            self.animation:stop()
            self.oddStep = not self.oddStep
        end
    end
end

-- Stores player data to memento
function Player.persist(memento)
    memento.playerInstance = Player.instance
end

-- Restores player data from memento
function Player.restore(memento)
    Player.instance = memento.playerInstance
end

return Player
