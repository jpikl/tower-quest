-- Dependencies
local Class = require("engine.Class")
local Math  = require("engine.Math")
local Table = require("engine.Table")

-- Sequence class
local Sequence = Class("Sequence")

-- Parses sequence descriptor
local function parseSequence(sprites, descriptor)
    local frames = {}
    local durations = {}
    for token in descriptor:gmatch("[^ ,]+") do
        local item, duration = token:match("(.+):(.+)")
        duration = tonumber(duration)
        if not item or not duration then
            item = token
            duration = 1
        end
        local from, to = item:match("(.+)-(.+)")
        from, to = tonumber(from), tonumber(to)
        if not from or not to then
            from = tonumber(item)
            to = from
        end
        if from and to then
            for i = from, to do
                frames[#frames + 1] = sprites[i]
                durations[#durations + 1] = duration
            end
        end
    end
    return frames, durations
end

-- Constructor
function Sequence:Sequence(frames, durations)
    if Class.is(frames, "SpriteSheet") and type(durations) == "string" then
        frames, durations = parseSequence(frames, durations)
    end
    self.frames = frames             -- Sequence frames
    self.durations = durations       -- Durations of frames
    self.total = Math.sum(durations) -- Total duration of sequence
    self.looping = false             -- Is repeated?
end

-- Sets sequence looping
function Sequence:setLooping(looping)
    self.looping = looping ~= false
    return self
end

-- Checks whether sequence is looping
function Sequence:isLooping()
    return self.looping
end

-- Returns specified frame
function Sequence:getFrame(number)
    return self.frames[number]
end

-- Returns time when the specified frame begins
function Sequence:frameToTime(number)
    local time = 0
    for i = 1, number - 1 do
        time = time + (self.durations[i] or 0)
    end
    return time
end

-- Returns frame that begins at the specified time
function Sequence:timeToFrame(time)
    if self.looping then
        time = time % self.total
    end
    local total = 0
    for i, duration in ipairs(self.durations) do
        total = total + duration
        if total > time then
            return self.frames[i]
        end
    end
    return self.frames[#self.frames]
end

-- Flips all frames vertically
function Sequence:flipVertically()
    local done = {}
    for i, frame in ipairs(self.frames) do
        if not done[frame] then
            frame:flipVertically()
            done[frame] = true
        end
    end
end

-- Flips all frames horizontally
function Sequence:flipHorizontally()
    local done = {}
    for i, frame in ipairs(self.frames) do
        if not done[frame] then
            frame:flipHorizontally()
            done[frame] = true
        end
    end
end

-- Makes a copy of sequence
function Sequence:clone()
    local copy = Class.clone(self)
    self.frames = Table.clone(self.frames)
    copy.looping = self.looping
    return copy
end

return Sequence
