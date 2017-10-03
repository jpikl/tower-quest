-- Dependencies
local Log = require("engine.Log")

-- Video module
local Video = {}

-- Variables
local gameWidth = 0
local gameHeight = 0
local screenWidth = 0
local screenHeight = 0
local screenScale = 1
local viewX = 0
local viewY = 0
local viewWidth = 0
local viewHeight = 0
local viewScale = 1
local windowScale = 1
local fullscreenMode = nil
local fullscreenType = nil
local verticalSynch = true
local mouseVisible = true
local fullscreenMouseVisible = false

-- Updates mouse cursor visibility
local function updateMouseVisibility()
    if fullscreenMode then
        love.mouse.setVisible(mouseVisible and fullscreenMouseVisible)
    else
        love.mouse.setVisible(mouseVisible)
    end
end

-- Initializes video
function Video.init(config)
    -- Print renderer info
    local rendererName, rendererVersion,
          rendererVendor, rendererDevice = love.graphics.getRendererInfo()
    Log.info("Graphics device: %s (%s)", rendererDevice, rendererVendor)
    Log.info("Graphics renderer: %s (%s)", rendererName, rendererVersion)

    -- Get screen resolution
    screenWidth, screenHeight = love.window.getDesktopDimensions()
    Log.info("Screen resolution: %dx%d", screenWidth, screenHeight)

    -- Get game resolution
    gameWidth = config.gameWidth or 800
    gameHeight = config.gameHeight or 600

    -- Get scale for the fullscreen mode
    local scaleX = screenWidth / gameWidth
    local scaleY = screenHeight / gameHeight
    screenScale = math.floor(math.min(scaleX, scaleY))

    -- Set video mode
    fullscreenType = config.fullscreenType or "desktop"
    verticalSynch = config.verticalSynch ~= false -- Makes 'true' the default value
    mouseVisible = config.mouseVisible ~= false
    fullscreenMouseVisible = config.fullscreenMouseVisible ~= false
    Video.setVideoMode(config.fullscreenMode, config.windowScale or 1)

    -- Set line rough style
    love.graphics.setLineStyle("rough")
    love.graphics.setLineJoin("miter")
end

-- Initializes drawing
function Video.beginDrawing()
    love.graphics.translate(viewX, viewY)
    love.graphics.scale(viewScale, viewScale)
    love.graphics.setColor(255, 255, 255)
end

-- Finishes drawing
function Video.endDrawing()
    -- May be used later (canvas & shaders)
end

-- Sets video mode
function Video.setVideoMode(fullscreen, scale)
    -- Ignore invalid requests
    if fullscreen == fullscreenMode and scale == windowScale then
        return
    end

    Log.info("Setting video mode (fullscreen=%s, scale=%d)", fullscreen, scale)

    -- Save new settings
    windowScale = scale
    if fullscreenMode and fullscreen then
        return -- Window scale change has no effect in fullscreen mode
    end
    fullscreenMode = fullscreen

    if fullscreenMode then
        -- Setup fullscreen mode
        viewWidth = screenScale * gameWidth
        viewHeight = screenScale * gameHeight
        viewX = (screenWidth - viewWidth) / 2
        viewY = (screenHeight - viewHeight) / 2
        viewScale = screenScale
        love.window.setMode(screenWidth, screenHeight, {
            fullscreen = true,
            fullscreentype = fullscreenType,
            vsync = verticalSynch
        })

        -- Clear possible artifacts in both frame buffers
        love.graphics.setScissor(0, 0, screenWidth, screenHeight)
        love.graphics.clear()
        love.graphics.present() -- Swap frame buffers
        love.graphics.clear()
    else
        -- Setup Window mode
        viewWidth = windowScale * gameWidth
        viewHeight = windowScale * gameHeight
        viewX, viewY = 0, 0
        viewScale = windowScale
        love.window.setMode(viewWidth, viewHeight, {
            fullscreen = false,
            vsync = verticalSynch
        })
    end

    -- Update mouse cursor
    updateMouseVisibility()
    -- Clip area
    love.graphics.setScissor(viewX, viewY, viewWidth, viewHeight)
end

-- Sets window scale
function Video.setWindowScale(scale)
    Video.setVideoMode(fullscreenMode, scale)
end

-- Returns current window scale
function Video.getWindowScale()
    return windowScale
end

-- Returns the biggest supported window scale
function Video.getMaxWindowScale()
    return screenScale
end

-- Sets fullscreen mode
function Video.setFullscreenMode(fullscreen)
    Video.setVideoMode(fullscreen, windowScale)
end

-- Returns whether is fullscreen mode
function Video.isFullscreenMode()
    return fullscreenMode
end

-- Sets mouse visible in fullscreen mode
function Video.setFullscreenMouseVisible(visible)
    fullscreenMouseVisible = visible
    updateMouseVisibility()
end

-- Sets mouse visible
function Video.setMouseVisible(visible)
    mouseVisible = visible
    updateMouseVisibility()
end

-- Returns mouse position
function Video.getMousePosition()
    local mouseX, mouseY = love.mouse.getPosition()
    local x = (mouseX - viewX) / viewScale
    local y = (mouseY - viewY) / viewScale
    return x, y
end

-- Sets mouse position
function Video.setMousePosition(x, y)
    local mouseX = viewX + x * viewScale
    local mouseY = viewY + y * viewScale
    love.mouse.setPosition(mouseX, mouseY)
end

return Video
