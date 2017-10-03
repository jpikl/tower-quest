-- Dependencies
local Math     = require("engine.Math")
local Text     = require("engine.Text")
local Video    = require("engine.Video")
local Widget   = require("game.editor.dialog.Widget")
local Renderer = require("game.editor.Renderer")

-- File browser class
local FileBrowser = Widget:derive("FileBrowser")

-- Constructor
function FileBrowser:FileBrowser(directory, filter, x, y, width, height, callback)
    self:Widget(x, y, width, height, true) -- Superclass constructor
    self.callback = callback               -- Item selection callback
    self.items = {}                        -- List of files in directory
    self.selection = 1                     -- Selected item
    self.top = 1                           -- Item on the top of the list

    -- Read files in directory
    for i, file in ipairs(love.filesystem.getDirectoryItems(directory)) do
        local match = file:match(filter)
        if match then
            table.insert(self.items, match)
        end
    end

    -- Parameters
    self.itemHeight = love.graphics.getFont():getHeight() + 3
    self.size = math.floor(height / self.itemHeight) -- Visible items count
end

-- Activates file browser
function FileBrowser:activate()
    Widget.activate(self)
    self:selectItem(Math.fit(self.selection, self.top, self.top + self.size - 1))
end

-- Selects item
function FileBrowser:selectItem(selection)
    self.selection = Math.fit(selection, 1, #self.items)
    self.callback(self.items[self.selection])
    self.top = Math.fit(self.top, self.selection - self.size + 1, self.selection)
end

-- Returns portion of visible items
function FileBrowser:getScrollPortion()
    if #self.items > self.size then
        return (self.height - 4) / (#self.items * self.itemHeight)
    else
        return 1
    end
end

-- Returns scrolling progress
function FileBrowser:getScrollProgress()
    if #self.items > self.size then
        return (self.top - 1) / (#self.items - self.size)
    else
        return 0
    end
end

-- Sets scrolling progress
function FileBrowser:setScrollProgress(progress)
    if #self.items > self.size then
        self.top = math.floor((#self.items - self.size) * progress) + 1
    end
end

-- Scrolls items up
function FileBrowser:scrollUp()
    self.top = math.max(self.top - 1, 1)
end

-- Scrolls items down
function FileBrowser:scrollDown()
    if #self.items > self.size then
        self.top = math.min(self.top + 1, #self.items - self.size + 1)
    end
end

-- Draws file browser
function FileBrowser:draw()
    -- Draw background
    local x, y, width, height = self:getRectangle()
    Renderer.drawFrame(x, y, width, height, "fill0", "border2", self.selected)

    -- Skip drawing of empty list
    if #self.items == 0 then
        return
    end

    -- Draw items
    local innerX, innerY, innerWidth, innerHeight = self:getRectangle(2)
    local itemHeight = self.itemHeight
    Renderer.limitDrawing(innerX, innerY, innerWidth, innerHeight, function()
        for i = self.top, math.min(#self.items, self.top + self.size + 1) do
            local itemY = innerY + (i - self.top) * self.itemHeight
            if i == self.selection then
                Renderer.drawRect(innerX, itemY, innerWidth, itemHeight, "select")
            end
            Text.print(self.items[i], innerX + 2, itemY + 2)
        end
    end)
end

-- Processes input press event
function FileBrowser:inputPressed(input)
    if input:is("confirm") then -- Must be tested before 'click'
        self:deactivate()
    elseif input:is("click") then
        local mouseX, mouseY = Video.getMousePosition()
        local offset = math.floor((mouseY - self.y - 2) / self.itemHeight)
        self:selectItem(self.top + offset)
    elseif input:is("up") then
        self:selectItem(self.selection - 1)
    elseif input:is("down") then
        self:selectItem(self.selection + 1)
    elseif input:is("scroll-up") then
        self:scrollUp()
    elseif input:is("scroll-down") then
        self:scrollDown()
    end
end

return FileBrowser
