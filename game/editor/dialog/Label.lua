-- Dependencies
local Text   = require("engine.Text")
local Widget = require("game.editor.dialog.Widget")

-- Label class
local Label = Widget:derive("Label")

-- Constructor
function Label:Label(text, x, y, width)
    self:Widget(x, y, width, nil, false) -- Superclass constructor
    self.text = text                     -- Displayed text
end

-- Draws label
function Label:draw()
    Text.print(self.text, self.x, self.y, self.width)
end

return Label
