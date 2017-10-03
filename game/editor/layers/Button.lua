-- Dependencies
local Assets   = require("engine.Assets")
local Class    = require("engine.Class")
local Math     = require("engine.Math")
local Text     = require("engine.Text")
local Renderer = require("game.editor.Renderer")
local Editor   = require("game.states.Editor")

-- Button class
local Button = Class("Button")

-- Variables
local sprites = Assets.sprites.editor -- Editor sprites
local sound = Assets.sounds.editor     -- Click button sound
local params = {}                    -- Tooltip drawing parameters

-- Sets tooltip drawing parameters
function Button.setTooltipDrawingParameters(drawingParams)
    params = drawingParams
end

-- Constructor
function Button:Button(image, tooltip)
    self.image = image     -- Button image
    self.tooltip = tooltip -- Tooltip text
    self.enabled = true    -- Can be button used?
end

-- Presses button
function Button:press()
    if self.enabled then
        self.pressed = true
    end
end

-- Releases button
function Button:release()
    if self.pressed then
        self.pressed = false
        local command = self.command
        if command then
            if command.undo and command.redo then
                Editor.getCommandStack():execute(command)
            elseif command.redo then
                command:redo()
            end
        end
        sound:play()
    end
end

-- Draws button
function Button:draw(x, y)
    if self.pressed then
        y = y + 1
    end
    if not self.enabled then
        love.graphics.setColor(255, 255, 255, 32)
    end
    self.image:draw(x, y)
    if self.checked then
        sprites[16]:draw(x, y)
    end
    love.graphics.setColor(255, 255, 255)
    if self.activated then
        sprites[24]:draw(x, y)
    end
    if self.selected and Editor.areTooltipsEnabled() then
        self:drawTooltip(x, y)
    end
end

-- Draws button tooltip
function Button:drawTooltip(x, y)
    local tooltip = self.tooltip
    local width, height = Text.measure(tooltip, params.maxWidth, params.padding)
    local left = params.left + params.margin
    local right = params.right - width - params.margin
    local top = params.top + params.margin
    local bottom = params.bottom - height - params.margin
    x = Math.fit(x + 8 -  width / 2, left,  right)
    y = Math.fit(y + 8  - height / 2, top, bottom)
    Renderer.drawFrame(x, y, width, height, "fill1", "border1")
    Text.print(tooltip, x + params.padding, y + params.padding, params.maxWidth)
end

return Button
