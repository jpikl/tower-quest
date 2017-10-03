-- Dependencies
local Assets   = require("engine.Assets")
local Class    = require("engine.Class")
local Renderer = require("game.editor.Renderer")
local Button   = require("game.editor.layers.Button")

-- Action bar class
local ToolBar = Class("ToolBar")

-- Variables
local sprites = Assets.sprites.editor -- Editor sprites

-- Constructor
function ToolBar:ToolBar(size)
    self.size = size  -- Toolbar size
    self.buttons = {} -- Array of buttons
    self.topIndex = 1 -- Index of button on the top of the toolbar

    -- Scroll buttons
    self.scrollUpButton = Button(sprites[21], "Scroll up")
    self.scrollUpButton.command = {
        redo = function() self:scrollUp() end
    }
    self.scrollDownButton = Button(sprites[22], "Scroll down")
    self.scrollDownButton.command = {
        redo = function() self:scrollDown() end
    }
    self:updateScrollButtons()
end

-- Adds a button to action bar
function ToolBar:addButton(data)
    local button = Button(data.image, data.tooltip)
    button.command = {
        redo = function()
            if self.activatedButton then
                self.activatedButton.activated = false
            end
            self.activatedButton = button
            self.activatedButton.activated = true
            self.selectedTool = data.character
        end
    }
    table.insert(self.buttons, button)
end

-- Returns button
function ToolBar:getButton(position)
    if position == 1 then
        return self.scrollUpButton
    elseif position == self.size then
        return self.scrollDownButton
    else
        return self.buttons[self.topIndex + position - 2]
    end
end

-- Scrolls toolbar bar up
function ToolBar:scrollUp()
    if self.scrollUpButton.enabled then
        self.topIndex = self.topIndex - 1
    end
    self:updateScrollButtons()
end

-- Scrolls toolbar bar down
function ToolBar:scrollDown()
    if self.scrollDownButton.enabled then
        self.topIndex = self.topIndex + 1
    end
    self:updateScrollButtons()
end

-- Updates scroll buttons
function ToolBar:updateScrollButtons()
    local bottomIndex = self.topIndex + self.size - 3
    self.scrollUpButton.enabled = self.topIndex > 1
    self.scrollDownButton.enabled = bottomIndex < #self.buttons
end

-- Draws tool bar
function ToolBar:draw(x, y, activeButton)
    -- Draw background
    local height = 16 * self.size
    Renderer.drawRect(x, y, 16, height, "fill1")
    Renderer.drawLine(x, y, x, y + height, "border1")

    -- Draw scroll buttons
    self.scrollUpButton:draw(x, y)
    self.scrollDownButton:draw(x, y + height - 16)

    -- Draw tool buttons
    for i = 1, self.size - 2 do
        local button = self.buttons[self.topIndex + i - 1]
        if button then
            button:draw(x, y + 16 * i)
        end
    end
end

return ToolBar
