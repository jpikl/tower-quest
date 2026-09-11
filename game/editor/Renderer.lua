-- Renderer module
local Renderer = {}

-- Base colors
local baseColors   = {}
baseColors.fill0   = { 0, 0, 0 }
baseColors.fill1   = { 0.25, 0.25, 0.25 }
baseColors.fill2   = { 0.38, 0.38, 0.38 }
baseColors.border1 = { 0.5, 0.5, 0.5 }
baseColors.border2 = { 0.63, 0.63, 0.63 }
baseColors.select  = { 0.5, 0.5, 0.5 }

-- Highlighted colors
local hlColors   = {}
hlColors.fill0   = { 0.13, 0.13, 0.13 }
hlColors.fill1   = { 0.5, 0.5, 0.5 }
hlColors.fill2   = { 0.63, 0.63, 0.63 }
hlColors.border2 = { 0.88, 0.88, 0.88 }

-- Returns target color
function Renderer.getColor(name, highlighted)
    if highlighted then
        return hlColors[name]
    else
        return baseColors[name]
    end
end

-- Uses target color for drawing
function Renderer.setColor(name, highlighted)
    love.graphics.setColor(Renderer.getColor(name, highlighted))
end

-- Uses default drawing color
function Renderer.setDefaultColor()
    love.graphics.setColor(1, 1, 1)
end

-- Draws line
function Renderer.drawLine(x1, y1, x2, y2, color, highlighted)
    Renderer.setColor(color, highlighted)
    love.graphics.line(x1, y1, x2, y2)
    Renderer.setDefaultColor()
end

-- Draws filled rectangle
function Renderer.drawRect(x, y, width, height, color, highlighted)
    Renderer.setColor(color, highlighted)
    love.graphics.rectangle("fill", x, y, width, height)
    Renderer.setDefaultColor()
end

-- Draws filled rectangle with border
function Renderer.drawFrame(x, y, width, height, fillColor, borderColor, highlighted)
    Renderer.setColor(fillColor, highlighted)
    love.graphics.rectangle("fill", x, y, width, height)
    Renderer.setColor(borderColor, highlighted)
    love.graphics.rectangle("line", x, y, width, height)
    Renderer.setDefaultColor()
end

-- Limits drawing to the specified area
function Renderer.limitDrawing(x, y, width, height, drawing)
    local function stencilFunction()
        love.graphics.rectangle("fill", x, y, width, height)
    end
    love.graphics.stencil(stencilFunction, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    drawing()
    love.graphics.setStencilTest()
end

return Renderer
