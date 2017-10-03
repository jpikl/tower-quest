-- Dependencies
local Assets    = require("engine.Assets")
local State     = require("engine.State")
local Table     = require("engine.Table")
local ActionBar = require("game.editor.layers.ActionBar")
local Layer     = require("game.editor.layers.Layer")
local ToolBar   = require("game.editor.layers.ToolBar")
local Editor    = require("game.states.Editor")
local Mapping   = require("game.Mapping")

-- UI Layer class
local UILayer = Layer:derive("UILayer")

-- Variables
local sprites = Assets.sprites.editor

-- Constructor
function UILayer:UILayer(width, height)
    self:Layer(width, height)          -- Call superclass constructor
    self.actionBar = ActionBar()       -- Bar of action buttons
    self.toolBar = ToolBar(height - 1) -- Bar of tool buttons

    -- Initialize both bars
    self:initActions()
    self:initTools()

    -- Listen for command stack changes
    Editor.getCommandStack():addListener(function(commandStack)
        self.actionBar:getButton("save").enabled = not commandStack:isMarkedAsSaved() or not Editor.isLevelOpened()
        self.actionBar:getButton("rename").enabled = Editor.isLevelOpened()
        self.actionBar:getButton("delete").enabled = Editor.isLevelOpened()
        self.actionBar:getButton("undo").enabled = commandStack:canUndo()
        self.actionBar:getButton("redo").enabled = commandStack:canRedo()
    end)
end

-- Initializes actions
function UILayer:initActions()
    local actionBar = self.actionBar

    -- File operations
    actionBar:addButton {
        id      = "new",
        tooltip = "Create new level",
        image   = sprites[2],
        redo    = Editor.newLevel
    }
    actionBar:addButton {
        id      = "open",
        tooltip = "Open level",
        image   = sprites[3],
        redo    = Editor.openLevel
    }
    actionBar:addButton {
        id      = "save",
        tooltip = "Save level",
        image   = sprites[4],
        redo    = Editor.saveLevel
    }
    actionBar:addButton {
        id      = "save-as",
        tooltip = "Save level as...",
        image   = sprites[5],
        redo    = Editor.saveLevelAs
    }
    actionBar:addButton {
        id      = "rename",
        tooltip = "Rename level",
        image   = sprites[6],
        redo    = Editor.renameLevel
    }
    actionBar:addButton {
        id      = "delete",
        tooltip = "Delete level",
        image   = sprites[7],
        redo    = Editor.deleteLevel
    }
    actionBar:addButton {
        id      = "quit",
        tooltip = "Quit editor",
        image   = sprites[8],
        redo    = Editor.quitEditor
    }

    -- Movement
    actionBar:addButton {
        id      = "left",
        tooltip = "Move left",
        image   = sprites[17],
        redo    = function() Editor.moveGrid("left") end
    }
    actionBar:addButton {
        id      = "up",
        tooltip = "Move up",
        image   = sprites[18],
        redo    = function() Editor.moveGrid("up") end
    }
    actionBar:addButton {
        id      = "center",
        tooltip = "Center view",
        image   = sprites[23],
        redo    = Editor.centerGrid
    }
    actionBar:addButton {
        id      = "down",
        tooltip = "Move down",
        image   = sprites[19],
        redo    = function() Editor.moveGrid("down") end
    }
    actionBar:addButton {
        id      = "right",
        tooltip = "Move right",
        image   = sprites[20],
        redo    = function() Editor.moveGrid("right") end
    }

    -- Editing
    actionBar:addButton {
        id      = "undo",
        tooltip = "Undo last action",
        image   = sprites[9],
        redo    = function() Editor.getCommandStack():undo() end
    }
    actionBar:addButton {
        id      = "redo",
        tooltip = "Redo undone action",
        image   = sprites[10],
        redo    = function() Editor.getCommandStack():redo() end
    }
    actionBar:addButton {
        id      = "play",
        tooltip = "Play level",
        image   = sprites[15],
        redo    = Editor.playLevel
    }
    actionBar:addButton {
        id      = "metadata",
        tooltip = "Edit level metadata",
        image   = sprites[14],
        redo    = Editor.editLevelMetadata
    }
    actionBar:addButton {
        id      = "grid",
        tooltip = "Toggle grid visibility",
        image   = sprites[13],
        redo    = function()
            local button = actionBar:getButton("grid")
            button.checked = not button.checked
            self.showGrid = not self.showGrid
        end
    }
    actionBar:addButton {
        id      = "clear",
        tooltip = "Clear level data",
        image   = sprites[12],
        redo    = function(self)
            self.data = Table.copy(Editor.getLevel().data)
            Editor.getLevel():clear()
        end,
        undo    = function(self)
            Editor.getLevel().data = self.data
        end
    }

    -- Others
    actionBar:addButton {
        id      = "fm",
        tooltip = "Open levels directory in file manager",
        image   = sprites[11],
        redo    = Editor.openFileManager
    }
    actionBar:addButton {
        id      = "help",
        tooltip = "Show help",
        image   = sprites[25],
        redo    = Editor.showHelp
    }
end

-- Initializes tools
function UILayer:initTools()
    local toolBar = self.toolBar
    for item in Mapping.getIterator() do
        toolBar:addButton {
            character = item.character,
            tooltip   = item.description,
            image     = item.image
        }
    end
    toolBar:updateScrollButtons()
end

-- Returns selected button
function UILayer:findButton(x, y)
    if y == 1 then
        return self.actionBar:getButton(x)
    elseif x == self.width then
        return self.toolBar:getButton(y - 1)
    end
end

-- Draws UI layer
function UILayer:draw()
    Layer.draw(self)

    local width = 16 * self.width
    local height = 16 * self.height

    -- Draw grid
    if self.showGrid then
        love.graphics.setColor(255, 255, 255, 48)
        for x = 0, width, 16 do
            love.graphics.line(x, 0, x, height)
        end
        for y = 16, height, 16 do
            love.graphics.line(0, y, width, y)
        end
        love.graphics.setColor(255, 255, 255)
    end

    -- Draw bars
    self.actionBar:draw(0, 0)
    self.toolBar:draw(width - 16, 16)
end

-- Processes cursor press event
function UILayer:cursorPressed(x, y)
    local button = self:findButton(x, y)
    if button then
        self.pressedButton = button
        button:press()
    else
        Layer.cursorPressed(self, x, y)
    end
end

-- Processes cursor release event
function UILayer:cursorReleased(x, y)
    local button = self.pressedButton
    if button then
        self.pressedButton = nil
        button:release()
    end
    Layer.cursorReleased(self, x, y)
end

-- Process cursor move event
function UILayer:cursorMoved(oldX, oldY, newX, newY)
    if self.selectedButton then
        self.selectedButton.selected = false
    end
    self.selectedButton = self:findButton(newX, newY)
    if self.selectedButton then
        self.selectedButton.selected = true
    end
    Layer.cursorMoved(self, oldX, oldY, newX, newY)
end

return UILayer
