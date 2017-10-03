-- Dependencies
local Assets       = require("engine.Assets")
local Cheater      = require("engine.Cheater")
local Config       = require("engine.Config")
local Controller   = require("engine.Controller")
local Log          = require("engine.Log")
local Memento      = require("engine.Memento")
local Music        = require("engine.Music")
local State        = require("engine.State")
local Transition   = require("engine.Transition")
local Player       = require("game.objects.Player")
local GenericMenu  = require("game.ui.GenericMenu")
local SettingsMenu = require("game.ui.SettingsMenu")
local UIManager    = require("game.ui.UIManager")
local Tower        = require("game.states.Tower")
local Notify       = require("game.Notify")
local Room         = require("game.Room")

-- Game state
local Game = {}

-- Variables
local playerProfile = nil                        -- Player profile
local saveData = nil                             -- Quick save data
local floorNumber = 1                            -- Current floor
local roomNumber = 1                             -- Current room
local levelType = "normal"                       -- Type of level (normal/custom/testing/editor)
local quitRequested = false                      -- Quit from room requested
local endingRequested = false                    -- Switch to ending state requested
local completionSound = Assets.sounds.completion -- Level completion sound
local gameMenu = GenericMenu()                   -- Game menu
local retryMenu = GenericMenu()                  -- Retry menu
local settingsMenu = SettingsMenu()              -- Settings menu
local uiManager = UIManager()                    -- UI manager
local cheater = Cheater()                        -- Cheat codes

cheater:addCheat("winthislevel", function()
    Room.skipMessage()
    gameMenu:close()
    retryMenu:close()
    settingsMenu:close()
    Game.completeRoom(true)
    Notify.set("Such a cheater!", 3)
end)

-- Saves game
local function quickSave()
    Log.info("Saving game")
    saveData = Memento()
    Room.persist(saveData)
    Player.persist(saveData)
    gameMenu:setItemEnabled(4, true)
    retryMenu:setItemEnabled(1, true)
    Notify.set("Game saved")
end

-- Loads game
local function quickLoad()
    if saveData then
        Log.info("Loading game")
        local loadData = Memento(saveData)
        Room.restore(loadData)
        Player.restore(loadData)
        Notify.set("Game loaded")
    end
end

-- Restarts current room
local function restartRoom()
    Transition.start(Room.restart)
end

-- Completes and quits current room
function Game.completeRoom(cheated)
    if not quitRequested then
        -- Schedule termination
        quitRequested = true
        Music.fadeOut()
        completionSound:play()

        -- Update player profile if necessary
        if levelType == "normal" then
            playerProfile:completeLevel(floorNumber, roomNumber, cheated)
            playerProfile:save()

            -- Check whether to show ending after quit
            local maxFloor = Tower.getMaxFloor()
            local finalLevel = floorNumber == maxFloor and roomNumber == 4
            local everythingCompleted = playerProfile:isEveryLevelCompleted(maxFloor)
            endingRequested = finalLevel and everythingCompleted
        end
    end
end

-- Quits game state
local function quitGame()
    if levelType == "normal" then
        if endingRequested then
            State.switch("Ending", playerProfile)
        else
            State.switch("Tower")
        end
    elseif levelType == "custom" then
        State.switch("Title", "custom")
    elseif levelType == "editor" then
        State.switch("Editor")
    else
        love.event.quit()
    end
end

-- Initializes game
function Game.init()
    -- Initialize game menu
    gameMenu.backgroundColor = { 0, 0, 0, 196 }
    gameMenu:addItem("Continue")
    gameMenu:addItem("Restart", restartRoom)
    gameMenu:addItem("Save game", quickSave)
    gameMenu:addItem("Load game", quickLoad)
    gameMenu:addItem("Settings", function() settingsMenu:show(true) end)
    gameMenu:addItem("Quit", quitGame)

    -- Initialize retry menu
    retryMenu:addItem("Load game", quickLoad)
    retryMenu:addItem("Restart", restartRoom)
    retryMenu:addItem("Quit", quitGame)

    -- Initialize settings menu
    settingsMenu.backgroundColor = { 0, 0, 0, 196 }
    settingsMenu.parent = gameMenu

    -- Initialize UI manager
    uiManager:add(gameMenu)
    uiManager:add(retryMenu)
    uiManager:add(settingsMenu)
end

-- Activates game
function Game.activate(type, param1, param2, param3)
    -- Initialize variables
    playerProfile = nil
    saveData = nil
    floorNumber = nil
    roomNumber = nil
    levelType = type
    quitRequested = false
    endingRequested = false
    gameMenu:setItemEnabled(4, false)
    retryMenu:setItemEnabled(1, false)

    -- Level was selected from level selection screen
    if levelType == "normal" then
        floorNumber = param1 or 1
        roomNumber = param2 or 1
        playerProfile = param3
        Room.create(string.format("levels/%02d-%02d.lua", floorNumber, roomNumber))
        Music.fadeIn(roomNumber <= 2 and Assets.music.game1 or Assets.music.game2)
    -- Custom level
    elseif levelType == "custom" then
        Music.fadeIn(love.math.random(1, 2) == 1 and Assets.music.game1 or Assets.music.game2)
        Room.create(param1)
    -- Testing or editor level (without music)
    else
        Music.fadeOut()
        Room.create(param1)
    end
end

-- Draws game
function Game.draw()
    -- Draw room
    Room.draw()

    -- Draw red screen when player is dead
    if Room.isStarted() and not Player.instance.alive then
        love.graphics.setColor(255, 0, 0, 160)
        love.graphics.rectangle("fill", 0, 0, Config.gameWidth, Config.gameHeight)
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(Assets.fonts.big)
        love.graphics.printf("You have died!", 0, 64, Config.gameWidth, "center")
        love.graphics.setFont(Assets.fonts.normal)
    end

    -- Draw UI
    uiManager:draw()
end

-- Updates game
function Game.update(delta)
    -- Retry menu does not pause the game
    if Transition.isRunning() or gameMenu.visible or settingsMenu.visible then
        return
    end

    -- Is quit requested?
    if quitRequested then
        -- Switch game state in the moment the completion sound finishes
        if completionSound:isStopped() then
            quitRequested = false
            quitGame()
        end
        return
    end

    -- Update room
    Room.update(delta)

    if Room.isStarted() then
        -- Update player control
        if Player.instance.alive then
            if Controller.isDown("left") then
                Player.instance:moveLeft()
            elseif Controller.isDown("right") then
                Player.instance:moveRight()
            elseif Controller.isDown("up") then
                Player.instance:moveUp()
            elseif Controller.isDown("down") then
                Player.instance:moveDown()
            else
                Player.instance:stop()
            end
        -- Show retry menu when player dies
        elseif not retryMenu.visible then
            retryMenu:show(true)
        end
    end
end

-- Processes input press event
function Game.inputPressed(input)
    if Transition.isRunning() or quitRequested then
        return
    end

    -- Skip error message
    if Room.isError() then
        if input:is("skip") then
            quitGame()
        end
    -- Skip level message
    elseif Room.isMessage() then
        if input:is("skip") then
            Room.skipMessage()
        end
    -- Process UI input
    elseif uiManager:isActive() then
        uiManager:inputPressed(input)
    -- Process game input
    else
        if input:is("shot") then
            Player.instance:shot()
        elseif input:is("restart") then
            restartRoom()
        elseif input:is("save") then
            quickSave()
        elseif input:is("load") then
            quickLoad()
        elseif input:is("menu") then
            gameMenu:show(true)
        end
    end
end

-- Processes key press event
function Game.keyPressed(key)
    cheater:inputUsed(key)
end

return Game
