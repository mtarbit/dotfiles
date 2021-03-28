SCREEN_MACBOOK = 'Color LCD'
SCREEN_DESKTOP = 'LG UltraFine'

-- Using bundle IDs rather than app names here because iTerm2 doesn't
-- respond to the name that it returns via app:name() for some reason.

APP_ID_ITERM  = 'com.googlecode.iterm2'
APP_ID_CHROME = 'com.google.Chrome'
APP_ID_MAIL   = 'com.apple.mail'
APP_ID_SLACK  = 'com.tinyspeck.slackmacgap'

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

function screenWatcherFn()
    -- Switch layouts when number of screens changes.
    local screens = hs.screen.allScreens()
    if #screens ~= #currentScreens then
        currentScreens = screens
        if #screens == 1 then
            applyLayout(APP_LAYOUT_LAPTOP)
        else
            applyLayout(APP_LAYOUT_DESKTOP)
        end
    end
end

currentScreens = hs.screen.allScreens()
screenWatcher = hs.screen.watcher.new(screenWatcherFn)
screenWatcher:start()

function setBluetoothState(value)
    local action

    if value then
        action = 'Turn Bluetooth On'
    else
        action = 'Turn Bluetooth Off'
    end

    runJavaScript([[

        let systemEvents = Application("System Events");
        let systemUiServer = systemEvents.applicationProcesses["SystemUIServer"];

        let menuBarItem, menuItem;

        try {

            // Click the menu-bar item for Bluetooth.
            menuBarItem = systemUiServer.menuBars[0].menuBarItems.whose({description: "bluetooth"}).first();
            menuBarItem.click();

            // Click the menu item to toggle state.
            try {
                menuItem = menuBarItem.menus[0].menuItems.whose({title: "{{ action }}"}).first();
                menuItem.click();
            } catch (e) {
                if (e.message != "Invalid index.") throw e;
                // Send escape key-code to close menu.
                systemEvents.keyCode(53);
            }

        } catch (e) {
            if (e.message != "Invalid index.") throw e;
            // Bluetooth menu-bar item is disabled.
        }

    ]], {action=action})
end

function setDockAutoHiding(value)
    runJavaScript([[
        system = Application("System Events");
        system.dockPreferences.autohide = {{ value }};
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
    setFrameCorrectness(true)
    hs.layout.apply(layout)
    setFrameCorrectness(false)
    setBluetoothState(layout ~= APP_LAYOUT_LAPTOP)
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
