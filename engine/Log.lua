-- Log module
local Log = {}

-- Variables
local handlers = {}
local defaultCallLevel = 4
local callLevel = defaultCallLevel

local logLevels = {
    none = 0,
    fatal = 1,
    error = 2,
    warn = 3,
    info = 4,
    debug = 5,
    all = 5
}

-- Empty function
local function doNothing()
end

-- Increases call level for the next log call
local function increaseCallLevel(value)
    callLevel = callLevel + (value or 1)
end

-- Creates logger function
local function createLogger(type)
    return function(message, ...)
        for i, handler in ipairs(handlers) do
            handler(type, message, ...)
        end
        callLevel = defaultCallLevel
    end
end

-- Returns logger function or none if it is disabled
local function getLogger(currentLevel, requiredLevel, logger)
    currentLevel = logLevels[currentLevel] or logLevels.none
    requiredLevel = logLevels[requiredLevel]

    if currentLevel >= requiredLevel then
        return logger
    else
        return doNothing
    end
end

-- Loggers for different levels
local logFatal = createLogger("F")
local logError = createLogger("E")
local logWarn = createLogger("W")
local logInfo = createLogger("I")
local logDebug = createLogger("D")

-- Sets logging level
function Log.setLevel(level)
    Log.increaseCallLevel = getLogger(level, "fatal", increaseCallLevel)
    Log.fatal = getLogger(level, "fatal", logFatal)
    Log.error = getLogger(level, "error", logError)
    Log.warn = getLogger(level, "warn", logWarn)
    Log.info = getLogger(level, "info", logInfo)
    Log.debug = getLogger(level, "debug", logDebug)
end

-- Sets logging handlers
function Log.setHandler(...)
    handlers = { ... }
end

-- Creates default log output
local function createOutput(type, message, ...)
    local info = debug.getinfo(callLevel, "Snl")
    local time = os.date("%Y-%m-%d-%H:%M:%S")
    local file = info.short_src
    local line = info.currentline
    local body = message or ""
    return ("[%s][%s][%s:%d] " .. body):format(type, time, file, line, ...)
end

-- Console log handler
function Log.console(type, message, ...)
    print(createOutput(type, message, ...))
end

-- Returns file log handler
function Log.file(fileName)
    local file = io.open(fileName, "w")
    if file then
        return function(type, message, ...)
            file:write(createOutput(type, message, ...))
            file:write("\n")
        end
    else
        return doNothing
    end
end

-- Initializes logging
function Log.init(config)
    -- Setup logging
    if config.logLevel then
        Log.setLevel(config.logLevel)
    else
        Log.setLevel(config.debugMode and "all" or "none")
    end

    -- Setup logging output
    if config.logFile then
        Log.setHandler(Log.console, Log.file(config.logFile))
    else
        Log.setHandler(Log.console)
    end
end

-- Logging is disabled by default
Log.setLevel("none")
Log.setHandler(Log.console)

return Log
