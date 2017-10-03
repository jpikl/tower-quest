-- Dependencies
local Math      = require("engine.Math")
local Text      = require("engine.Text")
local TextInput = require("engine.TextInput")
local Video     = require("engine.Video")
local Widget    = require("game.editor.dialog.Widget")
local Renderer  = require("game.editor.Renderer")

-- Input class
local Input = Widget:derive("Input")

-- Returns current font line height
local function getLineHeight()
    local font = love.graphics.getFont()
    return font:getHeight() * font:getLineHeight()
end

-- Constructor
function Input:Input(type, text, x, y, width, height, padding)
    self:Widget(x, y, width, height, true) -- Superclass constructor
    self.type = type or "single"           -- Input type (single/multi)
    self.text = text or ""                 -- Initial text input
    self.position = 0                      -- Cursor position
    self.padding = padding                 -- Text padding
    self.scrollX = -1                      -- Horizontal scroll position
    self.scrollY = 0                       -- Vertical scroll position
end

-- Returns maximal text width
function Input:getMaxTextWidth()
    if self.type == "multi" then
        return self.width - 2 * self.padding
    end
end

-- Returns inner rectangle
function Input:getInnerRectangle()
    return self:getRectangle(self.padding)
end

-- Returns cursor rectangle
function Input:getCursorRectangle()
    local x, y = Text.cursorToPoint(self.text, self.position, self:getMaxTextWidth())
    return x - 1, y, 1, love.graphics.getFont():getHeight()
end

-- Test if cursor should be displayed
function Input:isCursorVisible()
    return self.active
       and TextInput.isEnabled()
       and math.floor(4 * love.timer.getTime()) % 2 == 0
end

-- Returns portion of visible text
function Input:getScrollPortion()
    local innerX, innerY, innerWidth, innerHeight = self:getInnerRectangle()
    local textWidth, textHeight = Text.measure(self.text, innerWidth)
    return math.min(1, innerHeight / textHeight)
end

-- Returns scrolling progress
function Input:getScrollProgress()
    local innerX, innerY, innerWidth, innerHeight = self:getInnerRectangle()
    local textWidth, textHeight = Text.measure(self.text, innerWidth)
    return math.min(1, self.scrollY / (textHeight - innerHeight))
end

-- Sets scrolling progress
function Input:setScrollProgress(progress)
    local innerX, innerY, innerWidth, innerHeight = self:getInnerRectangle()
    local textWidth, textHeight = Text.measure(self.text, innerWidth)
    self.scrollY = (textHeight - innerHeight) * progress
end

-- Scrolls text up
function Input:scrollUp()
    self.scrollY = math.max(0, self.scrollY - getLineHeight())
end

-- Scrolls text down
function Input:scrollDown()
    local textWidth, textHeight = Text.measure(self.text, self:getMaxTextWidth())
    local maxScrollY = math.max(0, textHeight - self.height + 2 * self.padding)
    self.scrollY = math.min(maxScrollY, self.scrollY + getLineHeight())
end

-- Activates input
function Input:activate()
    Widget.activate(self)
    TextInput.start {
        mode = self.type,
        text = self.text,
        position = self.position,
        cursorMoved = function(text, position)
            self.text = text -- It needs to be updated too
            self.position = position
            local innerX, innerY, innerWidth, innerHeight = self:getInnerRectangle()
            local cursorX, cursorY, cursorWidth, cursorHeight = self:getCursorRectangle()
            local minScrollX = cursorX + cursorWidth - innerWidth
            local minScrollY = cursorY + cursorHeight- innerHeight - 1
            self.scrollX = Math.fit(self.scrollX, minScrollX, cursorX)
            self.scrollY = Math.fit(self.scrollY, minScrollY, cursorY)
        end,
        moveUp = function(text, position)
            local maxTextWidth = self:getMaxTextWidth()
            local x, y = Text.cursorToPoint(text, position, maxTextWidth)
            y = math.max(0, y - getLineHeight())
            return Text.pointToCursor(text, x, y, maxTextWidth)
        end,
        moveDown = function(text, position)
            local maxTextWidth = self:getMaxTextWidth()
            local x, y = Text.cursorToPoint(text, position, maxTextWidth)
            local textWidth, textHeight = Text.measure(text, maxTextWidth)
            local maxY = math.max(0, textHeight)
            y = math.min(maxY, y + getLineHeight())
            return Text.pointToCursor(text, x, y, maxTextWidth)
        end,
        textEdited = function(text, position)
            self.text = text
        end,
        editingFinished = function(text, position)
            Widget.deactivate(self)
        end
    }
end

-- Deactivates input
function Input:deactivate()
    TextInput.stop()
end

-- Draws input
function Input:draw()
    -- Draw background
    local x, y, width, height = self:getRectangle()
    Renderer.drawFrame(x, y, width, height, "fill0", "border2", self.selected)

    -- Draw content
    local innerX, innerY, innerWidth, innerHeight = self:getInnerRectangle()
    Renderer.limitDrawing(innerX, innerY, innerWidth, innerHeight, function()
        -- Draw text
        local textX = innerX - self.scrollX
        local textY = innerY - self.scrollY
        Text.print(self.text, textX, textY, self:getMaxTextWidth())

        -- Draw blinking cursor
        if self:isCursorVisible() then
            local cursorX, cursorY, cursorWidth, cursorHeight = self:getCursorRectangle()
            cursorX = innerX - self.scrollX + cursorX
            cursorY = innerY - self.scrollY + cursorY
            Renderer.drawRect(cursorX, cursorY, cursorWidth, cursorHeight, "border2")
        end
    end)
end

-- Processes input press event
function Input:inputPressed(input)
    if input:is("confirm") then -- Must be tested before 'click'
        self:deactivate()
    elseif input:is("left") then
        TextInput.moveLeft()
    elseif input:is("right") then
        TextInput.moveRight()
    elseif input:is("up") then
        TextInput.moveUp()
    elseif input:is("down") then
        TextInput.moveDown()
    elseif input:is("click") then
        local mouseX, mouseY = Video.getMousePosition()
        local x = mouseX - self.x - self.padding + self.scrollX
        local y = mouseY - self.y - self.padding + self.scrollY
        local position = Text.pointToCursor(self.text, x, y, self:getMaxTextWidth())
        TextInput.setPosition(position)
    elseif self.type == "multi" then
        if input:is("scroll-up") then
            self:scrollUp()
        elseif input:is("scroll-down") then
            self:scrollDown()
        end
    end
end

return Input
