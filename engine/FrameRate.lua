-- Frame rate module
local FrameRate = {}

-- Variables
local frameSize = 0
local frameTime = 0

-- Initializes frameSize rate
function FrameRate.init(config)
    FrameRate.setValue(config.frameRate)
    frameTime = love.timer.getTime()
end

-- Sets frame rate
function FrameRate.setValue(frameRate)
    frameTime = 1 / (frameRate or 60)
end

-- Begins FPS counting
function FrameRate.beginCounting()
    frameTime = frameTime + frameSize
end

-- Ends FPS counting and limits FPS
function FrameRate.endCounting()
    local currentTime = love.timer.getTime()
    if currentTime >= frameTime then
        frameTime = currentTime
    else
        love.timer.sleep(frameTime - currentTime)
    end
end

return FrameRate
