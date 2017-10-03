-- Dependencies
local Class    = require("engine.Class")
local Config   = require("engine.Config")
local Video    = require("engine.Video")
local Renderer = require("game.editor.Renderer")

-- Dialog class
local Dialog = Class("Dialog")

-- Constructor
function Dialog:Dialog(width, height)
    self.x = (Config.gameWidth - width) / 2    -- X drawing coordinate
    self.y = (Config.gameHeight - height) / 2  -- Y drawing coordinate
    self.width = width                         -- Dialog width
    self.height = height                       -- Dialog height
    self.widgets = {}                          -- All dialog widgets
    self.selection = 0                         -- Index of selected widget
end

-- Adds widget to dialog
function Dialog:add(widget)
    table.insert(self.widgets, widget)
    widget.x = self.x + widget.x -- Move widget relative to dialog
    widget.y = self.y + widget.y
    return widget
end

-- Changes selection on the next/previous widget
function Dialog:changeSelection(delta)
    local widgets = self.widgets
    local selection = self.selection
    local selectedWidget = nil

    repeat
        selection = selection + delta
        if selection > #widgets then
            selection = 1
        elseif selection <= 0 then
            selection = #widgets
        end
        selectedWidget = widgets[selection]
    until selectedWidget.selectable or selection == self.selection

    self:setSelection(selection)
end

-- Sets selected widget
function Dialog:setSelection(selection)
    local selectedWidget = self:getSelectedWidget()
    if selectedWidget then
        selectedWidget.selected = false
    end
    self.selection = selection
    selectedWidget = self:getSelectedWidget()
    if selectedWidget then
        selectedWidget.selected = true
    end
end

-- Returns selected widget
function Dialog:getSelectedWidget()
    return self.widgets[self.selection]
end

-- Sets active widget
function Dialog:setActiveWidget(widget)
    if self.activeWidget and self.activeWidget.active then
        self.activeWidget:deactivate()
    end
    self.activeWidget = widget
    if self.activeWidget then
        self.activeWidget:activate()
    end
end

-- Returns active widget
function Dialog:getActiveWidget()
    -- Check first if the widget deactivated itself
    if self.activeWidget and not self.activeWidget.active then
        self.activeWidget = nil
    end
    return self.activeWidget
end

-- Draws dialog
function Dialog:draw()
    -- Draw background
    Renderer.drawFrame(self.x, self.y, self.width, self.height, "fill1", "border1")

    -- Draw widgets
    for i, widget in ipairs(self.widgets) do
        widget:draw()
    end
end

-- Updates dialog
function Dialog:mouseMoved(oldX, oldY, newX, newY)
    -- Send event to active widget
    local activeWidget = self:getActiveWidget()
    if activeWidget and activeWidget.mouseMoved then
        activeWidget:mouseMoved(oldX, oldY, newX, newY)
    end

    -- Select widget under mouse cursor
    for i, widget in ipairs(self.widgets) do
        if widget:containsPoint(newX, newY) then
            self:setSelection(i)
            return
        end
    end

    -- Select nothing
    self:setSelection(0)
end

-- Processes input press event
function Dialog:inputPressed(input)
    -- Find active and selected widget
    local activeWidget = self:getActiveWidget()
    local selectedWidget = self:getSelectedWidget()

    -- Some widget is active
    if activeWidget then
        -- Deactivate widget if user clicked somewhere else
        if input:is("click") and not input:is("confirm") then
            if not activeWidget:containsPoint(Video.getMousePosition()) then
                self:setActiveWidget(nil)
                -- Do not return here, so mouse can activate another widget
            end
        else
            -- Send input or deactivate widget
            if input:is("cancel") then
                self:setActiveWidget(nil)
            else
                activeWidget:inputPressed(input)
            end
            return
        end
    end

    -- Update selection or close dialog
    if input:is("cancel") then
        self.closed = true
    elseif input:is("next")then
        self:changeSelection(1)
    elseif input:is("previous")then
        self:changeSelection(-1)
    elseif selectedWidget then
        -- Activate selected widget
        if selectedWidget ~= activeWidget and input:is("confirm", "click") then
            self:setActiveWidget(selectedWidget)
            if not input:is("confirm") then
                selectedWidget:inputPressed(input) -- Real mouse click
            end
        else
            selectedWidget:inputPressed(input)
        end
    end
end

-- Processes input release event
function Dialog:inputReleased(input)
    local targetWidget = self:getActiveWidget() or self:getSelectedWidget()
    if targetWidget then
        targetWidget:inputReleased(input)
    end
end

return Dialog
