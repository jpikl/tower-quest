-- Dependencies
local Config = require("engine.Config")
local Log    = require("engine.Log")

-- Make default configuration
Config.init {
    loveVersion = "0.10.2",

    gameName = "Tower Quest",
    gameCode = "tower-quest",
    gameVersion = "0.11.1",
    gameWidth = 320,
    gameHeight = 240,

    debugMode = false,
    globalDeclarationsWarning = true,
    errorReportURL = "https://github.com/jpikl/tower-quest/issues",

    fullscreenMode = false,
    fullscreenMouseVisible = false,
    fullscreenType = "desktop",
    windowScale = 2,
    windowIcon = "graphics/icon.png",
    verticalSynch = true,
    frameRate = 60,

    audioVolume = 1.0,
    soundsVolume = 1.0,
    musicVolume = 0.5,

    imagesDirectory = "graphics",
    fontsDirectory = "graphics",
    soundsDirectory = "sounds",
    musicDirectory = "music",

    statesDirectory = "game.states",
    initialState = "Intro",

    transitionDuration = 1,
    audioFadeDuration = 0.3,
    notifyDuration = 1 / 2,
    notifyFadeDuration = 1 / 3,

    baseSpeed = 1.25,
    pushDelay = false,
    turboMode = false,

    controls = {
        -- Game inputs
        ["left"]    = { "k:left", "g:dpleft" },
        ["right"]   = { "k:right", "g:dpright" },
        ["up"]      = { "k:up", "g:dpup" },
        ["down"]    = { "k:down", "g:dpdown" },
        ["confirm"] = { "k:return", "k:space", "g:a" },
        ["cancel"]  = { "k:escape", "g:b", "g:back" },
        ["menu"]    = { "k:escape", "g:b", "g:start" },
        ["shot"]    = { "k:space", "g:a" },
        ["skip"]    = { "k:return", "k:space", "k:escape", "g:a", "g:b" },
        ["restart"] = { "k:r" },
        ["save"]    = { "k:s", "g:x" },
        ["load"]    = { "k:l", "g:y" },

        -- Editor inputs
        ["click"]       = { "k:space", "g:a", "m:left" },
        ["lock"]        = { "k:lctrl", "g:x", "m:right" },
        ["next"]        = { "k:down", "k:right", "k:tab", "g:dpdown", "g:dpright" },
        ["previous"]    = { "k:up", "k:left", "g:dpup", "g:dpleft" },
        ["scroll-up"]   = { "k:pageup", "g:leftshoulder", "m:wheelup" },
        ["scroll-down"] = { "k:pagedown", "g:rightshoulder", "m:wheeldown" },
        ["play"]        = { "k:f5", "g:y" },
    }
}

-- Configures LOVE
function love.conf(t)
    Log.info("Configuring...")
    -- Basic configuration
    Config.apply(t)
    -- Additional configuration
    t.window.width = 192
    t.window.height = 96
    t.modules.physics = false
    t.modules.touch = false
    t.modules.thread = false
end
