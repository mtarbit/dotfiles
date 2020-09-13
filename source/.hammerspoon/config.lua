local watchConfig = function(files)
    local shouldReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == '.lua' then
            shouldReload = true
        end
    end
    if shouldReload then
        hs.reload()
    end
end

watcher = hs.pathwatcher.new(hs.configdir, watchConfig):start()
