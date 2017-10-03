-- Dependencies
local Assets = require("engine.Assets")
local Table  = require("engine.Table")
local Sink   = require("game.objects.Sink")

-- Abyss class
local Abyss = Sink:derive("Abyss")

-- Variables
local sound = Assets.sounds.fall
local duration = 1

-- Constructor
function Abyss:Abyss(x, y)
    self:Sink(x, y)          -- Superclass constructor
    self.fallingObjects = {} -- Objects falling into the abyss
end

-- Throws an object into the abyss
function Abyss:sinkObject(object)
    table.insert(self.fallingObjects, {
        object = object,
        time = duration
    })
    sound:stop()
    sound:play()
end

-- Returns number of a sprite which is drawn as background
function Abyss.getBackgroundSprite(classes)
    if not classes.tc:is("Abyss") then
        return Abyss.sprites[27]
    end
end

-- Draws abyss
function Abyss:draw()
    -- Draw falling objects
    for i, item in ipairs(self.fallingObjects) do
        local obj = item.object
        local inverseProgress = item.time / duration
        if inverseProgress <= 0.0 then inverseProgress = 0.001 end
        local progress = 1.0 - inverseProgress

        love.graphics.setColor(255, 255, 255, 255 * inverseProgress)
        love.graphics.push()
        love.graphics.translate(progress * (obj.x + obj.w / 2), progress * (obj.y + obj.h / 2))
        love.graphics.scale(inverseProgress, inverseProgress)
        obj:draw()
        love.graphics.pop()
    end
    love.graphics.setColor(255, 255, 255)
end

-- Updates abyss
function Abyss:update(delta)
    Sink.update(self, delta)

    -- Update falling objects
    Table.filter(self.fallingObjects, function(i, obj)
        obj.time = obj.time - delta
        return obj.time <= 0
    end)
end

return Abyss
