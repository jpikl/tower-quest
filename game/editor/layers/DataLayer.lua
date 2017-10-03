-- Dependencies
local Assets          = require("engine.Assets")
local EditDataCommand = require("game.editor.commands.EditDataCommand")
local Layer           = require("game.editor.layers.Layer")
local Editor          = require("game.states.Editor")
local Mapping         = require("game.Mapping")

-- Data layer class
local DataLayer = Layer:derive("DataLayer")

-- Variables
local sprites = Assets.sprites.background -- Background sprites

-- Constructor
function DataLayer:DataLayer(width, height)
    self:Layer(width, height)                     -- Superclass constructor
    self.xOffset = 0                              -- Camera X offset
    self.yOffset = 0                              -- Camera Y offset
    self.batch = sprites:createBatch(1000)        -- Batch for drawing background

    -- Refresh background batch when level changes
    Editor.getCommandStack():addListener(function()
        self:redrawBatch()
    end)
end

-- Redraw background batch
function DataLayer:redrawBatch()
    local batch = self.batch
    local level = Editor.getLevel()
    local left, right, top, bottom = level:getBorders()

    batch:clear()

    for i = top, bottom do
        for j = left, right do
            local sprite = level:getBackgroundSprite(j, i)
            if sprite then
                local x = (j - 1) * 16
                local y = (i - 1) * 16
                sprite:addToBatch(batch, x, y)
            end
        end
    end
end

-- Draws layer
function DataLayer:draw()
    -- Draw background
    local baseX = -16 * self.xOffset
    local baseY = -16 * self.yOffset
    love.graphics.draw(self.batch, baseX, baseY)

    -- Draw foreground
    local level = Editor.getLevel()
    local left, right, top, bottom = level:getBorders()
    for i = top, bottom do
        for j = left, right do
            local value = level:getData(j, i)
            local image = Mapping.getImage(value)
            if image then
                local x = baseX + (j - 1) * 16
                local y = baseY + (i - 1) * 16
                image:draw(x, y)
            end
        end
    end
end

-- Set level data using the selected tool
function DataLayer:useSelectedTool(x, y)
    local value = Editor.getSelectedTool()
    if value then
        local level = Editor.getLevel()
        local x = x + self.xOffset
        local y = y + self.yOffset
        local command = EditDataCommand(level, x, y, value)
        Editor.getCommandStack():execute(command)
    end
end

-- Processes cursor press event
function DataLayer:cursorPressed(x, y)
    self.drawing = true
    self:useSelectedTool(x, y)
end

-- Processes cursor move event
function DataLayer:cursorMoved(oldX, oldY, newX, newY)
    if self.drawing then
        self:useSelectedTool(newX, newY)
    end
end

-- Processes cursor release event
function DataLayer:cursorReleased(x, y)
    self.drawing = false
end

return DataLayer
