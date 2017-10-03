-- Dependencies
local Assets     = require("engine.Assets")
local Cheater    = require("engine.Cheater")
local Config     = require("engine.Config")
local Log        = require("engine.Log")
local Math       = require("engine.Math")
local Music      = require("engine.Music")
local State      = require("engine.State")
local Transition = require("engine.Transition")
local Level      = require("game.Level")
local Notify     = require("game.Notify")

-- Tower screen state (level selection)
local Tower = {}

-- Variables
local sound = Assets.sounds.ui
local sprites = Assets.sprites.selection
local uiSpriteSheet = Assets.sprites.ui
local playerProfile = nil
local maxFloor = nil
local topFloor = nil
local selectedFloor = nil
local selectedRoom = nil
local levelNames = nil
local cheater = Cheater()

-- Add cheat to unlock all levels
cheater:addCheat("unlockalllevels", function()
    for floor = 1, maxFloor do
        for room = 1, 4 do
            playerProfile:unlockLevel(floor, room, true)
        end
    end
    playerProfile:save()
    Notify.set("Such a cheater!", 3)
end)

-- Add cheat to win all levels
cheater:addCheat("winalllevels", function()
    if Config.debugMode then
        for floor = 1, maxFloor do
            for room = 1, 4 do
                playerProfile:completeLevel(floor, room, true)
            end
        end
        playerProfile:save()
        Notify.set("Such a cheater!", 3)
    else
        Notify.set("Nice try :P", 3)
    end
end)

-- Loads level metadata from files
function Tower.load()
    Log.info("Searching for available levels")
    love.busy()

    local finished = false
    local floor = 0
    levelNames = {}

    while not finished do
        floor = floor + 1
        levelNames[floor] = {}

        for room = 1, 4 do
            -- Continue until next file does not exists
            local fileName = string.format("levels/%02d-%02d.lua", floor, room)
            if not love.filesystem.isFile(fileName) then
                finished = true
                break
            end

            -- Read level metadata
            Log.info("Processing '%s'", fileName)
            local metadata, error = Level(fileName, "metadata")
            if metadata then
                if metadata.name then
                    levelNames[floor][room] = metadata.name
                else
                    Log.error("Missing name for level '%s'", fileName)
                end
            else
                Log.error(error)
            end
        end
    end

    maxFloor = floor - 1
    topFloor = math.min(maxFloor, 3)
end

-- Finds default level floor and room numbers
local function findDefaultLevel()
    for floor = maxFloor, 1, -1 do
        if playerProfile:isLevelUnlocked(floor, 1) then
            for room = 1, 4 do
                if not playerProfile:isLevelCompleted(floor, room) then
                    return floor, room
                end
            end
            return floor, 4
        end
    end
    return 1, 1
end

-- Returns number of tha last floor
function Tower.getMaxFloor()
    return maxFloor
end

-- Activates levels selection screen
function Tower.activate(profile)
    -- Play music
    Music.fadeIn(Assets.music.levels)

    -- Override profile
    if profile then
        playerProfile = profile
    end

    -- Initialize level selection
    if not selectedFloor or not selectedRoom then
        selectedFloor, selectedRoom = findDefaultLevel()
        if topFloor < selectedFloor then
            topFloor = selectedFloor
        end
    end
end

-- Draws level selection screen
function Tower.draw()
    -- Draw name of the selected level
    local name
    if playerProfile:isLevelUnlocked(selectedFloor, selectedRoom) then
        name = levelNames[selectedFloor][selectedRoom] or "Unknown"
    else
        name = "???"
    end
    love.graphics.setFont(Assets.fonts.big)
    love.graphics.printf(name, 0, 16, Config.gameWidth, "center")
    love.graphics.setFont(Assets.fonts.normal)

    -- Draw sprites
    for floor = topFloor, math.max(topFloor - 2, 1), -1 do
        for room = 1, 4 do
            local x = 16 + 69 * (room - 1)
            local y = 52 + 56 * (topFloor - floor)

            -- Draw sprite
            if playerProfile:isLevelCompleted(floor, room) then
                sprites[3]:draw(x, y)
            elseif playerProfile:isLevelUnlocked(floor, room) then
                sprites[2]:draw(x, y)
            else
                sprites[1]:draw(x, y)
            end

            -- Draw label
            if playerProfile:isLevelUnlocked(floor, room) then
                local name = string.format("%02d-%d", floor, room)
                love.graphics.printf(name, x, y + 19, 56, "center")
            end

            -- Draw selection
            if floor == selectedFloor and room == selectedRoom then
                sprites[4]:draw( x, y)
            end
        end
    end

    -- Draw slider
    local sliderHeight = 20
    local sliderProgress = (topFloor - 3) / (maxFloor - 3)
    local sliderX = 298
    local sliderY = 204 - sliderHeight - (144 - sliderHeight) * sliderProgress
    love.graphics.setColor(255, 255, 255, 128)
    uiSpriteSheet[2]:draw(sliderX, 55)
    uiSpriteSheet[3]:draw(sliderX, 202)
    love.graphics.rectangle("fill", sliderX + 1, 60, 6, 144)
    love.graphics.setColor(255, 255, 255)
    uiSpriteSheet[2]:draw(sliderX, sliderY - 5)
    uiSpriteSheet[3]:draw(sliderX, sliderY + sliderHeight - 2)
    love.graphics.rectangle("fill", sliderX + 1, sliderY, 6, sliderHeight)

    -- Draw progress
    local totalLevels = maxFloor * 4
    local completedLevels = playerProfile:getCompletedLevelsCount(maxFloor)
    local progress = 100 * completedLevels / totalLevels
    local text = string.format("Completed %d of %d (%.1f%%)", completedLevels, totalLevels, progress)
    love.graphics.print(text, 18, Config.gameHeight - 17)
end

-- Processes input press event
function Tower.inputPressed(input)
    if Transition.isRunning() then
        return
    end

    if input:is("left") then
        selectedRoom = selectedRoom > 1 and selectedRoom - 1 or 4
        sound:play()
    elseif input:is("right") then
        selectedRoom = selectedRoom < 4 and selectedRoom + 1 or 1
        sound:play()
    elseif input:is("down") then
        selectedFloor = selectedFloor > 1 and selectedFloor - 1 or maxFloor
        topFloor = Math.fit(topFloor, selectedFloor, selectedFloor + 2)
        sound:play()
    elseif input:is("up") then
        selectedFloor = selectedFloor < maxFloor and selectedFloor + 1 or 1
        topFloor = Math.fit(topFloor, selectedFloor, selectedFloor + 2)
        sound:play()
    elseif input:is("confirm") then
        if playerProfile:isLevelUnlocked(selectedFloor, selectedRoom) then
            Notify.set("Loading...")
            State.switch("Game", "normal", selectedFloor, selectedRoom, playerProfile)
        end
    elseif input:is("cancel") then
        State.switch("Title")
    end
end

-- Processes key press event
function Tower.keyPressed(key)
    cheater:inputUsed(key)
end

return Tower
