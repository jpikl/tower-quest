-- Function module
local Function = {}

-- Binds function to its arguments by creating wrapper
function Function.bind(func, ...)
    local args = { ... }
    return function()
        func(unpack(args))
    end
end

-- Wraps target function, calling the hook before it
function Function.before(func, hook)
    return function(...)
        hook(...)
        func(...)
    end
end

-- Wraps target function, calling the hook after it
function Function.after(func, hook)
    return function(...)
        hook(...)
        func(...)
    end
end

-- Wraps target function, calling the hook around it
function Function.around(func, hook)
    return function(...)
        hook(func, ...)
    end
end

return Function
