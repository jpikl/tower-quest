-- Notify module
local Notify = {}

-- Variables
local gameWidth = 0
local fadeDuration = 0
local notifyDuration = 0
local notifyTime = 0
local notifyText = nil

-- Initializes notifications
function Notify.init(config)
    gameWidth = config.gameWidth or 800
    notifyDuration = config.notifyDuration or 1
    fadeDuration = config.notifyFadeDuration or notifyDuration / 3
end

-- Shows notification in top right corner of the screen
function Notify.set(text, duration)
    notifyText = text or ""
    notifyTime = (duration or notifyDuration) + fadeDuration
end

-- Hides current notification
function Notify.reset()
    notifyText = nil
    notifyTime = 0
end

-- Updates notification
function Notify.update(delta)
    if notifyTime > 0 then
        notifyTime = notifyTime - delta
    end
end

-- Draws notification
function Notify.draw()
    if notifyTime > 0 then
        local width = love.graphics.getFont():getWidth(notifyText)
        local alpha = math.min(255, notifyTime / fadeDuration * 255)
        love.graphics.setColor(255, 255, 255, alpha)
        love.graphics.print(notifyText, gameWidth - width - 10, 10)
    end
end

return Notify
