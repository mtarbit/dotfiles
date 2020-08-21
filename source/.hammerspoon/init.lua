-- Notes & ideas:
--
-- General reference for a simple chooser UI.
-- https://gist.github.com/james2doyle/8cec2b2693f7909b36587327a85055d5
--
-- Look up word in dictionary or similar.
-- https://github.com/nathancahill/Anycomplete/blob/master/anycomplete.lua
-- https://github.com/pasiaj/Translate-for-Hammerspoon/blob/master/gtranslate.lua
--
-- Progressively resizable windows.
-- https://github.com/miromannino/miro-windows-manager/blob/master/MiroWindowsManager.spoon/init.lua
--
-- Passwordstore interface.
-- https://github.com/wosc/pass-autotype/blob/master/hammerspoon.lua
--
-- Desktop layout chooser (open usual apps in usual locations)
-- https://github.com/anishathalye/dotfiles-local/blob/mac/hammerspoon/util.lua
-- https://github.com/anishathalye/dotfiles-local/blob/mac/hammerspoon/layout.lua
--
-- Some kind of less obnoxious stretchly/break reminder?


function searchDictionary()
    -- This dictionary search isn't ideal because the initial suggestions come
    -- from a unix word list rather than the actual data that Dictionary.app
    -- uses for the word definition. It looks like that data might be stored in a
    -- sqlite DB though, so it might be possible to get suggestions matching the
    -- end result. Try "File > Open Dictionaries Folder" in Dicitonary.app.

    local tab = nil

    function chooserSelect(choice)
        if tab then tab:delete() end
        if choice ~= nil then
            hs.urlevent.openURL("dict://" .. choice.text)
        end
    end

    function chooserUpdate()
        local query = chooser:query()

        if string.len(query) < 2 then
            chooser:choices({})
            return
        end

        local choices = {}
        local results = hs.execute("grep -i '^" .. query .. "' /usr/share/dict/words")

        for s in results:gmatch("[^\r\n]+") do
            table.insert(choices, {text = s})
        end

        chooser:choices(choices)
    end

    function chooserComplete()
        local choice = chooser:selectedRowContents()
        chooser:query(choice.text)
        chooserUpdate()
    end

    tab = hs.hotkey.bind('', 'tab', chooserComplete)

    chooser = hs.chooser.new(chooserSelect)
    chooser:queryChangedCallback(chooserUpdate)
    chooser:placeholderText("A dictionary word")
    chooser:show()
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "D", searchDictionary)
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "/", hs.toggleConsole)

function watchConfig(files)
    local shouldReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            shouldReload = true
        end
    end
    if shouldReload then
        -- hs.notify.new({title="Reloading", informativeText="Reloading hammerspoon config", autoWithdraw=true}):send()
        hs.reload()
    end
end

function resizeWindowTo(unitrect)
    hs.window.focusedWindow():moveToUnit(unitrect, 0)
end

function resizeWindowL50() resizeWindowTo(hs.layout.left50) end
function resizeWindowR50() resizeWindowTo(hs.layout.right50) end
function resizeWindowT50() resizeWindowTo(hs.geometry.unitrect(0.0, 0.0, 1.0, 0.5)) end
function resizeWindowB50() resizeWindowTo(hs.geometry.unitrect(0.0, 0.5, 1.0, 0.5)) end
function resizeWindowMax() resizeWindowTo(hs.layout.maximized) end
function resizeWindowMid() resizeWindowTo(hs.geometry.unitrect(0.125, 0.125, 0.75, 0.75)) end

function moveWindowWest() hs.window.focusedWindow():moveOneScreenWest(false, true, 0) end
function moveWindowEast() hs.window.focusedWindow():moveOneScreenEast(false, true, 0) end

watch = hs.pathwatcher.new(hs.configdir, watchConfig):start()

hyper = {"cmd", "alt", "ctrl"}
cmdAlt = {"cmd", "alt"}

hs.hotkey.bind(hyper, "H", moveWindowWest)
hs.hotkey.bind(hyper, "L", moveWindowEast)
hs.hotkey.bind(hyper, "K", resizeWindowMax)
hs.hotkey.bind(hyper, "J", resizeWindowMid)

hs.hotkey.bind(cmdAlt, "H", resizeWindowL50)
hs.hotkey.bind(cmdAlt, "L", resizeWindowR50)
hs.hotkey.bind(cmdAlt, "K", resizeWindowT50)
hs.hotkey.bind(cmdAlt, "J", resizeWindowB50)

hs.hotkey.bind(hyper, "Left", moveWindowWest)
hs.hotkey.bind(hyper, "Right", moveWindowEast)
hs.hotkey.bind(hyper, "Up", resizeWindowMax)
hs.hotkey.bind(hyper, "Down", resizeWindowMid)

hs.hotkey.bind(cmdAlt, "Left", resizeWindowL50)
hs.hotkey.bind(cmdAlt, "Right", resizeWindowR50)
hs.hotkey.bind(cmdAlt, "Up", resizeWindowT50)
hs.hotkey.bind(cmdAlt, "Down", resizeWindowB50)
