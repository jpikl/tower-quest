-- Dependencies
local Assets      = require("engine.Assets")
local Config      = require("engine.Config")
local File        = require("engine.File")
local Button      = require("game.editor.dialog.Button")
local Dialog      = require("game.editor.dialog.Dialog")
local FileBrowser = require("game.editor.dialog.FileBrowser")
local Input       = require("game.editor.dialog.Input")
local Label       = require("game.editor.dialog.Label")
local Scroller    = require("game.editor.dialog.Scroller")

-- Dialog factory module
local DialogFactory = {}

-- Creates scroll bar for the specified part
local function createScrollBar(dialog, target, x, y, width, height)
    local upImage = Assets.sprites.editor[21]
    local downImage = Assets.sprites.editor[22]
    dialog:add(Button(upImage, x, y, width, width, function()
        target:scrollUp()
    end))
    dialog:add(Scroller(target, x, y + width + 1, width, height - 2 * width - 2))
    dialog:add(Button(downImage, x, y + height - width, width, width, function()
        target:scrollDown()
    end))
end

-- Creates message dialog
function DialogFactory.createMessage(message, closeCaption, width, height)
    closeCaption = closeCaption or "OK"
    width = width or 256
    height = height or 96
    local dialog = Dialog(width, height)
    dialog:add(Label(message, 16, 16, width - 32))
    dialog:add(Button(closeCaption, width - 64, height - 36, 48, 20, function()
        dialog.closed = true
    end))
    dialog:setSelection(2) -- Select close button as default
    return dialog
end

-- Creates fullscreen message dialog
function DialogFactory.createFullscreenMessage(message)
    return DialogFactory.createMessage(message, "Back", Config.gameWidth, Config.gameHeight)
end

-- Creates question dialog
function DialogFactory.createQuestion(message, yesCallback, noCallback)
    local dialog = Dialog(200, 96)
    dialog:add(Label(message, 16, 16, 168))
    dialog:add(Button("Yes", 32, 60, 48, 20, function()
        if yesCallback then yesCallback() end
        dialog.closed = true
    end))
    dialog:add(Button("No", 120, 60, 48, 20, function()
        if noCallback then noCallback() end
        dialog.closed = true
    end))
    dialog:setSelection(3) -- Select No button as default
    return dialog
end

-- Creates metadata editor dialog
function DialogFactory.createMetadataEditor(level, callback)
    local dialog = Dialog(256, 228)
    local nameInput = dialog:add(Input("single", level.name, 68, 16, 172, 20, 6))
    local authorInput = dialog:add(Input("single", level.author, 68, 45, 172, 20, 6))
    local messageInput = dialog:add(Input("multi", level.message, 16, 96, 207, 76, 6))
    createScrollBar(dialog, messageInput, 224, 96, 16, 76)
    dialog:add(Label("Name:", 28, 23))
    dialog:add(Label("Author:", 18, 52))
    dialog:add(Label("Message:", 18, 80))
    dialog:add(Button("OK", 32, 192, 48, 20, function()
        callback(nameInput.text, authorInput.text, messageInput.text)
        dialog.closed = true
    end))
    dialog:add(Button("Cancel", 160, 192, 64, 20, function()
        dialog.closed = true
    end))
    dialog:setSelection(1) -- Select name input as default
    return dialog
end

-- Create file selection dialog
function DialogFactory.createFileSelector(message, callback)
    local directory = "custom-levels"
    local pattern = "^(.*%.lua)$"
    local dialog = Dialog(256, 196)
    local fileInput = Input("single", nil, 48, 120, 192, 20, 6)
    local fileBrowser = FileBrowser(directory, pattern, 16, 38, 207, 64, function(file)
        fileInput.text = file or ""
    end)
    dialog:add(Label(message, 16, 16, 208))
    dialog:add(fileBrowser)
    createScrollBar(dialog, fileBrowser, 224, 38, 16, 64)
    dialog:add(fileInput)
    dialog:add(Label("File:", 16, 126))
    dialog:add(Button("OK", 32, 160, 48, 20, function()
        local file = fileInput.text
        if file ~= "" then
            if not file:match(pattern) then
                file = file .. ".lua"
            end
            callback(File.path(directory, file))
            dialog.closed = true
        end
    end))
    dialog:add(Button("Cancel", 160, 160, 64, 20, function()
        dialog.closed = true
    end))
    dialog:setSelection(2) -- Select file browser as default
    return dialog
end

return DialogFactory
