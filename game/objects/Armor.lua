-- Dependencies
local Enemy  = require("game.objects.Enemy")
local Player = require("game.objects.Player")
local Sword  = require("game.objects.Sword")
local Room   = require("game.Room")

-- Armor class
local Armor = Enemy:derive("Armor")

-- Constructor
function Armor:Armor(x, y)
    self:Enemy(x, y, false) -- Superclass constructor
    self.swordTimeout = 0   -- Timeout between sword shots
end

-- Checks for collisions
function Armor:collideWith(object)
    -- No collisions with sword created by this armor
    if object.creator == self then
        return false
    else
        return Enemy.collideWith(self, object)
    end
end

-- Draws armor
function Armor:draw()
    self.sprites[9]:draw(self.x, self.y - 2)
end

-- Updates armor
function Armor:update(delta)
    -- Destroy armor when key is obtained
    if Room.keyObtained then
        self:destroy()
    -- Shot sword when player in sight
    elseif self.swordTimeout <= 0 and Player.instance.alive then
        local sx1, sy1, sx2, sy2 = self:getBounds()
        local px1, py1, px2, py2 = Player.instance:getBounds()
        local dir = nil

        -- Calculate shot direction
        if px1 < sx2 and px2 > sx1 then
            dir = py1 < sy1 and "up" or "down"
        elseif py1 < sy2 and py2 > sy1 then
            dir = px1 > sx1 and "right" or "left"
        end

        -- Shot sword if possible
        if dir then
            local x = self.x + 8
            local y = self.y + 8
            local sword = Sword(x, y, dir, self)
            if not Room.isCollision(sword) then
                Room.addObject(sword)
            end
            self.swordTimeout = 0.25
        end
    -- Decrement timeout
    elseif self.swordTimeout > 0 then
        self.swordTimeout = self.swordTimeout - delta
    end
end

return Armor
