-- Dependencies
local Assets              = require("engine.Assets")
local Config              = require("engine.Config")
local Log                 = require("engine.Log")
local Math                = require("engine.Math")
local Music               = require("engine.Music")
local State               = require("engine.State")
local Transition          = require("engine.Transition")
local Video               = require("engine.Video")
local CommandStack        = require("game.editor.commands.CommandStack")
local EditMetadataCommand = require("game.editor.commands.EditMetadataCommand")
local DialogFactory       = require("game.editor.dialog.DialogFactory")
local LevelsMenu          = require("game.ui.LevelsMenu")
local Level               = require("game.Level")

-- Editor module
local Editor = {}

-- Variables
local cursorX = 1                         -- Cursor X coordinate
local cursorY = 1                         -- Cursor Y coordinate
local mouseX = 1                          -- Mouse X coordinate
local mouseY = 1                          -- Mouse Y coordinate
local mouseDeltaX = 0                     -- Mouse X delta in grid movement mode
local mouseDeltaY = 0                     -- Mouse Y delta in grid movement mode
local mouseTimeout = 0                    -- Timeout to hide mouse cursor in fullscreen mode
local gridWidth = Config.gameWidth / 16   -- Editor grid width
local gridHeight = Config.gameHeight / 16 -- Editor grid height
local gridMovement = false                -- Is grid movement using cursor enabled
local showGrid = false                    -- Is grid displayed?
local sprites = Assets.sprites.editor    -- Editor sprites
local uiLayer, dataLayer = nil            -- Editor layers
local layerStack = nil                    -- Stack of layers
local commandStack = CommandStack()       -- Stack of commands
local openedFile = nil                    -- Current level file
local level = Level()                     -- Level data
local dialog = nil                        -- Dialog window

local instructions = [[
Cursor movement
   Mouse cursor / Cursor keys / D-Pad

Activate or use object
   Mouse LB / Space bar / Gamepad A

Lock cursor movement to editor grid
   Mouse RB / Left Ctrl / Gamepad X

Iterate between objects
   Mouse wheel / Pg Up & Down / Gamepad LB & RB

Play level
   F5  / Gamepad Y
]]


-- Creates layer and adds it to the stack
local function createLayer(name)
    local previousLayer = layerStack
    local layerClass = require("game.editor.layers." .. name)
    layerStack = layerClass(gridWidth, gridHeight)
    layerStack.nextLayer = previousLayer
    return layerStack
end

-- Initializes editor
function Editor.init()
    dataLayer = createLayer("DataLayer")
    uiLayer   = createLayer("UILayer")

    require("game.editor.layers.Button").setTooltipDrawingParameters {
        maxWidth = 200,
        padding = 8,
        margin = 8,
        left = 8,
        right = Config.gameWidth - 16,
        top = 16,
        bottom = Config.gameHeight
    }
end

-- Updates cursor position
local function updateCursorPosition(x, y, forceChange)
    -- Limit x coordinate
    x = Math.fit(x, 1, gridWidth)
    y = Math.fit(y, 1, gridHeight)

    -- Process change
    if forceChange or cursorX ~= x or cursorY ~= y then
        if gridMovement then
            -- Move grid instead of cursor
            dataLayer.xOffset = dataLayer.xOffset + x - cursorX
            dataLayer.yOffset = dataLayer.yOffset + y - cursorY
        else
            -- Send event to layers and update cursor location
            layerStack:cursorMoved(cursorX, cursorY, x, y)
            cursorX = x
            cursorY = y
        end
    end
end

-- Resets cursor position
local function resetCursorPosition()
    local mouseX, mouseY = Video.getMousePosition()
    local cursorX = math.floor(mouseX / 16) + 1
    local cursorY = math.floor(mouseY / 16) + 1
    updateCursorPosition(cursorX, cursorY, cursorX, cursorY)
end

-- Activates editor
function Editor.activate()
    Video.setFullscreenMouseVisible(true)
    Music.fadeOut()
    resetCursorPosition()
    commandStack:notifyListeners() -- To refresh some action buttons
end

