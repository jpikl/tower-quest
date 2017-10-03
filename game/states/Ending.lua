-- Dependencies
local Config     = require("engine.Config")
local Music      = require("engine.Music")
local State      = require("engine.State")
local Transition = require("engine.Transition")
local Tower      = require("game.states.Tower")

-- Ending state
local Ending = {}

-- Variables
local endingText = nil
local endingTextTemplate = [[
%s

You've completed every single level.

Sadly, there is no proper ending since the game is unfinished. This message is the only reward you get :P

Thank you for playing!
]]

-- Activates ending
function Ending.activate(profile)
    local maxFloor = Tower.getMaxFloor()
    local cheated = profile:isAnyLevelCheated(maxFloor)
    local title = cheated and "CONGRATULATIONS CHEATER!" or "CONGRATULATIONS!"
    endingText = endingTextTemplate:format(title)
    Music.fadeOut(2)
end

-- Draws ending
function Ending.draw()
    love.graphics.printf(endingText, 48, 32, Config.gameWidth - 96, "center")
    love.graphics.printf("Press [space] to continue.", 0, 180, Config.gameWidth, "center")
end

-- Processes input press event
function Ending.inputPressed(input)
    if not Transition.isRunning() and input:is("skip") then
        State.switch("Credits")
    end
end

return Ending
