-- Dependencies
local Assets = require("engine.Assets")
local Audio  = require("engine.Audio")
local Config = require("engine.Config")
local Math   = require("engine.Math")
local State  = require("engine.State")
local Video  = require("engine.Video")
local Menu   = require("game.ui.Menu")

-- Settings menu class
local SettingsMenu = Menu:derive("SettingsMenu")

-- Variables
local sound = Assets.sounds.ui

-- Returns boolean value label
local function getBooleanValueLabel(name, value)
    return string.format("%s: %s", name, value and "on" or "off")
end

-- Returns multiplier value label
local function getMultiplierValueLabel(name, value)
    return string.format("%s: %dx", name, value)
end

-- Returns percentage value label
local function getPercentageValueLabel(name, value)
    return string.format("%s: %d%%", name, 100 * value)
end

-- Returns item label
function SettingsMenu:getLabel(index)
    if index == 1 then
        return getBooleanValueLabel("Fullscreen", Config.fullscreenMode)
    elseif index == 2 then
        return getMultiplierValueLabel("Window scale", Config.windowScale)
    elseif index == 3 then
        return getBooleanValueLabel("Push delay", Config.pushDelay)
    elseif index == 4 then
        return getBooleanValueLabel("Turbo mode", Config.turboMode)
    elseif index == 5 then
        return getPercentageValueLabel("SFX volume", Config.soundsVolume)
    elseif index == 6 then
        return getPercentageValueLabel("Music volume", Config.musicVolume)
    elseif index == 7 then
        return "Back"
    end
end

-- Returns items count
function SettingsMenu:getSize()
    return 7
end

-- Add percentage amount to volume value
local function addVolumePercentage(volume, increment)
    local percentage = math.floor(100 * volume); -- Converting to integer prevents rounding errors
    local newVolume = (percentage + increment) / 100;
    return Math.fit(newVolume, 0, 1);
end

-- Process input press event
function SettingsMenu:inputPressed(input)
    -- Superclass implementation
    local result = Menu.inputPressed(self, input)
    if result ~= nil then
        return result
    end

    -- Process input
    local index = self.selectedItem
    if input:is("confirm", "left", "right") then
        if index == 1 then
            Config.fullscreenMode = not Config.fullscreenMode
            Video.setFullscreenMode(Config.fullscreenMode)
        elseif index == 2 then
            if input:is("left") then
                Config.windowScale = Config.windowScale - 1
                if Config.windowScale == 0 then
                    Config.windowScale = Video.getMaxWindowScale()
                end
            else
                Config.windowScale = Config.windowScale + 1
                if Config.windowScale > Video.getMaxWindowScale() then
                    Config.windowScale = 1
                end

            end
            Video.setWindowScale(Config.windowScale)
        elseif index == 3 then
            Config.pushDelay = not Config.pushDelay
        elseif index == 4 then
            Config.turboMode = not Config.turboMode
        elseif index == 5 then
            local increment = input:is("right") and 5 or -5
            Config.soundsVolume = addVolumePercentage(Config.soundsVolume, increment)
            Audio.setSoundsVolume(Config.soundsVolume)
            sound:play() -- Show sound loudness
        elseif index == 6 then
            local increment = input:is("right") and 5 or -5
            Config.musicVolume = addVolumePercentage(Config.musicVolume, increment)
            Audio.setMusicVolume(Config.musicVolume)
        elseif index == 7 then
            if input:is("confirm") then
                self:showParent()
            end
        end
    elseif input:is("cancel", "menu") then
        self:showParent()
    end

    return true
end

return SettingsMenu
