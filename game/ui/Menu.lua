-- Dependencies
local Assets = require("engine.Assets")
local Class  = require("engine.Class")
local Config = require("engine.Config")

-- Menu class
local Menu = Class("Menu")

-- Variables
local sound = Assets.sounds.ui
local font = Assets.fonts.normal
local sprites = Assets.sprites.ui
local borderSize = 1.25 * font:getHeight()
local leftSpace = sprites[1].width + 2 * borderSize

-- Constructor
function Menu:Menu()
    self.visible = false                  -- Visibility
    self.maxVisibleSize = 99              -- Maximum visible items
    self.topItem = 1                      -- Top menu item
    self.selectedItem = 1                 -- Selected menu item
    self.backgroundColor = { 0, 0, 0, 0 } -- Background color
end

-- Shows menu
function Menu:show(reset)
    if reset then
        self.topItem = 1
        self.selectedItem = 1
    end
    self.visible = true
end

-- Closes menu and shows its parent when exists
function Menu:showParent()
    self:close()
    if self.parent then
        self.parent:show()
    end
end

-- Closes menu
function Menu:close()
    self.visible = false
end

-- Processes input press event
function Menu:inputPressed(input)
    -- Ignore input when menu is hidden
    if not self.visible then
        return false
    end

    -- Move upwards in the list
    if input:is("up") then
        if self.selectedItem > 1 then
            self.selectedItem = self.selectedItem - 1
            self.topItem = math.min(self.topItem, self.selectedItem)
        else
            self.selectedItem = self:getSize()
            self.topItem = math.max(self.topItem, self.selectedItem - self.maxVisibleSize + 1)
        end
        sound:play()
        return true
    -- Move downwards in the list
    elseif input:is("down") then
        if self.selectedItem < self:getSize() then
            self.selectedItem = self.selectedItem + 1
            self.topItem = math.max(self.topItem, self.selectedItem - self.maxVisibleSize + 1)
        else
            self.selectedItem = 1
            self.topItem = 1
        end
        sound:play()
        return true
    end
end

-- Draws menu
function Menu:draw()
    -- Skip drawing when menu is hidden
    if not self.visible then
        return
    end

    -- Compute width
    local menuWidth = 0
    for i = 1, self:getSize() do
        menuWidth = math.max(menuWidth, font:getWidth(self:getLabel(i)))
    end
    menuWidth = menuWidth + leftSpace + borderSize

    -- Compute height
    local itemHeight = font:getHeight()
    local spaceHeight = itemHeight / 2
    local lineHeight = itemHeight + spaceHeight
    local visibleItemsCount = math.min(self.maxVisibleSize, self:getSize())
    local menuHeight = visibleItemsCount * lineHeight - spaceHeight + 2 * borderSize

    -- Compute coordinates
    local menuX = (Config.gameWidth - menuWidth) / 2
    local menuY = (Config.gameHeight - menuHeight) / 2

    -- Draw background
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", menuX, menuY, menuWidth, menuHeight)

    -- Draw top and bottom arrow arrow
    love.graphics.setColor(255, 255, 255)
    local arrowX = menuX + (menuWidth - sprites[1].width) / 2
    if self.topItem ~= 1 then
        sprites[2]:draw(arrowX, menuY)
    end
    if self.topItem + visibleItemsCount <= self:getSize() then
        sprites[3]:draw(arrowX, menuY + menuHeight - sprites[3].height)
    end

    -- Draw list
    for i = 0, visibleItemsCount - 1 do
        local currentItem = self.topItem + i
        local x = menuX + leftSpace
        local y = menuY + borderSize + i * lineHeight
        love.graphics.print(self:getLabel(currentItem), x, y)
        -- Draw selection arrow
        if currentItem == self.selectedItem then
            local x = menuX + borderSize
            sprites[1]:draw( x, y)
        end
    end
end

return Menu
