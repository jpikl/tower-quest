-- Dependencies
local Menu = require("game.ui.Menu")

-- Generic menu class
local GenericMenu = Menu:derive("GenericMenu")

-- Constructor
function GenericMenu:GenericMenu()
    self:Menu()            -- Superclass constructor
    self.items = {}        -- Menu items
    self.closeable = true  -- Can be closed?
end

-- Adds menu item
function GenericMenu:addItem(label, callback)
    table.insert(self.items, {
        label = label,
        enabled = true,
        callback = callback or function() end
    })
end

-- Sets item enabled or disabled
function GenericMenu:setItemEnabled(index, enabled)
    self.items[index].enabled = enabled
end

-- Returns enabled item on the specified index
function GenericMenu:getItem(index)
    local current = 0
    for i, item in ipairs(self.items) do
        if item.enabled then
            current = current + 1
            if current == index then
                return item
            end
        end
    end
end

-- Returns item label
function GenericMenu:getLabel(index)
    local item = self:getItem(index)
    return item and item.label
end

-- Returns items count
function GenericMenu:getSize()
    local size = 0
    for i, item in ipairs(self.items) do
        if item.enabled then
            size = size + 1
        end
    end
    return size
end

-- Process input press event
function GenericMenu:inputPressed(input)
    -- Superclass implementation
    local result = Menu.inputPressed(self, input)
    if result ~= nil then
        return result
    end

    -- Process input
    if input:is("confirm") then
        self:getItem(self.selectedItem).callback()
        self:close()
    elseif input:is("cancel", "menu") then
        if self.closeable then
            self:showParent()
        end
    end

    return true
end

return GenericMenu
