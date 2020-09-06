
-- Notes & ideas:
--
-- General reference for a simple chooser UI.
-- https://gist.github.com/james2doyle/8cec2b2693f7909b36587327a85055d5
--
-- Look up word in dictionary or similar.
-- https://github.com/nathancahill/Anycomplete/blob/master/anycomplete.lua
-- https://github.com/pasiaj/Translate-for-Hammerspoon/blob/master/gtranslate.lua
-- https://nshipster.com/dictionary-services/
--
-- Progressively resizable windows.
-- https://github.com/miromannino/miro-windows-manager/blob/master/MiroWindowsManager.spoon/init.lua
--
-- Passwordstore interface.
-- https://github.com/wosc/pass-autotype/blob/master/hammerspoon.lua
-- https://github.com/CGenie/alfred-pass#setup
-- https://brianschiller.com/blog/2016/08/31/gnu-pass-alfred
--
-- Desktop layout chooser (open usual apps in usual locations)
-- https://github.com/anishathalye/dotfiles-local/blob/mac/hammerspoon/util.lua
-- https://github.com/anishathalye/dotfiles-local/blob/mac/hammerspoon/layout.lua
--
-- Project chooser
-- Automate iTerm2 to open common arrangement of splits and tabs.
-- Changing directories and triggering commands as needed.
-- https://news.ycombinator.com/item?id=13050933
--
-- Some kind of less obnoxious stretchly/break reminder?
-- https://gitlab.com/NickBusey/dotfiles/-/blob/master/hammerspoon/timers.lua


-- ==========
-- Dictionary
-- ==========

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


-- =========
-- Passwords
-- =========

function searchPasswords()
    local tab = nil
    local choices = {}

    function longestCommonPrefix(choices)
        local length = math.huge
        local result = ""
        local charA, charB

        -- Find the length of the shortest string.
        for _, choice in pairs(choices) do
            local n = choice.text:len()
            if n < length then length = n end
        end

        -- Compare choices until we find a conflict.
        for charIndex = 1, length do
            if choices[1] then
                charA = choices[1].text:sub(charIndex, charIndex)
            else
                return result
            end

            for choiceIndex = 2, #choices do
                charB = choices[choiceIndex].text:sub(charIndex, charIndex)
                if charA ~= charB then
                    return result
                end
            end

            result = result .. charA
        end

        return result
    end

    function chooserSelect(choice)
        if tab then tab:delete() end
        if choice ~= nil then
            local label = choice.text

            -- Note that this is a bit finicky. Calling the `pass` command will
            -- trigger a pinentry dialog when needed, presuming pinentry-mac is
            -- installed, and it looks like the hs.chooser steals focus back
            -- from this dialog just after it's launched unless we add a small
            -- delay to make sure that the command happens after the chooser is
            -- closed instead of before.
            --
            -- Also, this uses a pbcopy pipeline instead of `pass show -c`
            -- because that seems to cause issues of its own (crash/beachball).

            hs.timer.doAfter(0.000001, function()
                hs.execute('pass show ' .. label .. ' | head -1 | tr -d \'\n\' | pbcopy', true)
                hs.notify.new({title="Password copied", informativeText=label}):send()
            end)
        end
    end

    function chooserUpdate()
        local query = chooser:query()
        local path = os.getenv('HOME') .. '/.password-store'
        local results = ''

        if query:len() < 1 then
            choices = {}
        else
            choices = {}
            results = hs.execute("find " .. path .. " -name '*.gpg' | sed 's|" .. path .. '/' .. "||' | grep '^" .. query .. "' | sort")

            for s in results:gmatch('[^\n]+') do
                table.insert(choices, {text = s:sub(0, -5)})
            end
        end

        chooser:choices(choices)
    end

    function chooserComplete()
        local prefix = longestCommonPrefix(choices)
        local choice = chooser:selectedRowContents()
        local query = chooser:query()

        if prefix == chooser:query() then
            -- If we've tab-completed the longest prefix already then
            -- a 2nd tab-press should select the top item in the list.
            chooser:query(choice.text)
        else
            chooser:query(prefix)
        end

        chooserUpdate()
    end

    tab = hs.hotkey.bind('', 'tab', chooserComplete)

    chooser = hs.chooser.new(chooserSelect)
    chooser:queryChangedCallback(chooserUpdate)
    chooser:placeholderText("A password name")
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

