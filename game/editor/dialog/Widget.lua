-- Dependencies
local Class = require("engine.Class")

-- Widget class
local Widget = Class("Widget")

-- Constructor
function Widget:Widget(x, y, width, height, selectable)
    self.x = x                    -- X coordinate
    self.y = y                    -- Y coordinate
    self.width = width            -- Widget width
    self.height = height          -- Widget height
    self.selectable = selectable  -- Can be widget selected?
end

-- Activates widget
function Widget:activate()
    self.active = true
end

-- Deactivates widget
function Widget:deactivate()
    self.active = false
end

-- Returns widget rectangle
function Widget:getRectangle(border)
    border = border or 0
    local x = self.x + border
    local y = self.y + border
    local width = (self.width or 0) - 2 * border
    local height = (self.height or 0) - 2 * border
    return x, y, width, height
end

-- Returns widget bounds
function Widget:getBounds(border)
    local x, y, width, height = self:getRectangle(border)
    return x, x + width, y, y + height
end

-- Checks if widget contains point
function Widget:containsPoint(x, y)
    local left, right, top, bottom = self:getBounds()
    return x >= left and x <= right and y >= top and y <= bottom
end

-- Processes input press event
function Widget:inputPressed(input)
end

-- Processes input release event
function Widget:inputReleased()
end

return Widget
