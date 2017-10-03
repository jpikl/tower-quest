-- Dependencies
local Log  = require("engine.Log")

-- Transition module
local Transition = {}

-- Variables
local gameWidth = 0         -- Game width
local gameHeight = 0        -- Game height
local defaultDuration = 0   -- Default transition duration
local defaultRenderer = nil -- Default function for rendering transition
local renderer = nil        -- Current function for rendering transition
local callback = nil        -- Transition callback
local timeLeft = 0          -- Remaining time
local timeTotal = 1         -- Total time

-- Basic transition renderer
local function simpleRenderer(progress, width, height)
    local alpha = 0
    if progress < 0.333 then
        alpha = 255 * progress / 0.333
    elseif progress < 0.666 then
        alpha = 255
    else
        alpha = 255 * (1.0 - progress) / 0.333
    end
    love.graphics.setColor(0, 0, 0, alpha)
    love.graphics.rectangle("fill", 0, 0, width, height)
end

-- Initializes transition
function Transition.init(config)
    gameWidth = config.gameWidth or 800
    gameHeight = config.gameHeight or 600
    Transition.setDuration(config.transitionDuration)
    Transition.setRenderer()
end

-- Starts new transition
function Transition.start(targetCallback, targetDuration, targetRenderer)
    callback = targetCallback
    renderer = targetRenderer or defaultRenderer
    timeTotal = targetDuration or defaultDuration
    timeLeft = timeTotal
end

-- Tests if transition is running
function Transition.isRunning()
    return timeLeft > 0
end

-- Sets transition duration
function Transition.setDuration(duration)
    defaultDuration = duration or 1
end

-- Sets function for rendering transition
function Transition.setRenderer(renderer)
    defaultRenderer = renderer or simpleRenderer
end

-- Updates transition
function Transition.update(delta)
    if timeLeft > 0 then
        -- Decrease time left
        timeLeft = timeLeft - delta
        -- Execute callback in the middle of transition
        if callback and timeLeft < timeTotal / 2 then
            callback()
            callback = nil
        end
    end
end

-- Draws transition
function Transition.draw()
    if timeLeft > 0 then
        renderer(timeLeft / timeTotal, gameWidth, gameHeight)
    end
end

return Transition
