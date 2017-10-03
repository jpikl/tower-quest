-- Dependencies
local Class = require("engine.Class")

-- Layer class
local Layer = Class("Layer")

-- Constructor
function Layer:Layer(width, height)
    self.width = width   -- Layer width
    self.height = height -- Layer height
end

-- Draws layer
function Layer:draw()
   if self.nextLayer then
      self.nextLayer:draw()
   end
end

-- Processes cursor press event
function Layer:cursorPressed(x, y)
    if self.nextLayer then
        self.nextLayer:cursorPressed(x, y)
    end
end

-- Processes cursor release event
function Layer:cursorReleased(x, y)
    if self.nextLayer then
        self.nextLayer:cursorReleased(x, y)
    end
end

-- Processes cursor move event
function Layer:cursorMoved(oldX, oldY, newX, newY)
    if self.nextLayer then
        self.nextLayer:cursorMoved(oldX, oldY, newX, newY)
    end
end

return Layer
