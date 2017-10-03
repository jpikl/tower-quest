-- Dependencies
local Class = require("engine.Class")

-- Audio module
local Audio = {}

-- Variables
local soundsVolume = 1.0
local musicVolume = 1.0
local sounds = {}
local music = {}

-- Original source loader function
local newSource = love.audio.newSource

-- Source wrapper class
local SourceWrapper = Class("SourceWrapper")

-- Constructor
function SourceWrapper:SourceWrapper(fileName, type)
    self.source = newSource(fileName, type)
    self.localVolume = 1.0
    if type == "static" then
        self:setGlobalVolume(soundsVolume)
        table.insert(sounds, self)
    else
        self:setGlobalVolume(musicVolume)
        table.insert(music, self)
    end
end

-- Sets local volume
function SourceWrapper:setVolume(volume)
    self.localVolume = volume
    self.source:setVolume(self.globalVolume * self.localVolume)
end

-- Sets global volume
function SourceWrapper:setGlobalVolume(volume)
    self.globalVolume = volume
    self.source:setVolume(self.globalVolume * self.localVolume)
end

-- Create rest of the functions
for i, funcName in ipairs { "type", "typeOf", "getAttenuationDistances", "getChannels",
                            "getCone", "getDirection", "getType", "getPitch", "getPosition",
                            "getRolloff", "getVelocity", "getVolume", "getVolumeLimits",
                            "isLooping", "isPaused", "isPlaying", "isRelative",
                            "isStopped", "pause", "play", "resume", "rewind",
                            "seek", "setAttenuationDistances", "setDirection", "setCone",
                            "setLooping", "setPitch", "setPosition", "setRelative",
                            "setRolloff", "setVelocity", "setVolumeLimits", "stop", "tell" } do

    SourceWrapper[funcName] = function(self, ...)
        return self.source[funcName](self.source, ...)
    end
end

-- Applies sound volume to source wrappers
local function applyGlobalVolume(wrappers, volume)
    for i, wrapper in ipairs(wrappers) do
        wrapper:setGlobalVolume(volume)
    end
end

-- Hooks love.audio using custom source loader
function Audio.hook()
    love.audio.newSource = SourceWrapper
end

-- Initializes audio
function Audio.init(config)
    Audio.setVolume(config.audioVolume or 1.0)
    soundsVolume = config.soundsVolume or 1.0
    musicVolume = config.musicVolume or 1.0
    applyGlobalVolume(sounds, soundsVolume)
    applyGlobalVolume(music, musicVolume)
end

-- Sets master volume
function Audio.setVolume(volume)
    love.audio.setVolume(volume or 1.0)
end

-- Returns master volume
function Audio.getVolume()
    love.audio.getVolume()
end

-- Sets sounds volume
function Audio.setSoundsVolume(volume)
    soundsVolume = volume or 1.0
    applyGlobalVolume(sounds, volume)
end

-- Returns sounds volume
function Audio.getSoundsVolume()
    return soundsVolume
end

-- Sets master volume
function Audio.setMusicVolume(volume)
    musicVolume = volume or 1.0
    applyGlobalVolume(music, volume)
end

-- Returns master volume
function Audio.getMusicVolume()
    return musicVolume
end

return Audio
