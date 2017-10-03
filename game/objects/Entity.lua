-- Dependencies
local Object = require("game.objects.Object")
local Room   = require("game.Room")

-- Entity class
local Entity = Object:derive("Entity")

-- Converts direction to vector
function Entity.createVector(direction, length)
    if direction == "right" then
        return length, 0
    elseif direction == "left" then
        return -length, 0
    elseif direction ==  "down" then
        return 0, length
    elseif direction == "up" then
        return 0, -length
    else
        return 0, 0
    end
end

-- Constructor
function Entity:Entity(x, y, z, w, h)
    self:Object(x, y, z, w, h) -- Superclass constructor
    self.direction = "down"    -- Direction
    self.weight = 100          -- Weight
    self.power = 0             -- Power to push things
    self.moving = false        -- Is moving?
    self.nx = self.x           -- Target x coordinate
    self.ny = self.y           -- Target y coordinate
    self.vx = 0                -- X velocity
    self.vy = 0                -- Y velocity

    -- Placeholder object (for collision avoidance)
    self.placeholder = self:clone()
end

-- Moves entity to the specified position
function Entity:moveTo(dx, dy, speed)
    if (dy == 0) and (dx == 0) then
        return
    end

    -- Target position
    self.nx = self.x + dx
    self.ny = self.y + dy

    -- Move placeholder on the target position (for collision avoidance)
    self.placeholder.x = self.nx
    self.placeholder.y = self.ny

    -- Velocity
    local k = speed / math.sqrt(dx * dx + dy * dy)
    self.vx = k * dx
    self.vy = k * dy

    -- State
    self.moving = true
end

-- Moves entity to the specified direction
function Entity:move(direction, speed)
    if self.moving then
        return false
    end

    local dx, dy = Entity.createVector(direction, 16)
    self.direction = direction

    if Room.canMove(self, dx, dy) then
        self:moveTo(dx, dy, speed)
        return true
    else
        return false
    end
end

-- Moves entity and pushes blocking objects to the specified direction
function Entity:push(direction, speed)
    if self.moving then
        return false
    end

    local dx, dy = Entity.createVector(direction, 16)
    local power = self.power + self.weight
    local pushedObjects = { weight = 0 }
    self.direction = direction

    if Room.canPush(self, dx, dy, power, pushedObjects) then
        pushedObjects.weight = nil
        for obj in pairs(pushedObjects) do
            obj:moveTo(dx, dy, speed)
        end
        return true
    else
        return false
    end
end

-- Updates entity
function Entity:update(delta)
    if not self.moving then
        return
    end

    self.x = self.x + self.vx * delta
    self.y = self.y + self.vy * delta

    if (self.vx > 0 and self.x >= self.nx) or
       (self.vx < 0 and self.x <= self.nx) then
       self.x = self.nx
       self.vx = 0
    end

    if (self.vy > 0 and self.y >= self.ny) or
       (self.vy < 0 and self.y <= self.ny) then
       self.y = self.ny
       self.vy = 0
    end

    self.moving = self.vx ~= 0 or self.vy ~= 0
end

return Entity
