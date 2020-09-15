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
    result, _ = s:gsub('{{%s*([^}]-)%s*}}', function(k) return t[k] end)
    return result
end