-- Deactivates editor
function Editor.deactivate()
    Video.setFullscreenMouseVisible(false)
    LevelsMenu.customLevels:reload()
end

-- Updates editor
function Editor.update(delta)
    -- Destroy dialog when is closed
    if dialog and dialog.closed then
        dialog = nil
        resetCursorPosition()
    end

    -- Hide mouse in fullscreen mode when is not used for some time
    mouseTimeout = math.max(0, mouseTimeout - delta)
    if mouseTimeout == 0 then
        Video.setFullscreenMouseVisible(false)
    end

    -- Get new mouse position
    local oldMouseX, oldMouseY = mouseX, mouseY
    mouseX, mouseY = Video.getMousePosition()

    -- Check if mouse is active
    if mouseX ~= oldMouseX or mouseY ~= oldMouseY then
        -- Refresh timeout and show mouse
        mouseTimeout = 5
        Video.setFullscreenMouseVisible(true)

        -- Update cursor position or move grid when dialog is not visible
        if dialog then
            dialog:mouseMoved(oldMouseX, oldMouseY, mouseX, mouseY)
        elseif gridMovement then
            mouseDeltaX = mouseDeltaX + mouseX - oldMouseX
            mouseDeltaY = mouseDeltaY + mouseY - oldMouseY
            local cursorDeltaX = math.floor(mouseDeltaX / 16)
            local cursorDeltaY = math.floor(mouseDeltaY / 16)
            mouseDeltaX = mouseDeltaX - 16 * cursorDeltaX
            mouseDeltaY = mouseDeltaY - 16 * cursorDeltaY
            updateCursorPosition(cursorX - cursorDeltaX, cursorY - cursorDeltaY)
        else
            local newCursorX = math.floor(mouseX / 16) + 1
            local newCursorY = math.floor(mouseY / 16) + 1
            updateCursorPosition(newCursorX, newCursorY)
        end
    end
end

-- Draws editor
function Editor.draw()
    -- Draw layers
    layerStack:draw()

    -- Draw cursor when dialog is not visible
    if dialog then
        dialog:draw()
    else
        local cursorDrawX = 16 * (cursorX - 1)
        local cursorDrawY = 16 * (cursorY - 1)
        sprites[1]:draw( cursorDrawX, cursorDrawY)
    end
end

-- Processes input press event
function Editor.inputPressed(input)
    -- Process input or forward it to the dialog
    if dialog then
        dialog:inputPressed(input)
    elseif input:is("left") then
        updateCursorPosition(cursorX == 1 and gridWidth or cursorX - 1, cursorY)
    elseif input:is("right") then
        updateCursorPosition(cursorX == gridWidth and 1 or cursorX + 1, cursorY)
    elseif input:is("up") then
        updateCursorPosition(cursorX, cursorY == 1 and gridHeight or cursorY - 1)
    elseif input:is("down") then
        updateCursorPosition(cursorX, cursorY == gridHeight and 1 or cursorY + 1)
    elseif input:is("click") then
        layerStack:cursorPressed(cursorX, cursorY)
    elseif input:is("lock") then
        gridMovement = true
        mouseDeltaX = 0
        mouseDeltaY = 0
        love.mouse.setGrabbed(true)
        Video.setMouseVisible(false)
    elseif input:is("scroll-up") then
        uiLayer.toolBar:scrollUp()
        updateCursorPosition(cursorX, cursorY, true) -- To refresh selected button
    elseif input:is("scroll-down") then
        uiLayer.toolBar:scrollDown()
        updateCursorPosition(cursorX, cursorY, true) -- To refresh selected button
    elseif input:is("play") then
        Editor.playLevel()
    end
end

-- Processes input release event
function Editor.inputReleased(input)
    -- Process input or forward it to the dialog
    if dialog then
        dialog:inputReleased(input)
    elseif input:is("click") then
        layerStack:cursorReleased(cursorX, cursorY)
    elseif input:is("lock") then
        gridMovement = false
        love.mouse.setGrabbed(false)
        Video.setMouseVisible(true)
    end
end

-- Returns level data
function Editor.getLevel()
    return level
end

