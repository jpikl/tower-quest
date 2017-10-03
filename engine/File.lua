-- File module
local File = {}

-- Makes path from the specified directory and file
function File.path(directory, file)
    if not directory then
        return file or ""
    elseif directory:sub(#directory) == "/" then
        return file and (directory .. file) or directory
    else
        return file and (directory .. "/" .. file) or (directory .. "/")
    end
end

-- Makes Lua prefix from the specified path
function File.prefix(path)
    if not path then
        return ""
    end
    local prefix = path:gsub("/", ".")
    if #prefix > 0 and prefix:sub(#prefix) ~= "." then
        return prefix .. "."
    else
        return prefix
    end
end

return File
