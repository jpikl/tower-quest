-- Dependencies
local Math     = require("engine.Math")
local Video    = require("engine.Video")
local Renderer = require("game.editor.Renderer")
local Widget   = require("game.editor.dialog.Widget")

-- Scroller class
local Scroller = Widget:derive("Scroller")

-- Constructor
function Scroller:Scroller(target, x, y, width, height)
    self:Widget(x, y, width, height, true) -- Superclass constructor
    self.target = target                   -- Target part
end

-- Draws scroller
function Scroller:draw()
    -- Draw background
    local x, y, width, height = self:getRectangle()
    local selected = self.selected
    Renderer.drawFrame(x, y, width, height, "fill0", "border2", selected)

    -- Draw bar
    local portion = self.target:getScrollPortion()
    local progress = self.target:getScrollProgress()
    local barHeight = height * portion
    local barY = y + (height - barHeight) * progress
    Renderer.drawFrame(x, barY, width, barHeight, "fill2", "border2", selected)
end

-- Processes input press event
function Scroller:inputPressed(input)
    if input:is("confirm") then -- Must be called before 'click'
        self:deactivate()
    elseif input:is("click") then
        local mouseX, mouseY = Video.getMousePosition()
        self.dragged = true
        self.dragY = mouseY
        self.dragProgress = (mouseY - self.y) / self.height
        self.target:setScrollProgress(self.dragProgress)
    elseif input:is("up", "scroll-up") then
        local portion = self.target:getScrollPortion()
        local progress = self.target:getScrollProgress()
        self.target:setScrollProgress(math.max(0, progress - portion))
    elseif input:is("down", "scroll-down") then
        local portion = self.target:getScrollPortion()
        local progress = self.target:getScrollProgress()
        self.target:setScrollProgress(math.min(1, progress + portion))
    end
end

-- Processes input release event
function Scroller:inputReleased(input)
    if not input:is("confirm") and input:is("click") then
        self.dragged = false
    end
end

-- Processes mouse move event
function Scroller:mouseMoved(oldX, oldY, newX, newY)
    if self.dragged then
        newY = Math.fit(newY, self.y, self.y + self.height)
        local portion = self.target:getScrollPortion()
        local delta = (newY - self.dragY) / (self.height * (1 - portion))
        self.target:setScrollProgress(Math.fit(self.dragProgress + delta, 0, 1))
    end
end

return Scroller
