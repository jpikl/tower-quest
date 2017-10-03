-- Dependencies
local Playable = require("engine.Playable")
local Sequence = require("engine.Sequence")
local Table    = require("engine.Table")

-- Animation class
local Animation = Playable:derive("Animation")

-- Constructor
function Animation:Animation(sprites, descriptor)
    self.sprites = sprites -- Sprite sheet for all sequences
    self.sequences = {}    -- All animation sequences
    self.current = nil     -- Current sequence
    self.speed = 1         -- Animation speed
    self.time = 0          -- Animation time

    -- Creates default sequence if specified
    if descriptor then
        self:addSequence("default", descriptor)
    end
end

-- Adds animation sequence
function Animation:addSequence(name, descriptor)
    self.current = Sequence(self.sprites, descriptor)
    self.sequences[name] = self.current
    return self.current
end

-- Returns animation sequence
function Animation:getSequence(name)
    return self.sequences[name]
end

-- Sets animation sequence
function Animation:setSequence(name)
    self.current = self.sequences[name]
    return self
end

-- Sets animation speed
function Animation:setSpeed(speed)
    self.speed = speed
    return self
end

-- Returns animation speed
function Animation:getSpeed()
    return speed
end

-- Sets current sequence looping
function Animation:setLooping(value)
    self.current:setLooping(value)
    return self
end

-- Checks whether current sequence is looping
function Animation:isLooping()
    return self.current:getLooping()
end

-- Flips current sequence horizontally
function Animation:flipHorizontally()
    return self.current:flipHorizontally()
end

-- Flips current sequence vertically
function Animation:flipVertically()
    return self.current:flipVertically()
end

-- Sets animation frame number
function Animation:setFrame(number)
    self.time = self.current:frameToTime(number) / self.speed
    return self
end

-- Returns current or specific animation frame
function Animation:getFrame(number)
    if number then
        return self.current:getFrame(number)
    else
        return self.current:timeToFrame(self.time * self.speed)
    end
end

-- Tests if current sequence is finished
function Animation:isFinished()
    local current = self.current
    return current and not current.looping and self.time * self.speed >= current.total
end

-- Draws current sequence
function Animation:draw(x, y, ...)
    local frame = self:getFrame()
    if frame then
        frame:draw(x, y, ...)
    end
end

-- Creates copy of animation and all sequences
function Animation:clone()
    local copy = Playable.clone(self)
    copy.speed = self.speed
    copy.time = self.time
    copy.sequences = Table.clone(self.sequences)
    copy.current = nil
    for name, sequence in pairs(self.sequences) do
        if self.current == sequence then
            copy.current = copy.sequences[name]
        end
    end
    return copy
end

return Animation
