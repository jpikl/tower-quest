-- Dependencies
local Assets     = require("engine.Assets")
local Config     = require("engine.Config")
local Repeater   = require("engine.Repeater")
local State      = require("engine.State")
local Transition = require("engine.Transition")
local Clouds     = require("game.Clouds")

-- Intro state
local Intro = {}

local introMessage = [[
A long time ago,

there was a tower full of puzzles, treasures and deadly traps...
]];

-- Black screen animation variables
local blackScreenTime = 7
local blackScreenAlpha = 255

-- Background animation variables
local bg1Image = Assets.images.intro1
local bg2Image = Assets.images.intro2
local bg3Image = Assets.images.intro3
local bg2Repeat = 25
local bg2PerScreen = math.floor(Config.gameHeight / bg2Image:getHeight()) + 2
local limit1 = 64
local limit2 = limit1 + bg1Image:getHeight()
local limit3 = limit2 + bg2Repeat * bg2Image:getHeight()
local limit4 = limit3 + bg3Image:getHeight()
local cloudsLimit = limit3
local cameraStartY = limit4 - Config.gameHeight
local cameraY = cameraStartY

-- Player animation variables
local playerSpriteSheet = Assets.sprites.player
local playerAnimation = Assets.animations.player:clone()
local playerWalkSound = Repeater(0.5, function() Assets.sounds.walk:play() end):play()
local playerX = (Config.gameWidth - 16) / 2
local playerY = Config.gameHeight + 16
local playerStartY = Config.gameHeight + 16
local playerEndY = Config.gameHeight - 16 * 7.1
local playerAlpha = 255

-- Activates intro
function Intro.activate()
    Clouds.setTopGeneration(true)
    playerAnimation:setSequence("up"):play()
end

-- Draws intro
function Intro.draw()
    -- Draw sky
    love.graphics.setColor(167, 186, 218)
    love.graphics.rectangle("fill", 0, 0, Config.gameWidth, Config.gameHeight)

    -- Draw background clouds
    love.graphics.setColor(255, 255, 255)
    Clouds.drawBack()

    -- Draw repeatedly middle part of the tower
    local cameraBottom = cameraY + Config.gameHeight
    if (cameraBottom >= limit2) and (cameraY <= limit3) then
        local index = math.floor((cameraY - limit2) / bg2Image:getHeight())
        local y = limit2 - cameraY + math.max(index * bg2Image:getHeight(), 0)
        for i = 1, bg2PerScreen do
            love.graphics.draw(bg2Image, 0, y)
            y = y + bg2Image:getHeight()
        end
    end

    -- Draw top part of the tower
    if (cameraBottom >= limit1) and (cameraY <= limit2) then
        love.graphics.draw(bg1Image, 0, limit1 - cameraY)
    end

    -- Draw bottom part of the tower
    if (cameraBottom >= limit3) and (cameraY <= limit4) then
        love.graphics.draw(bg3Image, 0, limit3 - cameraY)
    end

    -- Draw player if visible
    if playerY > playerEndY then
        playerAnimation:draw(playerX, playerY)
    elseif playerAlpha > 0 then
        love.graphics.setColor(255, 255, 255, playerAlpha)
        playerSpriteSheet[2]:draw( playerX, playerY)
    end

    -- Draw foreground clouds
    Clouds.drawFront()

    -- Draw black screen with title
    if blackScreenAlpha > 0 then
        love.graphics.setColor(0, 0, 0, blackScreenAlpha)
        love.graphics.rectangle("fill", 0, 0, Config.gameWidth, Config.gameHeight)
        local titleAlpha
        if blackScreenTime > 1 then
            titleAlpha = 255
        elseif blackScreenTime > 0.5 then
            titleAlpha = 255 * (1 - (1 - blackScreenTime) / 0.5)
        else
            titleAlpha = 0
        end
        love.graphics.setColor(255, 255, 255, titleAlpha)
        love.graphics.printf(introMessage, (Config.gameWidth - 200) / 2, 90, 200, "center")
    end
end

-- Updates intro
function Intro.update(delta)
    -- Phase 1: Black screen with title
    if blackScreenTime > 0 then
        blackScreenTime = blackScreenTime - delta

    -- Phase 2: Disappearing black screen
    elseif blackScreenAlpha > 0 then
        blackScreenAlpha = blackScreenAlpha - 128 * delta

    -- Phase 3: Walking player
    elseif playerY > playerEndY then
        playerWalkSound:update(delta)
        playerAnimation:update(delta)
        playerY = math.max(playerY - 25 * delta, playerEndY)

    -- Phase 4: Disappearing player (+ pause)
    elseif playerAlpha > -128 then
        playerAlpha = playerAlpha - 200 * delta

    -- Phase 5: Move camera to the top of the tower
    elseif cameraY > 0 then
        local speed
        if cameraY > (cameraStartY - 500) then
            speed = 25 + (cameraStartY - cameraY)
        elseif cameraY > 500 then
            speed = 525
        else
            speed = 25 + cameraY
        end
        -- Setup clouds generation
        cameraY = math.max(cameraY - speed * delta, 0)
        if cameraY < cloudsLimit then
            Clouds.setMaxClouds(5 * (1 - cameraY / cloudsLimit))
            Clouds.setCameraY(cameraY)
            Clouds.update(delta)
        end

    -- Phase 6: End of the intro
    elseif not Transition.isRunning() then
        State.set("Title")
        Clouds.update(delta)
    else
        Clouds.update(delta)
    end
end

-- Process input press event
function Intro.inputPressed(input)
    if not Transition.isRunning() and input:is("skip") then
        State.switch("Title")
    end
end

return Intro
