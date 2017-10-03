-- Dependencies
local Controller = require("engine.Controller")
local File       = require("engine.File")
local Function   = require("engine.Function")
local Log        = require("engine.Log")
local Transition = require("engine.Transition")

-- State module
local State = {}

-- Variables
local statesPrefix = nil
local currentState = nil
local loadedStates = {}
local skipNextUpdate = false

-- Initializes states
function State.init(config)
    -- Load configuration
    statesPrefix = File.prefix(config.statesDirectory)
    -- Set initial state if specified
    if config.initialState then
        State.set(config.initialState)
    end
end

-- Sets state
function State.set(stateName, ...)
    -- Deactivates the previous state
    if currentState and currentState.deactivate then
        Log.info("Deactivating state '%s'", loadedStates[currentState])
        currentState.deactivate()
    end

    -- Loads the new state
    Log.info("Setting state to '%s'", stateName)
    currentState = require(statesPrefix .. stateName)

    -- Initialize controls for the new state
    Controller.inputPressed = currentState.inputPressed
    Controller.inputReleased = currentState.inputReleased

    -- Initialize the new state
    if currentState.init and not loadedStates[currentState] then
        Log.info("Initializing state '%s'", stateName)
        loadedStates[currentState] = stateName
        currentState.init()
    end

    -- Activate the new state
    if currentState.activate then
        Log.info("Activating state '%s'", stateName)
        currentState.activate(...)
    end
end

-- Switches game state with transition
function State.switch(stateName, ...)
    Transition.start(Function.bind(State.set, stateName, ...))
end

-- Destroyes states
function State.quit()
    for state, stateName in pairs(loadedStates) do
        if state.quit then
            Log.info("Destroying state '%s'", stateName)
            state.quit()
        end
    end
end

-- Create rest of functions
for i, callbackName in ipairs { "draw", "update", "keyPressed", "keyReleased",
                                "joystickPressed", "joystickReleased",
                                "mousePressed", "mouseReleased" } do

    State[callbackName] = function(...)
        if currentState and currentState[callbackName] then
            currentState[callbackName](...)
        end
    end
end

return State
