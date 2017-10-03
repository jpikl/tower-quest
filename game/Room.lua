-- Dependencies
local Assets  = require("engine.Assets")
local Config  = require("engine.Config")
local Log     = require("engine.Log")
local Table   = require("engine.Table")
local Object  = require("game.objects.Object")
local Mapping = require("game.Mapping")
local Level   = require("game.Level")

-- Room module
local Room = {}

-- Variables
local level = nil     -- Level data
local drawX = 0       -- X coordinate of room area
local drawY = 0       -- Y coordinate of room area
local width = 0       -- Width of room area
local height = 0      -- Height of room area
local walls = {}      -- Walls
local objects = {}    -- Objects
local timeouts = {}   -- Timeouts
local particles = {}  -- Particles
local error = nil     -- Error message
local message = nil   -- Room message
local sprites = Assets.sprites.background -- Background sprites
local batch = sprites:createBatch(300)     -- Batch for drawing background

-- Initializes walls
local function initWalls()
    walls = {}

    for i = 1, level:getHeight() do
        walls[i] = {}
        for j = 1, level:getWidth() do
            walls[i][j] = level:getData(j, i) == Mapping.getWall()
        end
    end
end

-- Initializes objects
local function initObjects()
    objects = {}
    timeouts = {}
    particles = {}

    for i = 1, level:getHeight() do
        for j = 1, level:getWidth() do
            local x = 16 * (j - 1)
            local y = 16 * (i - 1)
            local character = level:getData(j, i)
            local object = Mapping.createObject(character, x, y)
            if object then
                table.insert(objects, object)
            end
        end
    end
end

-- Initializes attributes
local function initAttributes()
    width = level:getWidth() * 16
    height = level:getHeight() * 16
    drawX = (Config.gameWidth - width) / 2
    drawY = (Config.gameHeight - height) / 2
    message = level.message
end

-- Initializes state
local function initState()
    Room.diamondsCount = 0   -- Number of diamonds in room
    Room.keyObtained = false -- Is key obtained?

    -- Number of activated switches for each group
    Room.activatedSwitches = {
        white = 0,
        red = 0,
        blue = 0
    }
end

-- Initializes batch for drawing background
local function initBatch()
    batch:clear()

    for i = 1, level:getHeight() do
        for j = 1, level:getWidth() do
            local sprite = level:getBackgroundSprite(j, i)
            if sprite then
                local x = (j - 1) * 16
                local y = (i - 1) * 16
                sprite:addToBatch(batch, x, y)
            end
        end
    end
end

-- Creates room by loading specified level
function Room.create(source)
    if type(source) == "string" then
        Log.info("Loading level '%s'", source)
        level, error = Level(source)
    else
        Log.info("Starting level")
        level = Table.copy(source)
        error = level:validate()
    end

    if error then
        Log.error("Corrupted level: %s", error)
    else
        level:normalize()
        initWalls()
        initAttributes()
        initBatch()
        Room.restart()
    end
end

-- Restarts room
function Room.restart()
    initState()
    initObjects()
end

-- Stores room data to memento
function Room.persist(memento)
    memento.roomObjects = objects
    memento.diamondsCount = Room.diamondsCount
    memento.keyObtained = Room.keyObtained
    memento.activatedSwitches = Room.activatedSwitches
end

-- Restores room data from memento
function Room.restore(memento)
    objects = memento.roomObjects
    timeouts = {}
    particles = {}

    Room.diamondsCount = memento.diamondsCount
    Room.keyObtained = memento.keyObtained
    Room.activatedSwitches = memento.activatedSwitches

    -- Restore objects
    for i, object in ipairs(objects) do
        if object.restored then
            object:restored()
        end
    end
end

-- Adds timeout to draw
function Room.drawTimeout(time, x, y)
    timeouts[#timeouts + 1] = {
        x = x,
        y = y,
        time = time
    }
end

-- Adds particles to draw
function Room.drawParticles(data, x, y, time)
    particles[#particles + 1] = {
        x = x,
        y = y,
        data = data,
        time = time or 0
    }
end

-- Draws message
local function drawMessage(message, border, r, g, b, a)
    love.graphics.setColor(r, g, b, a or 255)
    love.graphics.rectangle("fill", 0, 0, Config.gameWidth, Config.gameHeight)
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(message, border, border, Config.gameWidth - 2 * border)
end

