-- Dependencies
local Class = require("engine.Class")

-- Sprite class
local Sprite = Class("Sprite")

-- Constructor
function Sprite:Sprite(image, x, y, width, height)
    -- Load image if necessary
    if type(image) == "string" then
        image = love.graphics.newImage(image)
    end

    -- Compute default values
    x = x or 0
    y = y or 0
    width = width or (image:getWidth() - x)
    height = height or (image:getHeight() - y)

    -- Initialization
    self.quad = love.graphics.newQuad(x, y, width, height, image:getWidth(), image:getHeight())
    self.image = image
    self.x = 0
    self.y = 0
    self.width = width
    self.height = height
end

-- Returns sprite width
function Sprite:getWidth()
    return self.width
end

-- Returns sprite height
function Sprite:getHeight()
    return self.height
end

-- Returns sprite size
function Sprite:getSize()
    return self.width, self.height
end

-- Translates sprite rendering coordinates
function Sprite:move(dx, dy)
    self.x = self.x + (dx or 0)
    self.y = self.y + (dy or 0)
    return self
end

-- Flips sprite vertically
function Sprite:flipHorizontally()
    self.flipX = not self.flipX
    return self
end

-- Flips sprite horizontally
function Sprite:flipVertically()
    self.flipY = not self.flipY
    return self
end

-- Blends sprite with a color
function Sprite:blend(r, g, b, a)
    self.color = type(r) == "table" and r or { r, g, b, a }
    return self
end

-- Draws sprite
function Sprite:draw(x, y, r, sx, sy, ...)
    x = self.x + (x or 0)
    y = self.y + (y or 0)
    sx = sx or 1
    sy = sy or sx or 1

    if self.flipX then
        x = x + self.width * sx
        sx = -sx
    end
    if self.flipY then
        y = y + self.height * sy
        sy = -sy
    end

    if self.color then
        love.graphics.setColor(self.color)
        love.graphics.draw(self.image, self.quad, x, y, r, sx, sy, ...)
        love.graphics.setColor(255, 255, 255)
    else
        love.graphics.draw(self.image, self.quad, x, y, r, sx, sy, ...)
    end
end

-- Adds sprite to sprite batch
function Sprite:addToBatch(batch, ...)
    batch:add(self.quad, ...)
end

return Sprite
