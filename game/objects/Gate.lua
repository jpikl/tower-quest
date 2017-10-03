-- Dependencies
local Assets = require("engine.Assets")
local Object = require("game.objects.Object")
local Switch = require("game.objects.Switch")
local Room   = require("game.Room")

-- Gate class
local Gate = Object:derive("Gate")

-- Variables
local sound = Assets.sounds.gate

-- Constructor
function Gate:Gate(x, y, group)
    self:Object(x, y, -1)  -- Superclass constructor
    self.group = group     -- Name of the group containing gate
    self.opened = false    -- Is gate opened?
    self.surface = false   -- Is surface object (same state as opened)
end

-- Tests if object collide with another one
function Gate:collideWith(object)
    return not (self.opened or object:is("Dynamite"))
end

-- Draws gate
function Gate:draw()
    -- Mix color of base image
    love.graphics.setColor(Switch.groupColors[self.group])

    if self.opened then
        self:drawSprite(22)
    else
        self:drawSprite(21)
    end

    -- Reset basic color
    love.graphics.setColor(255, 255, 255)
end

-- Updates gate
function Gate:update()
    if self.opened then
        if Room.activatedSwitches[self.group] == 0 and not self:isPressed() then
            self.opened = false
            self.surface = false
            sound:play()
        end
    else
        if Room.activatedSwitches[self.group] > 0 or self:isPressed() then
            self.opened = true
            self.surface = true
            sound:play()
        end
    end
end

-- Test if there is an object colliding with the gate
function Gate:isPressed()
    for obj in Room.getObjectsIterator(self) do
        -- Object must have weight. Dynamite can't hold opened gate
        if obj.weight and not obj:is("Dynamite") and obj:intersects(self, 1) then
            return true
        end
    end
end

return Gate
