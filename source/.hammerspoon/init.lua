
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
-- https://github.com/CGenie/alfred-pass#setup
--
-- Desktop layout chooser (open usual apps in usual locations)
-- https://github.com/anishathalye/dotfiles-local/blob/mac/hammerspoon/util.lua
-- https://github.com/anishathalye/dotfiles-local/blob/mac/hammerspoon/layout.lua
--
-- Some kind of less obnoxious stretchly/break reminder?


-- ==================
-- Dictionary lookups
-- ==================

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
            hs.urlevent.openURL('dict://' .. choice.text)
        end
    end

    function chooserUpdate()
        local query = chooser:query()

        if string.len(query) < 2 then
            chooser:choices({})
            return
        end

        local choices = {}
        local results = hs.execute('grep -i "^' .. query .. '" /usr/share/dict/words')

        for s in results:gmatch('[^\r\n]+') do
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


-- ==================
-- Config auto-reload
-- ==================

function watchConfig(files)
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

watch = hs.pathwatcher.new(hs.configdir, watchConfig):start()


-- ==================
-- Modal key mappings
-- ==================

k = hs.hotkey.modal.new('', '§')

function keyBind(key, pressedfn)
    k:bind('', key, function()
        pressedfn()
        k:exit()
    end)
end

keyBind('escape', function() end)
keyBind('d', searchDictionary)
keyBind('/', hs.toggleConsole)


-- ==================
-- Window arrangement
-- ==================

hs.window.animationDuration = 0
hs.window.setFrameCorrectness = true

function resizeWindowTo(unitrect) hs.window.focusedWindow():moveToUnit(unitrect) end

function resizeWindowL50() resizeWindowTo(hs.layout.left50) end
function resizeWindowR50() resizeWindowTo(hs.layout.right50) end
function resizeWindowT50() resizeWindowTo(hs.geometry.unitrect(0.0, 0.0, 1.0, 0.5)) end
function resizeWindowB50() resizeWindowTo(hs.geometry.unitrect(0.0, 0.5, 1.0, 0.5)) end
function resizeWindowMax() resizeWindowTo(hs.layout.maximized) end
function resizeWindowMid() resizeWindowTo(hs.geometry.unitrect(0.125, 0.125, 0.75, 0.75)) end

function moveWindowWest() hs.window.focusedWindow():moveOneScreenWest(false, true) end
function moveWindowEast() hs.window.focusedWindow():moveOneScreenEast(false, true) end


hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'h', moveWindowWest)
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'l', moveWindowEast)
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'k', resizeWindowMax)
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'j', resizeWindowMid)

hs.hotkey.bind({'cmd', 'alt'}, 'h', resizeWindowL50)
hs.hotkey.bind({'cmd', 'alt'}, 'l', resizeWindowR50)
hs.hotkey.bind({'cmd', 'alt'}, 'k', resizeWindowT50)
hs.hotkey.bind({'cmd', 'alt'}, 'j', resizeWindowB50)

hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'left', moveWindowWest)
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'right', moveWindowEast)
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'up', resizeWindowMax)
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'down', resizeWindowMid)

hs.hotkey.bind({'cmd', 'alt'}, 'left', resizeWindowL50)
hs.hotkey.bind({'cmd', 'alt'}, 'right', resizeWindowR50)
hs.hotkey.bind({'cmd', 'alt'}, 'up', resizeWindowT50)
hs.hotkey.bind({'cmd', 'alt'}, 'down', resizeWindowB50)


-- =======
-- Layouts
-- =======

SCREEN_MACBOOK = 'Color LCD'
SCREEN_DESKTOP = 'LG UltraFine'

APP_ITERM  = 'iTerm2'
APP_CHROME = 'Google Chrome'
APP_MAIL   = 'Mail'
APP_SLACK  = 'Slack'

LAYOUT_DOCKED = {
    {APP_ITERM,  nil, SCREEN_DESKTOP, hs.layout.maximized, nil, nil},
    {APP_CHROME, nil, SCREEN_DESKTOP, hs.layout.maximized, nil, nil},
    {APP_MAIL,   nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_SLACK,  nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
}

LAYOUT_LAPTOP = {
    {APP_ITERM,  nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_CHROME, nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_MAIL,   nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_SLACK,  nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
}

function applyLayout(layout)
    -- Unfortunately with my current version of Hammerspoon and macOS
    -- I'm seeing inaccurate window-sizing when using hs.layout.apply
    -- where some windows will stretch under the dock when maximized.
    --
    -- Possibly related:
    -- https://github.com/Hammerspoon/hammerspoon/issues/408
    --
    -- This option appears to fix things at the expense of some ugly
    -- jumping around as the windows resize. I'm just toggling it
    -- here rather than turning it on permanently since resizing
    -- via window:moveToUnit() seems to work okay.

    function setFrameCorrectness(value)
        -- Only need to do this when switching to the laptop layout
        -- since it mainly seems to affect Chrome and iTerm and the
        -- laptop's screen is the one with the dock.
        if layout == LAYOUT_LAPTOP then
            hs.window.setFrameCorrectness = value
        end
    end

    setFrameCorrectness(true)
    hs.layout.apply(layout)
    setFrameCorrectness(false)
end


-- ==========
-- Caffeinate
-- ==========

function toggleCaffeinate(modifiers, menuItem)
    local enabled = hs.caffeinate.toggle('displayIdle')
    if enabled then
        hs.notify.new({title='Caffeinate', informativeText='Caffeinate on'}):send()
    else
        hs.notify.new({title='Caffeinate', informativeText='Caffeinate off'}):send()
    end
    menuItem.checked = enabled
    menuBarUpdate()
end


-- ========
-- Menu bar
-- ========

local menuBarMenu = nil
local menuBarIcon = [[
. . . . . . . . . . . . 3
. . . . . . . . . . # # .
. . 1 . . . . . # # # # .
. . . # # . . # # # # . .
. . . # # # 2 # # # # . .
. . . 5 # # # # # 4 . . .
. . . . . . . . . . . . .
. . . B # # # # # 7 . . .
. . # # # # 9 # # # . . .
. . # # # # . . # # . . .
. # # # # . . . . . 8 . .
. # # . . . . . . . . . .
A . . . . . . . . . . . .
]]

menuBar = hs.menubar.new()
menuBar:setIcon('ASCII:' .. menuBarIcon)

function menuBarUpdate()
    menuBar:setMenu(menuBarMenu)
end

menuBarMenu = {
  {title='Caffeinate', fn=toggleCaffeinate, checked=false},
  {title='-'}, -- separator
  {title='Layout: Docked', fn=function() applyLayout(LAYOUT_DOCKED) end},
  {title='Layout: Laptop', fn=function() applyLayout(LAYOUT_LAPTOP) end},
}

menuBarUpdate()
