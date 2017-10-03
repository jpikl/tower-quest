-- Dependencies
local Assets = require("engine.Assets")
local Config = require("engine.Config")
local Table  = require("engine.Table")

-- Clouds module
local Clouds = {}

-- Variables
local gameWidth = Config.gameWidth
local gameHeight = Config.gameHeight
local sprites = Assets.sprites.clouds
local cloudWidth = sprites[1].width
local cloudHeight = sprites[1].height
local clouds = {}
local maxClouds = 0
local topGeneration = false
local cameraY = 0

-- Generates cloud in the specified area
local function generateCloud(left, right, top, bottom)
    return {
        front = love.math.random() > 0.5,
        x = love.math.random(left, right),
        y = love.math.random(top, bottom),
        speed = love.math.random(16, 64),
        sprite = love.math.random(1, #sprites)
    }
end

-- Generates cloud in the top area
local function generateCloudOnTop()
    local left = -cloudWidth / 2
    local right = gameWidth - cloudWidth / 2
    local top = cameraY - gameHeight
    local bottom = cameraY - cloudHeight
    return generateCloud(left, right, top, bottom)
end

-- Generates cloud in the middle area
local function generateCloudInMiddle()
    local left = -cloudWidth / 2
    local right = gameWidth - cloudWidth / 2
    local top = cameraY - cloudHeight / 2
    local bottom = cameraY + gameHeight - cloudHeight / 2
    return generateCloud(left, right, top, bottom)
end

-- Generates cloud in the right area
local function generateCloudOnRight()
    local left = gameWidth
    local right = gameWidth + cloudWidth / 2
    local top = cameraY - cloudHeight / 2
    local bottom = cameraY + gameHeight - cloudHeight / 2
    return generateCloud(left, right, top, bottom)
end

-- Generates missing clouds using the generator function
local function generateMissingClouds(generator)
    for i = 1, maxClouds - #clouds do
        table.insert(clouds, generator())
    end
end

-- Draws clouds in front or back area
local function drawClouds(front)
    for i, cloud in ipairs(clouds) do
        if cloud.front == front then
            sprites[cloud.sprite]:draw(cloud.x, cloud.y - cameraY)
        end
    end
end

-- Draws clouds in front area
function Clouds.drawFront()
    drawClouds(true)
end

-- Draws clouds in back area
function Clouds.drawBack()
    drawClouds(false)
end

-- Updates clouds
function Clouds.update(delta)
    Table.filter(clouds, function(i, cloud)
        cloud.x = cloud.x - cloud.speed * delta
        return cloud.x < -cloudWidth or cloud.y > cameraY + gameHeight
    end)

    if topGeneration then
        generateMissingClouds(generateCloudOnTop)
    else
        generateMissingClouds(generateCloudOnRight)
    end
end

-- Fills screen with clouds
function Clouds.fillScreen()
    generateMissingClouds(generateCloudInMiddle)
end

-- Sets maximum number of clouds
function Clouds.setMaxClouds(value)
    maxClouds = value
end

-- Sets camera Y position
function Clouds.setCameraY(value)
    cameraY = value
end

-- Enables cloud generation above the camera
function Clouds.setTopGeneration(value)
    topGeneration = value
end

return Clouds
