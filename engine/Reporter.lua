-- Reporter module
local Reporter = {}

-- Variables
local gameName = nil
local gameVersion = nil
local errorReportURL = nil
local logFileName = nil

-- Creates error report
local function createErrorReport(message, showSystemInfo)
    local report = {}

    -- Add system information
    if showSystemInfo then
        rendererName, rendererVersion, rendererVendor, rendererDevice = love.graphics.getRendererInfo()
        table.insert(report, ("Game name:         %s"):format(gameName))
        table.insert(report, ("Game version:      %s"):format(gameVersion))
        table.insert(report, ("LOVE version:      %d.%d.%d (%s)"):format(love.getVersion()))
        table.insert(report, ("System name:       %s"):format(love.system.getOS()))
        table.insert(report, ("Graphics device:   %s (%s)"):format(rendererDevice, rendererVendor))
        table.insert(report, ("Graphics renderer: %s (%s)"):format(rendererName, rendererVersion))
        table.insert(report, ("Memory usage:      %.0f KiB\n"):format(collectgarbage("count")))
    end

    -- Add error message
    table.insert(report, "Error: \n    " .. message)
    table.insert(report, "\nTraceback:")

    -- Add traceback
    local trace = debug.traceback()
    for line in trace:gmatch("(.-)\n") do
        if line:match("boot.lua") then
            break;
        end
        if not line:match("Reporter.lua") and
           not line:match("stack traceback:") and
           not line:match("%[C%]:") then
            table.insert(report, line)
        end
    end

    -- Format result
    return table.concat(report, "\n"):gsub("\t", "    ") .. "\n"
end

-- Tests if LOVE and its necessary subsystems are initialized
local function checkLoveInitialized()
    -- Check love modules
    if not love.window or not love.graphics or not love.event then
        return false
    end

    -- Create window if it does not exists yet
    if not love.graphics.isCreated() or not love.window.isCreated() then
        if not pcall(love.window.setMode, 640, 480) then
            return false
        end
    end

    return true
end

-- Reset LOVE state for error handler
local function resetLoveState()
    -- Reset mouse state.
    if love.mouse then
        love.mouse.setVisible(true)
        love.mouse.setGrabbed(false)
    end

    -- Stop joystick vibrations
    if love.joystick then
        for i,v in ipairs(love.joystick.getJoysticks()) do
            v:setVibration()
        end
    end

    -- Stop music
    if love.audio then
        love.audio.stop()
    end

    -- Make bigger window if necessary
    local width, height, flags = love.window.getMode()
    if not flags.fullscreen and (width < 640 or height < 480) then
        love.window.setMode(640, 480)
    end

    -- Initialize rendering
    love.graphics.setCanvas()
    love.graphics.reset()
    love.graphics.setColor(255, 255, 255)
    love.graphics.clear()
    love.graphics.origin()
end

-- Main loop of the error handler
local function handlerLoop(initCallback, drawCallback)
    -- Check and initialization
    if checkLoveInitialized() then
        resetLoveState()
    else
        return
    end

    -- Custom initialization
    initCallback()

    -- Custom rendering function
    local function drawHandler()
        drawCallback()
        love.graphics.present()
    end

    -- Event loop
    drawHandler()
    while true do
        love.event.pump()

        for event, param in love.event.poll() do
            if event == "quit" then
                return
            end
            if event == "keypressed" and param == "escape" then
                return
            end
        end

        drawHandler()

        if love.timer then
            love.timer.sleep(0.1)
        end
    end
end

-- Debug error handler
local function debugErrorHandler(message)
    -- Write report to the standard output
    local report = createErrorReport(message)
    print(report)

    -- Render the report on the screen
    handlerLoop(function()
        love.graphics.setNewFont(12)
    end, function()
        love.graphics.clear(255, 0, 0)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(report, 8, 8)
        love.graphics.setColor(255, 255, 255)
        love.graphics.print(report, 8, 7)
    end)
end

-- Release error handler
local function releaseErrorHandler(message)
    local report = createErrorReport(message, true)

    -- Write report to log file
    local logFile = assert(io.open(logFileName, "w"))
    if errorReportURL then
        logFile:write("You can report this bug by posting the following information on ", errorReportURL, ".\n\n")
    end
    logFile:write(report)
    logFile:close()

    -- Generate message to display
    local message = "Oops! An error has occurred.\n\n\nLog was written to '" ..  logFileName .. "'."
    if errorReportURL then
        message = message .. "\n\nSee instructions inside this file if you'd like to report this bug."
    end

    -- Print the message also to the standard output
    print((message:gsub("\n\n+", "\n"))) -- Drop the second return value

    -- Add instructions how to quit
    message = message .. "\n\n\nPress [Esc] to quit."

    -- Rendering parameters
    local width, fontSize, border

    -- Render the message on the screen
    handlerLoop(function()
        width = love.window.getMode()
        fontSize = math.max(12, width / 40) -- Choose font size according to screen size
        border = 2 * fontSize
        love.graphics.setNewFont(fontSize)
    end, function()
        love.graphics.clear(255, 0, 0)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(message, border, border, width - 2 * border)
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf(message, border, border - 1, width - 2 * border)
    end)
end

-- Initializes reporting
function Reporter.init(config)
    -- Load configuration
    gameName = config.gameName or "???"
    gameVersion = config.gameVersion or "???"
    errorReportURL = config.errorReportURL
    logFileName = config.errorLog or "error.txt"

    -- Hook callbacks
    if config.debugMode then
        love.errhand = debugErrorHandler
    else
        love.errhand = releaseErrorHandler
    end
end

return Reporter
