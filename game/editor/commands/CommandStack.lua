-- Dependencies
local Class = require("engine.Class")

-- Command stack class
local CommandStack = Class("CommandStack")

-- Constructor
function CommandStack:CommandStack()
    self.listeners = {}
end

-- Executes commands and inserts it onto stack
function CommandStack:execute(command)
    -- Drop inexecutable commands
    if command.canExecute and not command:canExecute() then
        return
    end

    -- Insert and execute command
    if self.prevCommand then
        self.prevCommand.next = command
        command.prev = self.prevCommand
    end
    self.prevCommand = command
    self.nextCommand = nil
    command:redo()
    self:notifyListeners()
end

-- Clears command stack
function CommandStack:clear()
    self.prevCommand = nil
    self.nextCommand = nil
    self.saveMark = nil
    self:notifyListeners()
end

-- Tests if last executed command can be undone
function CommandStack:canUndo()
    return self.prevCommand ~= nil
end

-- Tests if last undone command can redone
function CommandStack:canRedo()
    return self.nextCommand ~= nil
end

-- Undoes last executed command
function CommandStack:undo()
    local command = self.prevCommand
    if command then
        self.prevCommand = command.prev
        self.nextCommand = command
        command:undo()
        self:notifyListeners()
    end
end

-- Redoes last undone command
function CommandStack:redo()
    local command = self.nextCommand
    if command then
        self.nextCommand = command.next
        self.prevCommand = command
        command:redo()
        self:notifyListeners()
    end
end

-- Marks current stack position as saved
function CommandStack:markAsSaved()
    self.saveMark = self.prevCommand
    self:notifyListeners()
end

-- Tests if current stack position is marked as saved
function CommandStack:isMarkedAsSaved()
    return self.saveMark == self.prevCommand
end

-- Adds command stack listener
function CommandStack:addListener(listener)
    table.insert(self.listeners, listener)
end

-- Notifies all command stack listeners
function CommandStack:notifyListeners()
    for i, listener in ipairs(self.listeners) do
        listener(self)
    end
end

return CommandStack
