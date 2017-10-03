-- Dependencies
local Math   = require("engine.Math")
local Table  = require("engine.Table")
local String = require("engine.String")

-- Text input module
local TextInput = {}

-- Variables
local editingEnabled = false        -- Is editing in progress?
local editingMode = "single"        -- Editing mode (single/multi)
local editedText = ""               -- Input text
local cursorPosition = 0            -- Cursor position in input text
local cursorMovedCallback = nil     -- Called when cursor is moved
local textEditedCallback = nil      -- Called when text is edited
local editingFinishedCallback = nil -- Called when editing is finished
local moveUpCallback = nil          -- Called to compute cursor position when moving up
local moveDownCallback = nil        -- Called to compute cursor position when moving up

-- Processes key press event
local function keyPressed(key)
    local shiftDown = love.keyboard.isDown("lshift", "rshift")
    local ctrlDown =  love.keyboard.isDown("lctrl", "rctrl")

    if key == "left" then
        if ctrlDown then
            TextInput.movePrevWord()
        else
            TextInput.moveLeft()
        end
    elseif key == "right" then
        if ctrlDown then
            TextInput.moveNextWord()
        else
            TextInput.moveRight()
        end
    elseif key == "up" then
        TextInput.moveUp()
    elseif key == "down" then
        TextInput.moveDown()
    elseif key == "home" then
        if ctrlDown then
            TextInput.moveBeginning()
        else
            TextInput.movePrevLine()
        end
    elseif key == "end" then
        if ctrlDown then
            TextInput.moveEnd()
        else
            TextInput.moveNextLine()
        end
    elseif key == "return" then
        if editingMode == "multi" then
            TextInput.append("\n")
        else
            TextInput.stop()
        end
    elseif key == "escape" then
        TextInput.stop()
    elseif key == "backspace" then
        TextInput.removeLeft()
    elseif key == "delete" then
        TextInput.removeRight()
    elseif key == "v" and ctrlDown then
        local text = love.system.getClipboardText()
        if text then
            TextInput.append(text)
        end
    end
end

-- Processes key release event
local function keyReleased(key)
end

-- Process text input event
local function textEntered(text)
    TextInput.append(text)
end

-- Switches love.keypressed callback
local function switchKeyboardCallbacks()
    love.keypressed, keyPressed   = keyPressed, love.keypressed
    love.keyreleased, keyReleased = keyReleased, love.keyreleased
    love.textinput, textEntered = textEntered, love.textinput
end

-- Sets cursor position
function TextInput.setPosition(position)
    cursorPosition = Math.fit(position, 0, #editedText)
    if cursorMovedCallback then
        cursorMovedCallback(editedText, cursorPosition)
    end
end

-- Returns cursor position
function TextInput.getPosition()
    return cursorPosition
end

-- Moves cursor to the beginning
function TextInput.moveBeginning()
    TextInput.setPosition(0)
end

-- Moves cursor N characters left
function TextInput.moveLeft(count)
    TextInput.setPosition(cursorPosition - (count or 1))
end

-- Moves cursor N characters right
function TextInput.moveRight(count)
    TextInput.setPosition(cursorPosition + (count or 1))
end

-- Moves cursor left until one of characters is found
function TextInput.moveLeftUntil(...)
    local characters = Table.set { ... }
    local position = cursorPosition
    while not characters[editedText:sub(position, position)] and position > 0 do
        position = position - 1
    end
    TextInput.setPosition(position)
end

-- Moves cursor right until one of characters is found
function TextInput.moveRightUntil(...)
    local characters = Table.set { ... }
    local position = cursorPosition
    while not characters[editedText:sub(position + 1, position + 1)] and position < #editedText do
        position = position + 1
    end
    TextInput.setPosition(position)
end

-- Moves cursor one word left
function TextInput.movePrevWord()
    TextInput.moveLeft()
    TextInput.moveLeftUntil(" ", "\n")
end

-- Moves cursor one word right
function TextInput.moveNextWord()
    TextInput.moveRight()
    TextInput.moveRightUntil(" ", "\n")
end

-- Moves cursor one word left
function TextInput.movePrevLine()
    TextInput.moveLeftUntil("\n")
end

-- Moves cursor one word right
function TextInput.moveNextLine()
    TextInput.moveRightUntil("\n")
end

-- Moves cursor to the end
function TextInput.moveEnd()
    TextInput.setPosition(#editedText)
end

-- Moves cursor up (default behavior: one word left)
function TextInput.moveUp()
    if moveUpCallback and editingMode == "multi" then
        TextInput.setPosition(moveUpCallback(editedText, cursorPosition))
    else
        TextInput.movePrevWord()
    end
end

-- Moves cursor down (default behavior: one word right)
function TextInput.moveDown()
    if moveDownCallback and editingMode == "multi" then
        TextInput.setPosition(moveDownCallback(editedText, cursorPosition))
    else
        TextInput.moveNextWord()
    end
end

-- Modifies text near to the cursor
function TextInput.modify(leftDelta, insertedText, rightDelta)
    local prefixEnd = math.max(0, cursorPosition - leftDelta)
    local suffixStart = cursorPosition + rightDelta + 1
    local prefix = editedText:sub(0, prefixEnd)
    local suffix = editedText:sub(suffixStart, #editedText)
    insertedText = String.ascii(insertedText)
    editedText = prefix .. insertedText .. suffix
    TextInput.setPosition(cursorPosition + #insertedText - leftDelta)
    if textEditedCallback then
        textEditedCallback(editedText, cursorPosition)
    end
end

-- Removes N characters left to the cursor
function TextInput.removeLeft(count)
    TextInput.modify(count or 1, "", 0)
end

-- Removes N characters right to the cursor
function TextInput.removeRight(count)
    TextInput.modify(0, "", count or 1)
end

-- Adds text after the cursor
function TextInput.append(text)
    TextInput.modify(0, text, 0)
end

-- Replaces text after the cursor
function TextInput.replace(text)
    TextInput.modify(0, text, #text)
end

-- Returns edited text
function TextInput.getText()
    return editedText
end

-- Starts text input editing
function TextInput.start(config)
    if not editingEnabled then
        editingEnabled = true
        editedText = config.text or ""
        cursorPosition = config.position or #editedText
        editingMode = config.mode or "single"
        cursorMovedCallback = config.cursorMoved
        textEditedCallback = config.textEdited
        editingFinishedCallback = config.editingFinished
        moveUpCallback = config.moveUp
        moveDownCallback = config.moveDown
        switchKeyboardCallbacks()
    end
end

-- Stops text input editing
function TextInput.stop()
    if editingEnabled then
        editingEnabled = false
        switchKeyboardCallbacks()
        if editingFinishedCallback then
            editingFinishedCallback(editedText, cursorPosition)
        end
        cursorMovedCallback = nil
        textEditedCallback = nil
        editingFinishedCallback = nil
        moveUpCallback = nil
        moveDownCallback = nil
    end
end

-- Test if text input editing is enabled
function TextInput.isEnabled()
    return editingEnabled
end

return TextInput
