-- Dependencies
local Assets   = require("engine.Assets")
local Text     = require("engine.Text")
local Renderer = require("game.editor.Renderer")
local Widget   = require("game.editor.dialog.Widget")

-- Button class
local Button = Widget:derive("Button")

-- Variables
local sound = Assets.sounds.editor

-- Constructor
function Button:Button(content, x, y, width, height, callback)
    self:Widget(x, y, width, height, true) -- Superclass constructor
    self.content = content                 -- Button content (text or image)
    self.callback = callback               -- Button callback
end

-- Draws button
function Button:draw()
    -- Draw background
    local x, y, width, height = self:getRectangle()
    if self.active then y = y + 1 end
    Renderer.drawFrame(x, y, width, height, "fill2", "border2", self.selected)

    -- Content parameters
    local content = self.content
    local contentWidth, contentHeight, contentRenderer
    if type(content) == "string" then
        contentWidth, contentHeight = Text.measure(content)
        contentRenderer = Text.print
    else
        contentWidth = content.width
        contentHeight = content.height
        contentRenderer = content.draw
    end
    local contentX = x + (width - contentWidth) / 2
    local contentY = y + (height - contentHeight) / 2

    -- Draw content
    Renderer.setDefaultColor()
    contentRenderer(content, contentX, contentY)
end

-- Processes input release event
function Button:inputReleased(input)
    if self.active and input:is("confirm", "click") then
        sound:play()
        self:callback()
        self:deactivate()
    end
end

return Button
