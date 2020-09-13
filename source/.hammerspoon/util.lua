function readFile(path)
    local f = io.open(path, 'r')
    local s = f:read('a')
    f:close()
    return s
end
