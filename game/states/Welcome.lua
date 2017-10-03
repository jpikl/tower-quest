-- Dependencies
local Config     = require("engine.Config")
local Music      = require("engine.Music")
local State      = require("engine.State")
local Transition = require("engine.Transition")

-- Welcome state
local Welcome = {}

-- Variables
local playerProfile = nil
local welcomeText = [[
Hello there!

A quest is awaiting for you.

Can you beat all levels and reach the top of the tower?

Well, let's see...
]]

-- Activates welcome
function Welcome.activate(profile)
    playerProfile = profile
    Music.fadeOut(2)
end

-- Draws welcome
function Welcome.draw()
    love.graphics.printf(welcomeText, 32, 32, Config.gameWidth - 64, "left")
    love.graphics.printf("Press [space] to continue.", 0, 168, Config.gameWidth, "center")
end

-- Processes input press event
function Welcome.inputPressed(input)
    if not Transition.isRunning() and input:is("skip") then
        State.switch("Tower", playerProfile)
    end
end

return Welcome
