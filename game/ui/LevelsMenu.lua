-- Dependencies
local File   = require("engine.File")
local Log    = require("engine.Log")
local State  = require("engine.State")
local Menu   = require("game.ui.Menu")
local Level  = require("game.Level")

-- Custom levels menu class
local LevelsMenu = Menu:derive("LevelsMenu")

-- Variables
local labelMaxLength = 24

-- Loads global instance
function LevelsMenu.load()
    LevelsMenu.customLevels = LevelsMenu("custom-levels")
end

-- Constructor
function LevelsMenu:LevelsMenu(directory)
    self:Menu()                -- Superclass constructor
    self.directory = directory -- Directory containing levels
    self:reload()              -- Load levels immediately
end

-- Loads level metadata
function LevelsMenu:reload()
    -- Clear previously loaded items
    love.busy()
    self.levels = {}

    -- Check if directory exists
    if not love.filesystem.exists(self.directory) then
        Log.info("Creating directory '%s'", self.directory)
        love.filesystem.createDirectory(self.directory)
        return
    end

    -- Process all levels
    Log.info("Searching levels in '%s'", self.directory)
    for i, file in ipairs(love.filesystem.getDirectoryItems(self.directory)) do
        local path = File.path(self.directory, file)
        if love.filesystem.isFile(path) and file:match('^.+%.lua$') then
            Log.info("Processing '%s'", file)
            local metadata, error = Level(path, "metadata")
            if metadata then
                local name = metadata.name or file
                if #name > labelMaxLength then
                    name = name:sub(1, labelMaxLength) .. "..." -- Truncate long names
                end
                table.insert(self.levels, { path = path, name = name })
            else
                Log.error(error)
            end
        end
    end
    table.sort(self.levels, function(a, b) return a.name:lower() < b.name:lower() end)

    -- Empty directory
    if #self.levels == 0 then
        Log.info("No levels found")
    end
end

-- Test if there are levels in the menu
function LevelsMenu:isEmpty()
    return #self.levels == 0
end

-- Returns item label
function LevelsMenu:getLabel(index)
    if index <= #self.levels then
        return self.levels[index].name
    else
        return "Back"
    end
end

-- Returns items count
function LevelsMenu:getSize()
    return #self.levels + 1
end

-- Process input press event
function LevelsMenu:inputPressed(input)
    -- Superclass implementation
    local result = Menu.inputPressed(self, input)
    if result ~= nil then
        return result
    end

    -- Process input
    if input:is("confirm") then
        local index = self.selectedItem
        if index > #self.levels then
            self:showParent()
        else
            State.switch("Game", "custom", self.levels[index].path)
            self:close()
        end
    elseif input:is("cancel", "menu") then
        self:showParent()
    end

    return true
end

return LevelsMenu
