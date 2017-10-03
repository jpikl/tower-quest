-- Dependencies
local Class  = require("engine.Class")
local String = require("engine.String")

-- Cheater class
local Cheater = Class("Cheater")

-- Constructor
function Cheater:Cheater(inputHistoryLimit)
    self.cheats = {}
    self.history = {}
    self.startPos = 1
    self.endPos = 1
    self.limit = inputHistoryLimit or 50
end

-- Adds new cheat
function Cheater:addCheat(sequence, callback)
    if type(sequence) == "string" then
        sequence = String.split(sequence)
    end

    table.insert(self.cheats, {
        sequence = sequence,
        callback = callback
    })
end

-- Adds last used input
function Cheater:inputUsed(input)
    self:addInput(input)
    self:inputChanged()
end

-- Adds input to history
function Cheater:addInput(input)
    self.history[self.endPos] = input
    self.endPos = self.endPos + 1

    if self.endPos - self.startPos > self.limit then
        self.history[self.startPos] = nil
        self.startPos = self.startPos + 1
    end
end

-- Checks if some cheat was activated
function Cheater:inputChanged()
    for i, cheat in ipairs(self.cheats) do
        local sequence = cheat.sequence
        local historyPos = self.endPos - 1
        local sequencePos = #sequence

        while sequencePos > 0 and self.history[historyPos] == sequence[sequencePos] do
            historyPos = historyPos - 1
            sequencePos = sequencePos - 1
        end

        if sequencePos == 0 then
            cheat.callback(sequence)
        end
    end
end

return Cheater
