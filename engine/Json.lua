-- Dependencies
local DkJson = require("libraries.dkjson")

-- JSON module
local Json = {}

-- Encodes decoded data
function Json.encode(data)
    if data == nil then
        return nil, "No data to encode"
    else
        return DkJson.encode(data, { indent = true })
    end
end

-- Decodes encoded data
function Json.decode(data)
    if data == nil then
        return nil, "No data to decode"
    end
    local result, pos, error = DkJson.decode(data)
    if error then
        return nil, error
    else
        return result, nil
    end
end

-- Loads table from JSON file
function Json.load(file)
    local result, error = love.filesystem.read(file)
    if result then
        return Json.decode(result)
    else
        return nil, error
    end
end

-- Saves table to JSON file
function Json.save(file, data)
    local result, error = Json.encode(data)
    if result then
        return love.filesystem.write(file, result)
    else
        return nil, error
    end
end

-- Inherit all functions
return setmetatable(Json, { __index = DkJson })
