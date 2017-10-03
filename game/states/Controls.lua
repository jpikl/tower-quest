-- Dependencies
local Assets     = require("engine.Assets")
local State      = require("engine.State")
local Transition = require("engine.Transition")

-- Variables
local screens = {
    Assets.images.controls1,
    Assets.images.controls2
}
local screenIndex = 1

-- Controls state
local Controls = {}

-- Shows next controls screen or switches to menu
local function nextScreen()
    if screenIndex < #screens then
        screenIndex = screenIndex + 1
    else
        State.set("Title")
    end
end

-- Activates controls screen
function Controls.activate()
    screenIndex = 1
end

-- Draws controls screen
function Controls.draw()
    love.graphics.draw(screens[screenIndex])
end

-- Processes input press event
function Controls.inputPressed(input)
    if not Transition.isRunning() and input:is("skip") then
        Transition.start(nextScreen)
    end
end

return Controls
