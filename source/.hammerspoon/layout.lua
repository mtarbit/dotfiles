-- Using bundle IDs rather than app names here because iTerm2 doesn't
-- respond to the name that it returns via app:name() for some reason.

APP_ID_ITERM  = 'com.googlecode.iterm2'
APP_ID_CHROME = 'com.google.Chrome'
APP_ID_MAIL   = 'com.apple.mail'
APP_ID_SLACK  = 'com.tinyspeck.slackmacgap'

SCREEN_MACBOOK = 'Color LCD'
SCREEN_DESKTOP = 'LG UltraFine'

APP_LAYOUT_DESKTOP = {
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

function setBluetoothState(value)
    -- It was a trial and error process getting this to work and still seems
    -- like it'll be flakey. If it causes much more difficulty then it might
    -- be best to try this instead: https://github.com/toy/blueutil

    local button
    local result

    if value then
        button = 'Turn Bluetooth On'
        result = 'Bluetooth: On'
    else
        button = 'Turn Bluetooth Off'
        result = 'Bluetooth: Off'
    end

    runAppleScript([[
        tell application "System Preferences"
            set current pane to pane "com.apple.preferences.Bluetooth"

            tell application "System Events"
                tell process "System Preferences"
                    try

                        -- First click the button.
                        click button "{{ button }}" of window "Bluetooth"

                        -- But then repeatedly check if the label has changed before quitting
                        -- or there might be no effect, especially when turning bluetooth off.
                        repeat while true
                            try
                                select static text "{{ result }}" of window "Bluetooth"
                                exit repeat
                            end try
                        end repeat

                    end try
                end tell
            end tell

            quit
        end tell
    ]], {button=button, result=result})
end

function setDockAutoHiding(value)
    runAppleScript([[
        tell app "System Events"
            set autohide of dock preferences to {{ value }}
        end tell
    ]], {value=value})
end

function setFrameCorrectness(value)
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

    -- Only need to do this when switching to the laptop layout
    -- since it mainly seems to affect Chrome and iTerm and the
    -- laptop's screen is the one with the dock.

    if layout == APP_LAYOUT_LAPTOP then
        hs.window.setFrameCorrectness = value
    end
end

function applyLayout(layout)
    setDockAutoHiding(layout == APP_LAYOUT_LAPTOP)
    setBluetoothState(layout ~= APP_LAYOUT_LAPTOP)
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
        layout = APP_LAYOUT_DESKTOP
    end

    -- Iterate through apps in reverse order, opening them and waiting for each one
    -- to open so that the apps at the top of the layout list end up at the front.

    for i = #layout, 1, -1 do
        local id = layout[i][1]
        hs.application.open(id, 10, true)
    end
end
