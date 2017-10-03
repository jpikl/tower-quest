-- Dependencies
local Smoke = require("game.objects.Smoke")
local Stone = require("game.objects.Stone")
local Room  = require("game.Room")

-- Fake Stone class
local FakeStone = Stone:derive("FakeStone")

-- Copies movement and direction entity attributes
local function copyEntityAttributes(dst, src)
    dst.direction = src.direction
    dst.moving = src.moving
    dst.x = src.x
    dst.y = src.y
    dst.nx = src.nx
    dst.ny = src.ny
    dst.vx = src.vx
    dst.vy = src.vy
end

-- Constructor
function FakeStone:FakeStone(target, timeout)
    self:Stone(target.x, target.y) -- Superclass constructor
    self.target = target           -- Petrified object
    self.timeout = timeout         -- Petrification duration timer

    copyEntityAttributes(self, target) -- Copy attributes
end

-- Draws fake stone
function FakeStone:draw()
    Stone.draw(self)
    -- Test in case fake stone is falling into the abyss
    if not self.destroyed then
        Room.drawTimeout(self.timeout, self.x, self.y)
    end
end

-- Updates fake stone
function FakeStone:update(delta)
    Stone.update(self, delta)

    -- Update timeout
    if self.timeout > 0 then
        self.timeout = self.timeout - delta
    -- Recover petrified object when timeout is out
    elseif self.x == self.nx and self.y == self.ny then
        self.destroyed = true
        self.target.destroyed = false
        copyEntityAttributes(self.target, self)
        Room.addObject(self.target) -- Recover original object
        Room.addObject(Smoke(self)) -- Add smoke effect
    end
end

return FakeStone
