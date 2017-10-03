-- Dependencies
local Animation   = require("engine.Animation")
local Log         = require("engine.Log")
local File        = require("engine.File")
local Function    = require("engine.Function")
local Sprite      = require("engine.Sprite")
local SpriteSheet = require("engine.SpriteSheet")
local Table       = require("engine.Table")

-- Assets module
local Assets = {}

-- Variables
local imageExtensions = Table.set { ".png", ".gif", ".jpg", ".jpeg" } -- Accepted image extensions
local imagesDirectory = nil -- Images base directory
local fontsDirectory = nil  -- Fonts base directory
local soundsDirectory = nil -- Sounds base directory
local musicDirectory = nil  -- Music base directory
local assetsFile = nil      -- Assets description file
local factories = {}        -- Factories for loading assets

-- Loads all assets
function Assets.load(config)
    local imageFilter = config.imageFilter or "nearest"
    love.graphics.setDefaultFilter(imageFilter, imageFilter)

    imagesDirectory = config.imagesDirectory or ""
    fontsDirectory = config.fontsDirectory or ""
    soundsDirectory = config.soundsDirectory or ""
    musicDirectory = config.musicDirectory or ""
    assetsFile = config.assetsFile or "assets.lua"

    local loadAssets = love.filesystem.load(assetsFile)
    local readOnlyEnv = setmetatable(factories, { __index = _G })
    local writableEnv = setmetatable(Assets, { __index = readOnlyEnv })
    setfenv(loadAssets, writableEnv)
    loadAssets()
end

-- Adds factory to creating assets
function Assets.addFactory(name, factory)
    factories[name] = factory
end

-- Wraps existing factory
function Assets.wrapFactory(name, factory)
    factories[name] = Function.around(factories[name], function(original, ...)
        return factory(original(...))
    end)
end

-- Add factory for loading images
Assets.addFactory("Image", function(file)
    local path = File.path(imagesDirectory, file)
    Log.info("Loading image '%s'", path)
    return love.graphics.newImage(path)
end)

-- Add factory for loading sprites
Assets.addFactory("Sprite", function(file, ...)
    local path = File.path(imagesDirectory, file)
    Log.info("Loading sprite '%s'", path)
    return Sprite(path, ...)
end)

-- Add factory for loading sprite sheets
Assets.addFactory("SpriteSheet", function(file, ...)
    local path = File.path(imagesDirectory, file)
    Log.info("Loading sprite sheet '%s'", path)
    return SpriteSheet(path, ...)
end)

-- Add factory for loading animations
Assets.addFactory("Animation", Animation)

-- Add factory for loading fonts
Assets.addFactory("Font", function(param1, param2)
    if type(param1) == "string" then
        local path = File.path(fontsDirectory, param1)
        Log.info("Loading font '%s'", path)
        if imageExtensions[path:sub(#path - 3)] then
            local image = love.graphics.newImage(path)
            return love.graphics.newImageFont(image, param2)
        else
            return love.graphics.newFont(path, param2 or 12)
        end
    else
        Log.info("Loading implicit font")
        return love.graphics.newFont(param1 or 12)
    end
end)

-- Add factory for loading sounds
Assets.addFactory("Sound", function(file, volume)
    local path = File.path(soundsDirectory, file)
    Log.info("Loading sound '%s'", path)
    local source = love.audio.newSource(path, "static")
    source:setVolume(volume or 1.0)
    return source
end)

-- Add factory for loading music
Assets.addFactory("Music", function(file, volume)
    local path = File.path(musicDirectory, file)
    Log.info("Loading music '%s'", path)
    local source = love.audio.newSource(path, "stream")
    source:setLooping(true)
    source:setVolume(volume or 1.0)
    return source
end)

return Assets
