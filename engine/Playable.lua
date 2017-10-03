-- Dependencies
local Class = require("engine.Class")

-- Playable class
local Playable = Class("Playable")

-- Constructor
function Playable:Playable(time)
    self.state = "stopped"
    self.time = time or 0
end

-- Plays object
function Playable:play()
    self.state = "playing"
    return self
end

-- Replays object
function Playable:replay()
    return self:rewind():play()
end

-- Stops object
function Playable:stop()
    self.state = "stopped"
    self.time = 0
    return self
end

-- Pauses object
function Playable:pause()
    if self.state == "playing" then
        self.state = "paused"
    end
    return self
end

-- Resumes object
function Playable:resume()
    if self.state == "paused" then
        self.state = "playing"
    end
    return self
end

-- Rewinds object
function Playable:rewind()
    self.time = 0
    return self
end

-- Sets object time
function Playable:setTime(time)
    self.time = time
    return self
end

-- Returns object time
function Playable:getTime()
    return self.time
end

-- Alias for setTime
function Playable:seek(time)
    return self:setTime(time)
end

-- Alias for getTime
function Playable:tell()
    return self:getTime()
end

-- Checks whether is object stopped
function Playable:isStopped()
    return self.state == "stopped"
end

-- Checks whether is object playing
function Playable:isPlaying()
    return self.state == "playing"
end

-- Checks whether is object paused
function Playable:isPaused()
    return self.state == "paused"
end

-- Updates object
function Playable:update(delta)
    if self.state == "playing" then
        self.time = self.time + delta
        return true
    else
        return false
    end
end

return Playable