-- Returns command stack
function Editor.getCommandStack()
    return commandStack
end

-- Returns cursor position
function Editor.getCursorPosition()
    return cursorX, cursorY
end

-- Returns selected tool for drawing
function Editor.getSelectedTool()
    return uiLayer.toolBar.selectedTool
end

-- Checks if tooltips are enabled
function Editor.areTooltipsEnabled()
    return dialog == nil and not Transition.isRunning()
end

-- Requires confirmation before executing action if some changes were made
local function executeUnsafeAction(action)
    if not commandStack:isMarkedAsSaved() then
        dialog = DialogFactory.createQuestion("Discard unsaved changes?", action)
    else
        action()
    end
end

-- Creates new level
function Editor.newLevel()
    executeUnsafeAction(function()
        openedFile = nil
        level:clear()
        commandStack:clear() -- Must be called right after level is cleared
    end)
end

-- Opens level
function Editor.openLevel()
    executeUnsafeAction(function()
        dialog = DialogFactory.createFileSelector("Open level:", function(file)
            local result, error = Level(file, "lenient")
            if error then
                Log.error(error)
                dialog = DialogFactory.createMessage("Unable to open " .. file:match("[^/]*$"))
            else
                openedFile = file
                level = result
                commandStack:clear()
                Editor.centerGrid()
            end
        end)
    end)
end

-- Checks if a level is opened
function Editor.isLevelOpened()
    return openedFile ~= nil
end

-- Saves level
function Editor.saveLevel()
    if openedFile then
        level.version = Config.gameVersion
        level:save(openedFile)
        commandStack:markAsSaved()
    else
        Editor.saveLevelAs()
    end
end

-- Saves level as
function Editor.saveLevelAs()
    dialog = DialogFactory.createFileSelector("Save level as:", function(file)
        openedFile = file
        Editor.saveLevel()
    end)
end

-- Renames level
function Editor.renameLevel()
    dialog = DialogFactory.createFileSelector("Rename level to:", function(file)
        love.filesystem.remove(openedFile)
        openedFile = file
        Editor.saveLevel()
    end)
end

-- Deletes current level
function Editor.deleteLevel()
    dialog = DialogFactory.createQuestion("Delete current level?", function()
        love.filesystem.remove(openedFile)
        openedFile = nil
        level:clear()
        commandStack:clear()
    end)
end

-- Quits editor
function Editor.quitEditor()
    executeUnsafeAction(function()
        openedFile = nil
        level:clear()
        commandStack:clear()
        State.switch("Title")
    end)
end

-- Moves editing area
function Editor.moveGrid(direction)
    if direction == "left" then
        dataLayer.xOffset = dataLayer.xOffset - 1
    elseif direction == "right" then
        dataLayer.xOffset = dataLayer.xOffset + 1
    elseif direction == "up" then
        dataLayer.yOffset = dataLayer.yOffset - 1
    elseif direction == "down" then
        dataLayer.yOffset = dataLayer.yOffset + 1
    end
end

-- Centers editing area
function Editor.centerGrid()
    local left, right, top, bottom = level:getBorders()
    local width = right - left
    local height = bottom - top
    dataLayer.xOffset = left - math.floor((gridWidth - width) / 2)
    dataLayer.yOffset = top - math.floor((gridHeight - height) / 2) - 1
end

-- Starts level
function Editor.playLevel()
    State.switch("Game", "editor", level)
end

-- Opens dialog to edit level metadata
function Editor.editLevelMetadata()
    dialog = DialogFactory.createMetadataEditor(level, function(name, author, message)
        local command = EditMetadataCommand(level, name, author, message)
        commandStack:execute(command)
    end)
end

-- Opens levels directory in file manager
function Editor.openFileManager()
    -- Switch to window mode
    Config.fullscreenMode = false
    Video.setFullscreenMode(false)

    -- Open directory in file manager
    love.system.openURL("file://" .. love.filesystem.getSaveDirectory() .. "/custom-levels")
end

-- Shows editor instructions
function Editor.showHelp()
    dialog = DialogFactory.createFullscreenMessage(instructions)
end

return Editor
