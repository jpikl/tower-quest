-- Dependencies
local Assets     = require("engine.Assets")
local Audio      = require("engine.Audio")
local Config     = require("engine.Config")
local Controller = require("engine.Controller")
local Debug      = require("engine.Debug")
local FrameRate  = require("engine.FrameRate")
local Function   = require("engine.Function")
local Log        = require("engine.Log")
local Music      = require("engine.Music")
local State      = require("engine.State")
local Reporter   = require("engine.Reporter")
local Transition = require("engine.Transition")
local Video      = require("engine.Video")
local Notify     = require("game.Notify")

-- Variables
local busy = false
local screenshotsQueue = nil -- Level names waiting for screenshot (screenshot mode)
local screenshotsPending = 0 -- Screenshot captures waiting for callback

-- Setups screen with 'loading...' title
local function setupLoadingScreen()
    local screen = love.graphics.newImage("graphics/loading.png")
    love.graphics.draw(screen)
    love.graphics.present()
end

-- Hooks some modules
local function installHooks()
    State.update = Function.around(State.update, function(update, delta)
        delta = 0.5 * delta * Config.baseSpeed

        -- We run the update twice with 1/2 delta for more precise simulation
        update(delta)
        update(delta)

        if Config.turboMode then
            update(delta)
            update(delta)
        end
    end)

    Controller.keyPressed = Function.before(Controller.keyPressed, function(...)
        Debug.keyPressed(...)
        State.keyPressed(...)
    end)

    love.busy = function()
        busy = true
    end
end

-- Loads levels metadata
local function loadMetadata()
    -- Must be required after Assets module is loaded
    require("game.states.Tower").load()
    require("game.ui.LevelsMenu").load()
end

-- Renders level for screenshot
local function renderScreenshotLevel(name)
    local Room = require("game.Room")

    Room.create("levels/" .. name .. ".lua")
    Room.skipMessage()
    love.graphics.reset()
    love.graphics.clear()
    Video.beginDrawing()
    Room.draw()
    Video.endDrawing()
end

-- Enqueues screenshots of all levels
local function makeScreenshots()
    local Tower = require("game.states.Tower")

    love.filesystem.createDirectory("screenshots")

    screenshotsQueue = {}

    for floor = 1, Tower.getMaxFloor() do
        for room = 1, 4 do
            screenshotsQueue[#screenshotsQueue + 1] = string.format("%02d-%02d", floor, room)
            screenshotsPending = screenshotsPending + 1
        end
    end
end

-- Captures screenshot of the next enqueued level
local function captureNextScreenshot()
    local name = table.remove(screenshotsQueue, 1)
    if name == nil then
        return
    end

    Log.info("Making screenshot of level " .. name)
    renderScreenshotLevel(name)

    love.graphics.captureScreenshot(function(imageData)
        love.filesystem.write("screenshots/" .. name .. ".png", imageData:encode("png"))
        screenshotsPending = screenshotsPending - 1
        if screenshotsPending <= 0 then
            love.event.quit()
        end
    end)
end

-- Initializes game
function love.load()
    -- Begin initialization
    Log.info("Loading...")
    setupLoadingScreen()

    -- Install hooks
    installHooks()
    Audio.hook()
    Controller.hook()

    -- Load modules data
    Config.load()
    Reporter.init(Config)
    Assets.load(Config)
    loadMetadata()

    -- Initialize rest of the modules
    Audio.init(Config)
    Controller.init(Config)
    Debug.init(Config)
    FrameRate.init(Config)
    Music.init(Config)
    State.init(Config)
    Transition.init(Config)
    Notify.init(Config)
    Video.init(Config)

    -- Finish initialization
    Log.info("Loading finished")

    -- Enqueue screenshots if set (captured one per frame in love.draw)
    if Config.makeScreenshots then
        makeScreenshots()
    end

    -- Play testing level if set
    if Config.testingLevel then
        State.set("Game", "testing", Config.testingLevel)
    end
end

-- Processes change of window visibility
function love.visible(visible)
    Log.info("Window visible: %s", visible)
    if visible then
        Music.resume()
    else
        Music.pause()
    end
end

-- Updates game
function love.update(delta)
    if screenshotsQueue then
        return -- Screenshot mode has no game updates
    end
    if busy or not love.window.isVisible() then
        busy = false
        return
    end
    FrameRate.beginCounting()
    Music.update(delta)
    Notify.update(delta)
    State.update(delta)
    Transition.update(delta)
    Controller.update(delta)
end

-- Draws game
function love.draw()
    if screenshotsQueue then
        captureNextScreenshot()
        return
    end
    Video.beginDrawing()
    State.draw()
    Transition.draw()
    Notify.draw()
    Debug.draw()
    Video.endDrawing()
    FrameRate.endCounting()
end

-- Quits game
function love.quit()
    Log.info("Quitting...")
    State.quit()
    Config.save()
end
