-- Dependencies
local Class = require("engine.Class")
local Json  = require("engine.Json")
local Log   = require("engine.Log")
local Table = require("engine.Table")

-- Profile class
local Profile = Class("Profile")

-- Constructor
function Profile:Profile(fileName)
    self.fileName = fileName
    self:clear()
    if self:exists() then
        self:load()
    end
end

-- Clears profile data
function Profile:clear()
    self.name = nil
    self.levels = {}
end

-- Tests if profile exists
function Profile:exists()
    return love.filesystem.isFile(self.fileName)
end

-- Loads profile data from file
function Profile:load()
    Log.info("Loading profile from '%s'", self.fileName)
    local data, error = Json.load(self.fileName)
    if data then
        self.name = data.name
        self.levels = data.levels or {}
    else
        Log.error("Unable to load '%s': %s", self.fileName, error)
    end
end

-- Saves profile data to file
function Profile:save()
    Log.info("Saving profile '%s' to '%s'", self.name, self.fileName)
    local data = { name = self.name, levels = self.levels }
    local success, error = Json.save(self.fileName, data)
    if not success then
        Log.error("Unable to save '%s': %s", self.fileName, error)
    end
end

-- Deletes profile
function Profile:delete()
    Log.info("Deleting profile '%s' in '%s'", self.name, self.fileName)
    if not love.filesystem.remove(self.fileName) then
        Log.info("Unable to delete '%s'", self.fileName)
    end
    self:clear()
end

-- Returns profile name
function Profile:getName()
    return self.name
end

-- Sets profile name
function Profile:setName(name)
    self.name = name
end

-- Makes level ID from floor and room number
local function getLevelId(floor, room)
    return string.format("%02d-%d", floor, room)
end

-- Returns level data
function Profile:getLevel(floor, room)
    return self.levels[getLevelId(floor, room)]
end

-- Sets level data
function Profile:setLevel(floor, room, data)
    self.levels[getLevelId(floor, room)] = data
end

-- Updates level data
function Profile:updateLevel(floor, room, data)
    local newData = {}
    local oldData = self:getLevel(floor, room);
    if oldData then
        Table.merge(newData, oldData);
    end
    Table.merge(newData, data)
    self:setLevel(floor, room, newData)
end

-- Returns state from level data
function Profile:getLevelState(floor, room)
    local data = self:getLevel(floor, room)
    return data and data.state or "unknown"
end

-- Tests if level is unlocked
function Profile:isLevelUnlocked(floor, room)
    local state = self:getLevelState(floor, room);
    if state == "unlocked" or state == "completed" then
        return true
    elseif room < 4 then
        return floor == 1 or self:isLevelCompleted(floor - 1, 4)
    else
        return self:isLevelCompleted(floor, 1)
           and self:isLevelCompleted(floor, 2)
           and self:isLevelCompleted(floor, 3)
    end
end

-- Makes level unlocked
function Profile:unlockLevel(floor, room, cheated)
    if not self:isLevelCompleted(floor, room) then
        self:updateLevel(floor, room, { state = "unlocked", cheated = cheated or false })
    end
end

-- Tests if level is completed
function Profile:isLevelCompleted(floor, room)
    return self:getLevelState(floor, room) == "completed"
end

-- Makes level completed
function Profile:completeLevel(floor, room, cheated)
    self:updateLevel(floor, room, { state = "completed", cheated = cheated or false })
end

-- Returns number of completed levels
function Profile:getCompletedLevelsCount(maxFloor)
    local count = 0
    for floor = 1, maxFloor do
        for room = 1, 4 do
            if self:isLevelCompleted(floor, room) then
                count = count + 1
            end
        end
    end
    return count
end

-- Tests if every level is completed
function Profile:isEveryLevelCompleted(maxFloor)
    return self:getCompletedLevelsCount(maxFloor) == 4 * maxFloor
end

-- Tests if cheats were used for the specified level
function Profile:isLevelCheated(floor, room)
    local data = self:getLevel(floor, room)
    return data and data.cheated or false
end

-- Tests if cheats were used for any level
function Profile:isAnyLevelCheated(maxFloor)
    local count = 0
    for floor = 1, maxFloor do
        for room = 1, 4 do
            if self:isLevelCheated(floor, room) then
                return true
            end
        end
    end
    return false
end

return Profile
