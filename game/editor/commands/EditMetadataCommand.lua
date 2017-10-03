-- Dependencies
local Class  = require("engine.Class")

-- Level metadata edit command class
local EditMetadataCommand = Class("EditMetadataCommand")

-- Constructor
function EditMetadataCommand:EditMetadataCommand(level, name, author, message)
    self.level = level
    self.oldName = level.name
    self.oldAuthor = level.author
    self.oldMessage = level.message
    self.newName = name ~= "" and name or nil
    self.newAuthor = author ~= "" and author or nil
    self.newMessage = message ~= "" and message or nil
end

-- Cannot be executed when no changes are being made
function EditMetadataCommand:canExecute()
    return self.newName ~= self.oldName or
           self.newAuthor ~= self.oldAuthor or
           self.newMessage ~= self.oldMessage
end

-- Redoes level metadata change
function EditMetadataCommand:redo()
    self.level.name = self.newName
    self.level.author = self.newAuthor
    self.level.message = self.newMessage
end

-- Undoes level metadata change
function EditMetadataCommand:undo()
    self.level.name = self.oldName
    self.level.author = self.oldAuthor
    self.level.message = self.oMessage
end

return EditMetadataCommand
