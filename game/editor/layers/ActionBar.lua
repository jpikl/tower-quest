-- Dependencies
local Class    = require("engine.Class")
local Button   = require("game.editor.layers.Button")
local Renderer = require("game.editor.Renderer")

-- Action bar class
local ActionBar = Class("ActionBar")

-- Variables
local separator = {} -- Button separator

-- Constructor
function ActionBar:ActionBar()
    self.buttons = {} -- Array of buttons
    self.mapping = {} -- Mapping of ID to button
end

-- Adds a button to action bar
function ActionBar:addButton(data)
    local button = Button(data.image, data.tooltip)
    button.command = {
        redo = data.redo,
        undo = data.undo
    }
    self.mapping[data.id] = button
    table.insert(self.buttons, button)
end

-- Adds separator to action bar
function ActionBar:addSeparator()
    table.insert(self.buttons, separator)
end

-- Returns button (by position or ID)
function ActionBar:getButton(key)
    -- Key is an ID
    if type(key) == "string" then
        return self.mapping[key]
    end
    -- Key is array index
    local button = self.buttons[key]
    if button ~= separator then
        return button
    end
end

-- Draws action bar
function ActionBar:draw(x, y, activeButton)
    -- Draw background
    local width = 16 * #self.buttons
    Renderer.drawRect(x, y, width, 16, "fill1")
    Renderer.drawLine(x, y + 16, x + width, y + 16, "border1")

    -- Draw buttons
    for i, button in ipairs(self.buttons) do
        if button ~= separator then
            button:draw(x + 16 * (i - 1), y)
        end
    end
end

return ActionBar