-- Draws room
function Room.draw()
    -- Draw error message
    if error then
        drawMessage(error, 32, 255, 0, 0)
        return
    end

    -- Draw background
    love.graphics.push()
    love.graphics.translate(drawX, drawY)
    love.graphics.draw(batch, 0, 0)

    -- Draw objects
    for i, object in ipairs(objects) do
        object:draw()
    end

    -- Draw timeouts
    love.graphics.setFont(Assets.fonts.tiny)
    for i, item in ipairs(timeouts) do
        local total = item.time + 1
        local value = math.floor(total)
        local ratio = total - value
        love.graphics.setColor(255, 255, 255, 255 * ratio)
        love.graphics.print(tostring(value), item.x, item.y - 8 * (1 - ratio))
    end
    love.graphics.setFont(Assets.fonts.normal)
    love.graphics.setColor(255, 255, 255)

    -- Draw particles
    for i, item in ipairs(particles) do
        love.graphics.draw(item.data, item.x, item.y)
    end

    -- Restore graphics state
    love.graphics.pop()

    -- Draw text message
    if message then
        drawMessage(message, 48, 0, 0, 0, 196)
    end
end

-- Updates room
function Room.update(delta)
    -- Waiting for confirmation
    if error or message then
        return
    end

    -- Remove destroyed objects
    Table.filter(objects, function(i, object)
        return object.destroyed
    end)

    -- Update objects (remove object immediately when it destroys itself)
    Table.filter(objects, function(i, object)
        object:update(delta)
        return object.destroyed
    end)

    -- Sort objects for drawing
    table.sort(objects, Object.compare)

    -- Clear all timeouts
    timeouts = {}

    -- Clear finished particles
    Table.filter(particles, function(i, item)
        item.data:update(delta)
        item.time = item.time - delta
        return item.time <= 0
    end)
end

-- Check if error is displayed
function Room.isError()
    return error ~= nil
end

-- Checks if message is displayed
function Room.isMessage()
    return message ~= nil
end

-- Checks if room is started
function Room.isStarted()
    return not error and not message
end

-- Skips message
function Room.skipMessage()
    message = nil
end

-- Adds object to room
function Room.addObject(object)
    table.insert(objects, object);
end

-- Returns iterator over all objects except the specified one
function Room.getObjectsIterator(currentObject)
    local i = 0
    return function()
        local object
        repeat
            i = i + 1
            object = objects[i]
        until object ~= currentObject
        return object
    end
end

-- Checks if the specified area contains solid objects
local function isSolid(x1, y1, x2, y2)
    -- Room border collision test
    if (x1 < 0) or (y1 < 0) or (x2 >= width) or (y2 >= height) then
        return true
    end
    -- Wall collision test
    local j1 = math.floor(x1 / 16) + 1
    local j2 = math.floor(x2 / 16) + 1
    local i1 = math.floor(y1 / 16) + 1
    local i2 = math.floor(y2 / 16) + 1
    return walls[i1][j1] or walls[i1][j2] or walls[i2][j1] or walls[i2][j2]
end

-- Checks if an object collides with the environment or another object
function Room.isCollision(target, border, dx, dy, checkPlaceholders)
    local x1, y1, x2, y2 = target:getBounds(border, dx, dy)

    -- Environment collision test
    if isSolid(x1, y1, x2, y2) then
        return true
    end

    -- Objects collision test
    for i, object in ipairs(objects) do
        if object ~= target and object:collideWith(target) then
            -- Placeholder collision test
            if checkPlaceholders and
               object.moving and
               object.placeholder:intersectsArea(x1, y1, x2, y2, space) then
                return true
            end
            -- Object collision test
            if object:intersectsArea(x1, y1, x2, y2, space) then
                return true
            end
        end
    end

    return false
end

-- Checks if an object can move to the specified location
function Room.canMove(target, dx, dy)
    return not Room.isCollision(target, 1) and            -- Current location
           not Room.isCollision(target, 1, dx, dy, true)  -- Target location
end

-- Checks if an object can move to the specified location when pushing other objects
function Room.canPush(target, dx, dy, power, pushedObjects)
    -- Check if the target can be pushed and does not collide with anything
    if not target.weight or Room.isCollision(target, 1) then
        return false
    end

    -- Check if the target has enough power to push other objects
    local weight = pushedObjects.weight + target.weight
    if power < weight then
        return false
    end

    -- Environment collision test
    local x1, y1, x2, y2 = target:getBounds(1, dx, dy)
    if isSolid(x1, y1, x2, y2) then
        return false
    end

    -- Update pushed objects
    pushedObjects[target] = true
    pushedObjects.weight = weight

    -- Objects collision test
    for i, object in ipairs(objects) do
        if not pushedObjects[object] and object:collideWith(target) then
            -- Placeholder collision test
            if object.moving and object.placeholder:intersectsArea(x1, y1, x2, y2, space) then
                return false
            end
            -- Object collision test
            if object:intersectsArea(x1, y1, x2, y2, space) then
                -- Give the object same direction as the target (in case it has this attribute)
                -- Needed for correct functioning of Arrow objects
                if object.direction then
                    object.direction = target.direction
                end
                -- Try to push the object
                if not Room.canPush(object, dx, dy, power, pushedObjects) then
                    return false
                end
            end
        end
    end

    return true
end

return Room
