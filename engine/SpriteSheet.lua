-- Dependencies
local Class  = require("engine.Class")
local Sprite = require("engine.Sprite")

-- Sprite sheet class
local SpriteSheet = Class("SpriteSheet")

-- Constructor
function SpriteSheet:SpriteSheet(image, spriteWidth, spriteHeight, ...)
    -- Load image if necessary
    if type(image) == "string" then
        self.image = love.graphics.newImage(image)
    else
        self.image = image
    end
    -- Generate sprites if it was specified
    if spriteWidth and spriteHeight then
        self:generateSprites(spriteWidth, spriteHeight, ...)
    end
end

-- Adds sprite to the sprite sheet
function SpriteSheet:addSprite(...)
    local sprite = Sprite(self.image, ...)
    table.insert(self, sprite)
    return sprite
end

-- Generates all sprites automatically
function SpriteSheet:generateSprites(width, height, border, space)
    border = border or 0
    space = space or 0
    local columns = (self.image:getWidth() - 2 * border + space) / (width + space)
    local rows = (self.image:getHeight() - 2 * border + space) / (height + space)
    for row = 0, rows - 1 do
        for column = 0, columns - 1 do
            local x = border + column * (width + space)
            local y = border + row * (height + space)
            self:addSprite(x, y, width, height)
        end
    end
    return self
end

-- Creates new sprite batch for the sprite sheet
function SpriteSheet:createBatch(size)
    return love.graphics.newSpriteBatch(self.image, size)
end

return SpriteSheet
