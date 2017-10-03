-- String module
local String = {}

-- Removes all non-ascii characters from string
function String.ascii(text)
    if not text then
        return nil
    end
    local output = {}
    for i = 1, #text do
        if text:byte(i) < 128 then
            output[#output + 1] = text:sub(i, i)
        end
    end
    return table.concat(output)
end

-- Makes first character upper case
function String.capitalize(text)
    if text and #text > 0 then
        return text:sub(1, 1):upper() .. text:sub(2)
    else
        return text
    end
end

-- Creates value from string
function String.parse(text)
    if text == "true" then
        return true
    elseif text == "false" then
        return false
    elseif tonumber(text) then
        return tonumber(text)
    else
        return text
    end
end

-- Splits string
function String.split(text, delimiter)
    local result = {}
    if delimiter then
        local pattern = ("([^%s]*)%s"):format(delimiter, delimiter)
        for part in (text .. delimiter):gmatch(pattern) do
            result[#result + 1] = part
        end
    else
        for i = 1, #text do
            result[i] = text:sub(i, i)
        end
    end
    return result
end

-- Trims string
function String.trim(text)
    if text then
        return text:gsub("^%s*(.-)%s*$", "%1")
    end
    return text
end

-- Normalizes text using specified modes
function String.normalize(text, ...)
    if not text then
        return nil
    end

    local mode, otherModes = ...
    if mode == nil then
        return text
    elseif mode == "newlines" then
        text = text:gsub("\r\n", "\n") -- Normalize Windows newlines
        text = text:gsub("\r", "\n")   -- Normalize Mac newlines
    elseif mode == "whitespaces" then
        text = text:gsub("%s+", " ")
    elseif mode == "paragraphs" then
        text = String.trim(text)
        text = text:gsub("[\t ]*\n[\t ]*", "\n")      -- Delete empty line borders
        text = text:gsub("([^\n])\n([^\n])", "%1 %2") -- Delete single newlines
        text = text:gsub("\n\n+", "\n\n")             -- Delete redundant newlines
        text = text:gsub("[\t ]+", " ")               -- Delete redundant spaces and tabs
    end

    return String.normalize(text, otherModes)
end

-- Determines text length
local function defaultMetric(text)
    return #text
end

-- Wraps text to array of lines
function String.wrap(text, maxWidth, metric, mode)
    if not text then
        return {}
    end

    maxWidth = maxWidth or 1 / 0
    metric = metric or defaultMetric

    local lines = {}
    local start = 1
    local stop = 0
    local width = 0

    for i = 1, #text do
        local char = text:sub(i, i)
        if char == "\n" then
            local j = mode == "keep-newlines" and i or i - 1
            lines[#lines + 1] = text:sub(start, j)
            start = i + 1
            stop = i
            width = 0
        else
            width = width + metric(char)
            local nextChar = text:sub(i + 1, i + 1)
            if char == " " or nextChar == " " or nextChar == "\n" or nextChar == "" then
                if width > maxWidth and not (char == " " and nextChar ~= " ") then
                    local part = text:sub(start, stop)
                    if part ~= "" then
                        lines[#lines + 1] = part
                        start = stop + 1
                        width = width - metric(part)
                    end
                end
                stop = i
            end
        end
    end

    lines[#lines + 1] = text:sub(start)
    return lines
end

-- Creates new string
function String:new(value)
    return setmetatable(value or "", self)
end

-- Allow to use strin as a class
String.__index = String
return setmetatable(String, { __index = string, __call = String.new })
