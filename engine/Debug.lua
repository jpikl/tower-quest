-- Dependencies
local Log   = require("engine.Log")
local ProFi = require("libraries.ProFi")

-- Debug module
local Debug = {}

-- Variables
local debugVisible = true

-- Draws debug information
local function drawDebug()
    if debugVisible then
        local fps = ("%.2f"):format(1 / love.timer.getAverageDelta())
        local memory = math.floor(collectgarbage("count")) .. " KiB"
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("Memory: " .. memory .. "\nFPS: " .. fps, 10, 10)
    end
end

-- Handles key press event
local function processKeyPressed(key)
    if love.keyboard.isDown("lctrl", "rctrl") then
        if key == "d" then
            debugVisible = not debugVisible
        elseif key == "p" then
            if not ProFi.has_started then
                Log.info("Starting profiler")
                ProFi:start()
            else
                Log.info("Stopping profiler")
                ProFi:stop()
                ProFi:writeReport("profiler.log")
                ProFi:reset()
            end
        elseif key == "g" then
            Log.info("Collecting garbage")
            collectgarbage("collect");
        end
    end
end

-- Empty function
local function doNothing()
end

-- Initializes debugging
function Debug.init(config)
    debugVisible = config.debugVisible ~= false
    if config.debugMode then
        Debug.draw = drawDebug
        Debug.keyPressed = processKeyPressed
    else
        Debug.draw = doNothing
        Debug.keyPressed = doNothing
    end
end

return Debug
