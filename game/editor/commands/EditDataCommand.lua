-- Dependencies
local Class  = require("engine.Class")

-- Level data edit command class
local EditDataCommand = Class("EditDataCommand")

-- Constructor
function EditDataCommand:EditDataCommand(level, x, y, value)
    self.level = level                  -- Level
    self.x = x                          -- Level x coordinate
    self.y = y                          -- Level y coordinate
    self.newValue = value               -- Value to set
    self.oldValue = level:getData(x, y) -- Backup of the old value
end

-- Cannot be executed when no changes are being made
function EditDataCommand:canExecute()
    return self.newValue ~= self.oldValue
end

-- Redoes level data change
function EditDataCommand:redo()
    self.level:setData(self.x, self.y, self.newValue)
end

-- Undoes level data change
function EditDataCommand:undo()
    self.level:setData(self.x, self.y, self.oldValue)
end

return EditDataCommand
