-- Dependencies
local Assets = require("engine.Assets")
local Object = require("game.objects.Object")
local Room   = require("game.Room")

-- Switch class
local Switch = Object:derive("Switch")

-- Variables
local sound = Assets.sounds.switch

-- Blending color for each group.
Switch.groupColors = {
    white = { 255, 255, 255 },
    red = { 188, 96, 96 },
    blue = { 122, 155, 200 }
}

-- Constructor
function Switch:Switch(x, y, group)
    self:Object(x, y, -1)  -- Superclass constructor
    self.group = group     -- Name of the group containing switch
    self.activated = false -- Is switch activated by some object on it?
    self.surface = true    -- Is surface object
end

-- Tests if object collide with another one
function Switch:collideWith(object)
    return false
end

-- Draws switch
function Switch:draw()
    -- Mix color of base image
    love.graphics.setColor(Switch.groupColors[self.group])

    if self.activated then
        self:drawSprite(24)
    else
        self:drawSprite(23)
    end

    -- Reset basic color
    love.graphics.setColor(255, 255, 255)
end

-- Updates switch
function Switch:update()
    if self.activated then
        if not self:isPressed() then
            self.activated = false
            Room.activatedSwitches[self.group] = Room.activatedSwitches[self.group] - 1
            sound:rewind()
            sound:play()
        end
    else
        if self:isPressed() then
            self.activated = true
            Room.activatedSwitches[self.group] = Room.activatedSwitches[self.group] + 1
            sound:rewind()
            sound:play()
        end
    end
end

-- Test if there is an object colliding with the switch
function Switch:isPressed()
    for obj in Room.getObjectsIterator(self) do
        if not obj.flying and obj:intersects(self, 1) then
            return true
        end
    end
end

return Switch
