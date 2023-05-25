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

function runJavaScript(s, t)
    return hs.osascript.javascript(template(s, t))
    -- To debug template substitution and return value:
    -- local source = template(s, t)
    -- local logger = hs.logger.new('util', 'debug')
    -- logger.i(source)
    -- return hs.osascript._osascript(source, "JavaScript")
end

function runAppleScript(s, t)
    return hs.osascript.applescript(template(s, t))
end
