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
