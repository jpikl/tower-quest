-- Dependencies
local Class = require("engine.Class")

-- UI manager class
local UIManager = Class("UIManager")

-- Constructor
function UIManager:UIManager()
    self.widgets = {} -- List of widgets
end

-- Inserts widget to the UI
function UIManager:add(widget)
    table.insert(self.widgets, widget)
end

-- Tests if UI is active
function UIManager:isActive()
    for i, widget in ipairs(self.widgets) do
        if widget.visible then
            return true
        end
    end
    return false
end

-- Draws GUI
function UIManager:draw()
    for i, widget in ipairs(self.widgets) do
        widget:draw()
    end
end

-- Processes input press event
function UIManager:inputPressed(input)
    for i, widget in ipairs(self.widgets) do
        if widget:inputPressed(input) then
            return
        end
    end
end

return UIManager
