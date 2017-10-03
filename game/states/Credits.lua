-- Dependencies
local Assets     = require("engine.Assets")
local Config     = require("engine.Config")
local Music      = require("engine.Music")
local State      = require("engine.State")
local Transition = require("engine.Transition")

-- Credits state
local Credits = {}

-- Variables
local foreground = Assets.images.creditsFg
local timeout = 0

local image = Assets.images.lovePowered
local imageX = 0
local imageY = 0
local imageTargetY = 0

local textY = 0
local textHeight = 0
local text = [[
PROGRAMMING

evilnote4d


LIBRARIES

LOVE by rude and others
ProFi by Luke Perkin
dkjson by David Kolf


GRAPHICS

Stephen Challener
CharlesGabriel
Blarumyrran
MrBeast
Bart Kelsey
AngryMeteor.com
Arachne
Anakreon
GuiChan Library Fonts
Tango Icon Library
evilnote4d


MUSIC & SOUNDS

abundant-music generator
as3sfxr generator


LEVEL DESIGN

evilnote4d
]]

-- Activates credits
function Credits.activate()
    local font = love.graphics.getFont()
    local _, wrappedText = font:getWrap(text, Config.gameWidth)

    timeout = 2
    textY = Config.gameHeight + 10
    textHeight = 9 * font:getLineHeight() * #wrappedText

    imageX = (Config.gameWidth - image:getWidth()) / 2
    imageY = textY + textHeight + 80
    imageTargetY = (Config.gameHeight - image:getHeight()) / 2

    Music.fadeIn(Assets.music.credits)
end

-- Draws credits
function Credits.draw()
    love.graphics.printf(text, 0, textY, Config.gameWidth, "center")
    love.graphics.draw(image, imageX, imageY)
    love.graphics.draw(foreground)
end

-- Updates credits
function Credits.update(delta)
    local posDelta = 20 * delta
    textY = textY - posDelta
    imageY = math.max(imageY - posDelta, imageTargetY)

    if imageY == imageTargetY then
        timeout = timeout - delta
        if not Transition.isRunning() and timeout <= 0 then
            State.switch("Title")
        end
    end
end

-- Processes input press event
function Credits.inputPressed(input)
    if not Transition.isRunning() and input:is("skip") then
        State.switch("Title")
    end
end

return Credits
