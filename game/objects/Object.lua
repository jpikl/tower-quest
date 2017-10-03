-- Dependencies
local Assets = require("engine.Assets")
local Class  = require("engine.Class")

-- Object class
local Object = Class("Object")

-- Variables
local instancesCount = 0
local backgroundSpriteSheet = Assets.sprites.background

-- Common sprites
Object.sprites = Assets.sprites.objects

-- Constructor
function Object:Object(x, y, z, w, h)
    self.id = instancesCount -- Unique ID
    self.x = x               -- X coordinate
    self.y = y               -- Y coordinate
    self.z = z or 1          -- Z coordinate (rendering order)
    self.w = w or 16         -- Width
    self.h = h or 16         -- Height

    instancesCount = instancesCount + 1
end

-- Destroys object
function Object:destroy()
    self.destroyed = true
end

-- Updates object
function Object:update()
end

-- Returns number of a sprite which is drawn as background
function Object.getBackgroundSprite(classes)
    return backgroundSpriteSheet[5] -- Default background sprite
end

-- Draws object
function Object:draw()
end

-- Draws object with sprite
function Object:drawSprite(number)
    self.sprites[number]:draw(self.x, self.y)
end

-- Tests if object collide with another one
function Object:collideWith(object)
    return true
end

-- Returns object bounds
function Object:getBounds(border, dx, dy)
    local x1 = self.x + (dx or 0)
    local y1 = self.y + (dy or 0)
    local x2 = x1 + self.w
    local y2 = y1 + self.h

    if border then
        return x1 + border, y1 + border, x2 - border, y2 - border
    else
        return x1, y1, x2, y2
    end
end

-- Tests intersection with a rectangle area
function Object:intersectsArea(x1, y1, x2, y2, border)
    local sx1, sy1, sx2, sy2 = self:getBounds(border)
    return sx1 <= x2 and sx2 >= x1 and sy1 <= y2 and sy2 >= y1
end

-- Tests intersection with an object
function Object:intersects(object, border)
    local x1, y1, x2, y2 = object:getBounds(border)
    return self:intersectsArea(x1, y1, x2, y2, border)
end

-- Resolves drawing order of 2 objects
function Object:compare(obj)
    if self.z == obj.z then
        return self.id < obj.id -- The highest ID
    else
        return self.z < obj.z   -- The highest Z coordinate
    end
end

return Object