watcher = hs.pathwatcher.new(hs.configdir, watchConfig):start()


-- ==================
-- Window arrangement
-- ==================

hs.window.animationDuration = 0

function resizeWindowTo(unitrect) hs.window.focusedWindow():moveToUnit(unitrect) end

function resizeWindowL50() resizeWindowTo(hs.layout.left50) end
function resizeWindowR50() resizeWindowTo(hs.layout.right50) end
function resizeWindowT50() resizeWindowTo(hs.geometry.unitrect(0.0, 0.0, 1.0, 0.5)) end
function resizeWindowB50() resizeWindowTo(hs.geometry.unitrect(0.0, 0.5, 1.0, 0.5)) end
function resizeWindowMax() resizeWindowTo(hs.layout.maximized) end
function resizeWindowMid() resizeWindowTo(hs.geometry.unitrect(0.125, 0.125, 0.75, 0.75)) end

function moveWindowWest() hs.window.focusedWindow():moveOneScreenWest(false, true) end
function moveWindowEast() hs.window.focusedWindow():moveOneScreenEast(false, true) end


-- =======
-- Layouts
-- =======

-- Using bundle IDs rather than app names here because iTerm2 doesn't
-- respond to the name that it returns via app:name() for some reason.

APP_ID_ITERM  = 'com.googlecode.iterm2'
APP_ID_CHROME = 'com.google.Chrome'
APP_ID_MAIL   = 'com.apple.mail'
APP_ID_SLACK  = 'com.tinyspeck.slackmacgap'

SCREEN_MACBOOK = 'Color LCD'
SCREEN_DESKTOP = 'LG UltraFine'

APP_LAYOUT_DOCKED = {
    {APP_ID_ITERM,  nil, SCREEN_DESKTOP, hs.layout.maximized, nil, nil},
    {APP_ID_CHROME, nil, SCREEN_DESKTOP, hs.layout.maximized, nil, nil},
    {APP_ID_MAIL,   nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_SLACK,  nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
}

APP_LAYOUT_LAPTOP = {
    {APP_ID_ITERM,  nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_CHROME, nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_MAIL,   nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_SLACK,  nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
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

function launchApps()
    local screens = hs.screen.allScreens()
    local layout = nil

    if #screens == 1 then
        layout = APP_LAYOUT_LAPTOP
    else
        layout = APP_LAYOUT_DOCKED
    end

    -- Iterate through apps in reverse order, opening them and waiting for each one
    -- to open so that the apps at the top of the layout list end up at the front.

    for i = #layout, 1, -1 do
        local id = layout[i][1]
        hs.application.open(id, 10, true)
    end
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
  {title='Launch default apps', fn=launchApps},
  {title='Layout: Docked', fn=function() applyLayout(APP_LAYOUT_DOCKED) end},
  {title='Layout: Laptop', fn=function() applyLayout(APP_LAYOUT_LAPTOP) end},
  {title='-'}, -- separator
  {title='Hammerspoon: Reload config', fn=hs.reload},
  {title='Hammerspoon: Open console', fn=hs.toggleConsole},
}

menuBarUpdate()


-- =================
-- Keyboard mappings
-- =================

local mash = {'cmd', 'alt', 'ctrl'}
local mush = {'cmd', 'alt'}

hs.hotkey.bind(mash, 'left', moveWindowWest)
hs.hotkey.bind(mash, 'right', moveWindowEast)
hs.hotkey.bind(mash, 'up', resizeWindowMax)
hs.hotkey.bind(mash, 'down', resizeWindowMid)

hs.hotkey.bind(mush, 'left', resizeWindowL50)
hs.hotkey.bind(mush, 'right', resizeWindowR50)
hs.hotkey.bind(mush, 'up', resizeWindowT50)
hs.hotkey.bind(mush, 'down', resizeWindowB50)

hs.hotkey.bind(mash, 'd', searchDictionary)
hs.hotkey.bind(mash, 'p', searchPasswords)
hs.hotkey.bind(mash, '/', hs.toggleConsole)
