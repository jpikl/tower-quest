-- Dependencies
local Class   = require("engine.Class")
local Config  = require("engine.Config")
local String  = require("engine.String")
local Table   = require("engine.Table")
local Version = require("engine.Version")
local Mapping = require("game.Mapping")

-- Level class
local Level = Class("Level")

-- Constructor
function Level:Level(fileName, mode)
    if fileName then
        return self:load(fileName, mode)
    else
        self:clear()
    end
end

-- Returns level width
function Level:getWidth()
    return self.data[1] and #self.data[1] or 0
end

-- Returns level height
function Level:getHeight()
    return #self.data
end

-- Returns level borders
function Level:getBorders()
    local inf = 1 / 0
    local left, right = inf, -inf
    local top, bottom = inf, -inf

    -- Decide level border coordinates
    for y, row in pairs(self.data) do
        for x, value in pairs(row) do
            local class = Mapping.getClass(value)
            if class and value ~= Mapping.getWall() then
                left = math.min(left, x)
                right = math.max(right, x)
                top = math.min(top, y)
                bottom = math.max(bottom, y)
            end
        end
    end

    if left == inf then
        return 0, 0, 0, 0
    else
        return left - 1, right + 1, top - 1, bottom + 1
    end
end

-- Sets level data field
function Level:setData(x, y, value)
    local row = self.data[y]
    if not row then
        row = {}
        self.data[y] = row
    end
    row[x] = value
end

-- Returns level data field
function Level:getData(x, y)
    local row = self.data[y]
    return row and row[x] or Mapping.getWall()
end

-- Returns normalized data
function Level:getNormalizedData()
    local left, right, top, bottom = self:getBorders()
    local normalizedData = {}
    for y = top, bottom do
        local newY = y - top + 1
        normalizedData[newY] = {}
        for x = left, right do
            local newX = x - left + 1
            normalizedData[newY][newX] = self:getData(x, y)
        end
    end
    return normalizedData
end

-- Normalizes level data
function Level:normalize()
    self.data = self:getNormalizedData()
end

-- Clears level data
function Level:clear()
    self.data = {}
    self.name = nil
    self.author = nil
    self.message = nil
end

-- Validates level
function Level:validate()
    return self:validateVersion()
        or self:validatePlayer()
end

-- Validates level version
function Level:validateVersion()
    local gameVersion = Version(Config.gameVersion, 2)
    local requiredVersion = Version(self.version, 2)
    if gameVersion < requiredVersion then
        return ("Game version '%s' is lower than required '%s'"):format(gameVersion, requiredVersion)
    end
    return nil
end

-- Validate player existence
function Level:validatePlayer()
    for i, row in pairs(self.data) do
        for j, value in pairs(row) do
            local class = Mapping.getClass(value)
            if class:is("Player") then
                return nil
            end
        end
    end
    return "Missing player"
end

-- Loads level from file
function Level:load(fileName, mode)
    love.busy()

    -- Check file existence
    if type(fileName) ~= "string" then
        return "No file name specified"
    elseif not love.filesystem.isFile(fileName) then
        return ("File '%s' not found"):format(fileName)
    end

    -- Load file as Lua chunk
    local success, chunk = pcall(love.filesystem.load, fileName)
    if not success then
        return chunk
    end

    -- Isolate chunk execution
    setfenv(chunk, {})

    -- Execute chunk
    local success, content = pcall(chunk)
    if not success then
        return ("Evaluation error: %s"):format(content)
    elseif type(content) ~= "table" then
        return ("File '%s' has invalid content"):format(fileName)
    end

    -- Clear current level
    self:clear()

    -- Copy metadata
    self.name = content.name
    self.version = content.version
    self.author = content.author

    -- Parse message and data
    if mode ~= "metadata" then
        -- Parse message
        self.message = String.normalize(content.message, "paragraphs")

        -- Parse data
        local data = content.data or ""
        for line in data:gmatch("[^\r\n]+") do
            local row = line:match("^%s*(.-)%s*$")
            if row then
                local y = #self.data + 1
                self.data[y] = {}
                for x = 1, #row do
                    self.data[y][x] = row:sub(x, x)
                end
            end
        end

        -- Validate level
        if mode == "lenient" then
            return self:validateVersion()
        elseif self:getHeight() == 0 then
            return "Missing level data"
        else
            return self:validate()
        end
    end
end

function Level:save(fileName)
    -- Open file
    local file = love.filesystem.newFile(fileName, "w")
    if not file then
        return ("Unable to open '%s'"):format(fileName)
    end

    -- Write start
    file:write("return {\n")

    -- Write medatada
    if self.name then
        file:write("  name = \"" .. self.name .. "\",\n")
    end
    if self.author then
        file:write("  author = \"" .. self.author .. "\",\n")
    end
    if self.version then
        file:write("  version = \"" .. self.version .. "\",\n")
    end

    -- Write message
    if self.message then
        file:write("  message = [[\n")
        local message = self.message:match("^%s*(.-)%s*$")
        for i, line in ipairs(String.wrap(message, 80)) do
            file:write("    " .. line:match("^%s*(.-)%s*$") .. "\n")
        end
        file:write("  ]],\n")
    end

    -- Write data
    file:write("  data = [[\n")
    for i, row in ipairs(self:getNormalizedData()) do
        file:write("    ")
        for j, value in ipairs(row) do
            file:write(value or Mapping.getWall())
        end
        file:write("\n")
    end
    file:write("  ]],\n")

    -- Write end and close the file
    file:write("}\n")
    file:close()
end

-- Returns background sprite on the specified position
function Level:getBackgroundSprite(x, y)
    local tl = self:getData(x - 1, y - 1)
    local tc = self:getData(x,     y - 1)
    local tr = self:getData(x + 1, y - 1)
    local cl = self:getData(x - 1, y)
    local cc = self:getData(x,     y)
    local cr = self:getData(x + 1, y)
    local bl = self:getData(x - 1, y + 1)
    local bc = self:getData(x,     y + 1)
    local br = self:getData(x + 1, y + 1)

    local classes = {}
    local parameters = {}

    classes.tl, parameters.tl = Mapping.getClass(tl)
    classes.tc, parameters.tc = Mapping.getClass(tc)
    classes.tr, parameters.tr = Mapping.getClass(tr)
    classes.cl, parameters.cl = Mapping.getClass(cl)
    classes.cc, parameters.cc = Mapping.getClass(cc)
    classes.cr, parameters.cr = Mapping.getClass(cr)
    classes.bl, parameters.bl = Mapping.getClass(bl)
    classes.bc, parameters.bc = Mapping.getClass(bc)
    classes.br, parameters.br = Mapping.getClass(br)

    return classes.cc.getBackgroundSprite(classes, parameters)
end

return Level
