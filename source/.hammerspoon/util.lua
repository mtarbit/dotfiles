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

function pprint(obj, depth)
    depth = depth or 1

    if type(obj) ~= 'table' then
        return tostring(obj)
    else
        local result = ''
        local indent_inner = string.rep('    ', depth)
        local indent_outer = string.rep('    ', depth - 1)

        for key, val in pairs(obj) do
            val = pprint(val, depth + 1)
            key = type(key) == 'number' and key or '"' .. key .. '"'
            result = result .. indent_inner .. key .. ' = ' .. val .. ',\n'
        end

        result = '{\n' .. result .. indent_outer .. '}'

        return result
    end
end

function table.contains(table, match)
    for _, value in pairs(table) do
        if value == match then
            return true
        end
    end
    return false
end
