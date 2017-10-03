-- Dependencies
local String = require("engine.String")

-- Text module
local Text = {}

-- Returns text width
local function fontMetric(text)
    return love.graphics.getFont():getWidth(text)
end

-- Wraps text to array of lines
function Text.wrap(text, maxWidth, mode)
    return String.wrap(text, maxWidth, fontMetric, mode)
end

-- Prints text
function Text.print(text, x, y, maxWidth)
    local font = love.graphics.getFont()
    local lineHeight = font:getHeight() * font:getLineHeight()
    local lines = Text.wrap(text, maxWidth)
    for i = 1, #lines do
        love.graphics.print(lines[i], x, y + (i - 1) * lineHeight)
    end
end

-- Measure wrapped text size
function Text.measure(text, maxWidth, padding)
    local lines = Text.wrap(text, maxWidth)
    if #lines == 0 then
        return 0, 0
    end

    local font = love.graphics.getFont()
    local width = 0
    for i = 1, #lines do
        local lineWidth = font:getWidth(lines[i])
        if lineWidth > width then
            width = lineWidth
        end
    end

    local lineHeight = font:getHeight() * font:getLineHeight()
    local height = (#lines - 1) * lineHeight + font:getHeight()
    local border = padding and 2 * padding or 0
    return width + border, height + border
end

-- Converts cursor location to point coordinates
function Text.cursorToPoint(text, position, maxWidth)
    local limit = position
    local char = text:sub(limit + 1, limit + 1)
    while limit < #text and char ~= " " and char ~= "\n" do
        limit = limit + 1
        char = text:sub(limit + 1, limit + 1)
    end

    local lines = Text.wrap(text:sub(1, limit), maxWidth)
    if #lines == 0 then
        return 0, 0
    end

    local font = love.graphics.getFont()
    local lastLine = lines[#lines]
    local x = font:getWidth(lastLine:sub(1, #lastLine + position - limit))
    local y = (#lines - 1) * font:getHeight() * font:getLineHeight()
    return x, y
end

-- Converts point coordinates to cursor location
function Text.pointToCursor(text, x, y, maxWidth)
    local lines = Text.wrap(text, maxWidth, "keep-newlines")
    if #lines == 0 then
        return 0
    end

    local font = love.graphics.getFont()
    local lineHeight = font:getHeight() * font:getLineHeight()
    local position = 0
    x = x + font:getWidth("x") / 2

    for i = 1, #lines do
        local line = lines[i]
        local height = i * lineHeight
        if height > y then
            local width = 0
            for j = 1, #line do
                width = width + font:getWidth(line:sub(j, j))
                if width > x then
                    return position
                else
                    position = position + 1
                end
            end
            if i < #lines then
                return position - 1
            end
        else
            position = position + #line
        end
    end
    return position
end

return Text
