-- Dependencies
local Assets       = require("engine.Assets")
local Class        = require("engine.Class")
local Config       = require("engine.Config")
local Music        = require("engine.Music")
local State        = require("engine.State")
local Transition   = require("engine.Transition")
local GenericMenu  = require("game.ui.GenericMenu")
local LevelsMenu   = require("game.ui.LevelsMenu")
local SettingsMenu = require("game.ui.SettingsMenu")
local UIManager    = require("game.ui.UIManager")
local Clouds       = require("game.Clouds")
local Profile      = require("game.Profile")

-- Title screen state
local Title = {}

-- Variables
local titleImage = Assets.images.title
local bgImage1 = Assets.images.intro1
local bgImage2 = Assets.images.intro2
local uiManager = UIManager()
local titleMenu = GenericMenu()
local settingsMenu = SettingsMenu()
local customLevelsMenu = LevelsMenu.customLevels
local playerProfile = Profile("save-1.json")

-- Starts game
local function startGame()
    -- Switch state
    if playerProfile:exists() then
        State.switch("Tower", playerProfile)
    else
        State.switch("Welcome", playerProfile)
    end
end

-- Initializes title screen
function Title.init()
    -- Initialize title menu
    titleMenu.closeable = false
    titleMenu.backgroundColor = { 0, 0, 0, 128 }
    titleMenu:addItem("Start Game", startGame)
    titleMenu:addItem("Custom Levels", function() customLevelsMenu:show(true) end)
    titleMenu:addItem("Level Editor", function() State.switch("Editor") end)
    titleMenu:addItem("Controls", function() State.switch("Controls") end)
    titleMenu:addItem("Settings", function() settingsMenu:show(true) end)
    titleMenu:addItem("Credits", function() State.switch("Credits") end)
    titleMenu:addItem("Quit", love.event.quit)

    -- Initialize other menus
    settingsMenu.backgroundColor = { 0, 0, 0, 128 }
    settingsMenu.parent = titleMenu
    customLevelsMenu.backgroundColor = { 0, 0, 0, 128 }
    customLevelsMenu.parent = titleMenu
    customLevelsMenu.maxVisibleSize = 7

    -- Initialize UI manager
    uiManager:add(titleMenu)
    uiManager:add(settingsMenu)
    uiManager:add(customLevelsMenu)
end

-- Activates title screen
function Title.activate(levelType)
    -- Show active menu
    if levelType == "custom" then
        customLevelsMenu:show()
    else
        titleMenu:show(true)
    end

    -- Show custom levels option when is not empty
    titleMenu:setItemEnabled(2, not customLevelsMenu:isEmpty())

    -- Initialize clouds
    Clouds.setCameraY(0)
    Clouds.setMaxClouds(5)
    Clouds.setTopGeneration(false)
    Clouds.fillScreen()

    -- Start music
    Music.fadeIn(Assets.music.title)
end

-- Draws title screen
function Title.draw()
    -- Draw sky
    love.graphics.setColor(167, 186, 218)
    love.graphics.rectangle("fill", 0, 0, Config.gameWidth, Config.gameHeight)
    love.graphics.setColor(255, 255, 255)

    -- Draw clouds and background
    Clouds.drawBack()
    love.graphics.draw(bgImage1, 0, 64)
    love.graphics.draw(bgImage2, 0, 64 + bgImage1:getHeight())
    Clouds.drawFront()

    -- Draw title
    love.graphics.draw(titleImage, (Config.gameWidth - titleImage:getWidth()) / 2, 24)

    -- Draw UI
    uiManager:draw()
end

-- Updates title screen
function Title.update(delta)
    Clouds.update(delta)
end

-- Processes input press event
function Title.inputPressed(input)
    if not Transition.isRunning() then
        uiManager:inputPressed(input)
    end
end

return Title
