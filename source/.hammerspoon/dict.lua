-- This dictionary search isn't ideal because the initial suggestions come
-- from a unix word list rather than the actual data that Dictionary.app
-- uses for the word definition. It looks like that data might be stored in a
-- sqlite DB though, so it might be possible to get suggestions matching the
-- end result. Try "File > Open Dictionaries Folder" in Dictionary.app.

local tab = nil
local chooser = nil

local chooserSelect = function(choice)
    if tab then tab:delete() end
    if choice ~= nil then
        hs.urlevent.openURL('dict://' .. choice.text)
    end
end

local chooserUpdate = function()
    local query = chooser:query()

    if query:len() < 2 then
        chooser:choices({})
        return
    end

    local choices = {}
    local results = hs.execute('grep -i "^' .. query .. '" /usr/share/dict/words')

    for s in results:gmatch('[^\n]+') do
        table.insert(choices, {text = s})
    end

    chooser:choices(choices)
end

local chooserComplete = function()
    local choice = chooser:selectedRowContents()
    chooser:query(choice.text)
    chooserUpdate()
end

function searchDictionary()
    tab = hs.hotkey.bind('', 'tab', chooserComplete)
    chooser = hs.chooser.new(chooserSelect)
    chooser:queryChangedCallback(chooserUpdate)
    chooser:placeholderText("Search for a word…")
    chooser:show()
end
