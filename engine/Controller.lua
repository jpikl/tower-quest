-- Dependencies
local Function = require("engine.Function")
local Log      = require("engine.Log")

-- Controller module
local Controller = {}

-- Variables
local suspendedFrames = 0           -- Number of frames event processing is suspended
local keyboardToInput = {}          -- Mapping of keyboard keys to virtual inputs
local inputToKeyboard = {}          -- Inverse mapping for keyboard
local mouseToInput = {}             -- Mapping of mouse buttons to virtual inputs
local inputToMouse = {}             -- Inverse mapping for keyboard
local gamepadToInput = {}           -- Mapping of gamepad buttons to virtual inputs
local inputToGamepad = {}           -- Inverse mapping for gamepad
local unmappedInputsEnabled = false -- Allows to send events for unmapped inputs

-- Clears module state and all mappings
function Controller.clear()
    keyboardToInput = {}
    gamepadToInput = {}
    mouseToInput = {}
    inputToKeyboard = {}
    inputToGamepad = {}
    inputToMouse = {}
end

function Controller.init(config)
    -- Clear module state
    Controller.clear()
    -- Initialize configuration
    unmappedInputsEnabled = config.unmappedInputsEnabled == true

    -- Initialize mappings
    for input, mapping in pairs(config.controls or {}) do
        if type(mapping) == "table" then
            Controller.bind(input, unpack(mapping))
        elseif type(mapping) == "string" then
            Controller.bind(input, mapping)
        else
            Log.error("Incorrect mapping '%s'", mapping)
        end
    end
end

-- Translates keyboard scan code
local function translateKeyboard(scancode)
    return scancode
end

-- Translates mouse button number
local function translateMouse(button)
    if button == "left" then
        return 1
    elseif button == "right" then
        return 2
    elseif button == "middle" then
        return 3
    else
        return tonumber(button) or button
    end
end

-- Translates gamepad button code
local function translateGamepad(button)
    return button
end

-- Binds virtual input to one or more real inputs
function Controller.bind(input, ...)
    for i, mapping in ipairs { ... } do
        local type, button = mapping:match("(.):(.*)")
        if type == "k" then
            Controller.bindKeyboard(input, translateKeyboard(button))
        elseif type == "m" then
            Controller.bindMouse(input, translateMouse(button))
        elseif type == "g" then
            Controller.bindGamepad(input, translateGamepad(button))
        else
            Log.error("Unknown type of device '%s'", type)
        end
    end
end

-- Adds mapping of virtual input to one or more device inputs
local function bindDevice(deviceToInput, inputToDevice, input, ...)
    if not inputToDevice[input] then
        inputToDevice[input] = {}
    end
    for i, button in ipairs { ... } do
        if not deviceToInput[button] then
            deviceToInput[button] = {}
        end
        deviceToInput[button][input] = true
        inputToDevice[input][button] = true
    end
end

-- Binds virtual input to one or more keyboard keys
function Controller.bindKeyboard(input, ...)
    bindDevice(keyboardToInput, inputToKeyboard, input, ...)
end

-- Binds virtual input to one or more mouse buttons
function Controller.bindMouse(input, ...)
    bindDevice(mouseToInput, inputToMouse, input, ...)
end

-- Binds virtual input to one or more gamepad buttons
function Controller.bindGamepad(input, ...)
    bindDevice(gamepadToInput, inputToGamepad, input, ...)
end

-- Compares input with a string
local function compareInput(input, ...)
    for i, name in pairs { ... } do
        if input.data[name] then
            return true
        end
    end
    return false
end

-- Creates input
local function createInput(data, value)
    return {
        data = data,
        value = value,
        is = compareInput
    }
end

-- Sends input event
local function fireInputChanged(callback, mapping, button)
    if suspendedFrames == 0 and callback then
        local data = mapping[button]
        if data then
            callback(createInput(data, button))
        elseif unmappedInputsEnabled then
            callback(createInput({}, button))
        end
    end
end

-- Handles key press event
function Controller.keyPressed(key, scancode, isRepeat)
    if not isRepeat then
        fireInputChanged(Controller.inputPressed, keyboardToInput, scancode)
    end
end

-- Handles key release event
function Controller.keyReleased(key, scancode)
    fireInputChanged(Controller.inputReleased, keyboardToInput, scancode)
end

-- Handles mouse press event
function Controller.mousePressed(x, y, button)
    fireInputChanged(Controller.inputPressed, mouseToInput, button)
end

-- Handles mouse release event
function Controller.mouseReleased(x, y, button)
    fireInputChanged(Controller.inputReleased, mouseToInput, button)
end

-- Handles mouse wheel event
function Controller.mouseWheelMoved(x, y)
    local yAbs = math.abs(y)
    if yAbs > 0 then
        local button = y > 0 and "wheelup" or "wheeldown"
        for i = 1, yAbs do
            fireInputChanged(Controller.inputPressed, mouseToInput, button)
        end
    end
end

-- Handles gamepad press event
function Controller.gamepadPressed(joystick, button)
    fireInputChanged(Controller.inputPressed, gamepadToInput, button)
end

-- Handles gamepad release event
function Controller.gamepadReleased(joystick, button)
    fireInputChanged(Controller.inputReleased, gamepadToInput, button)
end

-- Tests if some keyboard keys mapped to the specified input are down
local function isKeyboardDown(input)
    for scancode in pairs(inputToKeyboard[input] or {}) do
        if love.keyboard.isScancodeDown(scancode) then
            return true
        end
    end
    return false
end

-- Tests if some mouse buttons mapped to the specified input are down
local function isMouseDown(input)
    for button in pairs(inputToMouse[input] or {}) do
        if love.mouse.isDown(button) then
            return true
        end
    end
    return false
end

-- Tests if some gamepad buttons to the specified input are down
local function isGamepadDown(input)
    for button in pairs(inputToGamepad[input] or {}) do
        for i, joystick in ipairs(love.joystick.getJoysticks()) do
            if joystick:isGamepad() then
                if joystick:isGamepadDown(button) then
                    return true
                end
            end
        end
    end
    return false
end

-- Tests if at least one of inputs is down
function Controller.isDown(...)
    for i, input in ipairs { ... } do
        if isKeyboardDown(input) or isMouseDown(input) or isGamepadDown(input) then
            return true
        end
    end
    return false
end

-- Updates controller
function Controller.update()
    if suspendedFrames > 0 then
        suspendedFrames = suspendedFrames - 1
    end
end

local function temporarilySuspend()
    suspendedFrames = 2
end

-- Hooks controller to love callbacks
function Controller.hook()
    -- Device callbacks
    love.keypressed = Controller.keyPressed
    love.keyreleased = Controller.keyReleased
    love.mousepressed = Controller.mousePressed
    love.mousereleased = Controller.mouseReleased
    love.wheelmoved = Controller.mouseWheelMoved
    love.gamepadpressed = Controller.gamepadPressed
    love.gamepadreleased = Controller.gamepadReleased

    -- Window mode/fullscreen change causes unwanted input event repetition
    love.window.setMode = Function.after(love.window.setMode, temporarilySuspend)
    love.window.setFullscreen = Function.after(love.window.setFullscreen, temporarilySuspend)
end

return Controller
