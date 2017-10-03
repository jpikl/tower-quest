-- Dependencies
local Playable = require("engine.Playable")

-- Repeater class
local Repeater = Playable:derive("Repeater")

-- Constructor
function Repeater:Repeater(period, callback)
    self:Playable()          -- Superclass constructor
    self.period = period     -- Repetition period
    self.callback = callback -- Callback function
end

-- Updates repeater
function Repeater:update(delta)
    if Playable.update(self, delta) and self.time > self.period then
        self.time = self.time % self.period
        self.callback()
    end
end

return Repeater
