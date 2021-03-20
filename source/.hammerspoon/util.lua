function readFile(path)
    local f = io.open(path, 'r')
    local s = f:read('a')
    f:close()
    return s
end

function partial(fn, arg)
    return function(...)
        return fn(arg, ...)
    end
end

function template(s, t)
    local pattern = '{{%s*([^}]-)%s*}}'
    local replace = function(k) return tostring(t[k]) end
    local result, _ = s:gsub(pattern, replace)
    return result
end

function runAppleScript(s, t)
    hs.osascript.applescript(template(s, t))
end
