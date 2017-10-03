-- Dependencies
local Json   = require("engine.Json")
local Log    = require("engine.Log")
local String = require("engine.String")
local Table  = require("engine.Table")

-- Config module
local Config = {}

-- Variables
local fileConfig = {}
local consoleConfig = {}

-- Initializes configuration
function Config.init(defaultConfig)
    -- Setup configuration hierarchy
    setmetatable(fileConfig, { __index = defaultConfig })
    setmetatable(consoleConfig, { __index = fileConfig })
    setmetatable(Config, { __index = consoleConfig })

    -- Process command line arguments
    Config.readArguments(arg or {})

    -- Initialize logging
    Log.init(Config)

    -- Log declarations of global variables if enabled
    if Config.globalDeclarationsWarning then
        setmetatable(_G, {
            __newindex = function(table, key, value)
                Log.increaseCallLevel()
                Log.warn("Declaration of global variable '%s'", key)
                rawset(table, key, value)
            end
        })
    end
end

-- Reads command line arguments
function Config.readArguments(args)
    -- Each argument is pair (key=value)
    for i = 2, #args do
        local arg = args[i]
        -- Argument with a value
        local key, value = arg:match("^%-?%-?(%S.-)=(%S+)$")
        if key and value then
            consoleConfig[key] = String.parse(value)
        else
            -- Flag argument
            key = arg:match("^%-?%-?(%S.+)$")
            if key then
                consoleConfig[key] = true
            end
        end
    end
end

-- Loads configuration from file
function Config.load()
    local file = Config.configFile or "config.json"
    if love.filesystem.isFile(file) then
        Log.info("Loading configuration '%s'", file)
        local data, message = Json.load(file)
        if data then
            if type(data) == "table" then
                Table.merge(Config, data)
            else
                Log.warn("File '%s' does not contain configuration data", file)
            end
        else
            Log.error("Unable to load '%s': %s", file, message)
        end
    end
end

-- Saves configuration to file
function Config.save()
    local file = Config.configFile or "config.json"
    Log.info("Saving configuration '%s'", file)
    local data = Table.copy(Config, "data")
    local success, error = Json.save(file, data)
    if not success then
        Log.error("Unable to save '%s': %s", file, error)
    end
end

-- Creates basic LOVE configuration
function Config.apply(t)
    -- Get window title
    local windowTitle = Config.gameName or t.title
    if Config.gameVersion then
        windowTitle = windowTitle .. " " .. Config.gameVersion
    end
    if Config.debugMode then
        windowTitle = windowTitle .. " (debug mode)"
    end

    -- Fill LOVE configuration table
    t.title = windowTitle
    t.author = Config.authorName or t.author
    t.url = Config.gameURL or t.url
    t.identity = Config.gameCode or t.identity
    t.version = Config.loveVersion or t.version
    t.console = Config.debugMode == true
    t.window.width = Config.gameWidth or t.window.width
    t.window.height = Config.gameHeight or t.window.height
    t.window.icon = Config.windowIcon or t.window.icon
    t.window.fullscreen = false
    t.window.vsync = Config.verticalSynch ~= false
end

return Config
