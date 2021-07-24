SCREEN_MACBOOK = 'Color LCD'
SCREEN_DESKTOP = 'LG UltraFine'

-- Using bundle IDs rather than app names here because iTerm2 doesn't
-- respond to the name that it returns via app:name() for some reason.

APP_ID_KITTY    = 'net.kovidgoyal.kitty'
APP_ID_ITERM    = 'com.googlecode.iterm2'
APP_ID_FIREFOX  = 'org.mozilla.firefox'
APP_ID_CHROME   = 'com.google.Chrome'
APP_ID_MAIL     = 'com.apple.mail'
APP_ID_SLACK    = 'com.tinyspeck.slackmacgap'
APP_ID_SPOTIFY  = 'com.spotify.client'

APP_DEFAULTS = {APP_ID_KITTY, APP_ID_FIREFOX, APP_ID_MAIL, APP_ID_SLACK}

APP_LAYOUT_DESKTOP = {
    {APP_ID_KITTY,   nil, SCREEN_DESKTOP, hs.layout.maximized, nil, nil},
    {APP_ID_ITERM,   nil, SCREEN_DESKTOP, hs.layout.maximized, nil, nil},
    {APP_ID_FIREFOX, nil, SCREEN_DESKTOP, hs.layout.maximized, nil, nil},
    {APP_ID_CHROME,  nil, SCREEN_DESKTOP, hs.layout.maximized, nil, nil},
    {APP_ID_MAIL,    nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_SLACK,   nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_SPOTIFY, nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
}

APP_LAYOUT_LAPTOP = {
    {APP_ID_KITTY,   nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_ITERM,   nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_FIREFOX, nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_CHROME,  nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_MAIL,    nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_SLACK,   nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_SPOTIFY, nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
}

function screenWatcherFn()
    -- Switch setup when number of screens changes.
    local screens = hs.screen.allScreens()
    if #screens ~= #currentScreens then
        currentScreens = screens
        if #screens == 1 then
            switchSetup(APP_LAYOUT_LAPTOP)
        else
            switchSetup(APP_LAYOUT_DESKTOP)
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
    -- Note that the dock will animate when autohide value is toggled.
    -- It's possible to set the speed of this with defaults write,
    -- but the dock will still animate when using killall to apply the
    -- new default, so there would be no real advantage to temporarily
    -- setting a value here. See:
    -- https://macos-defaults.com/dock/autohide-time-modifier.html
    -- https://macos-defaults.com/dock/autohide-delay.html
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

    hs.window.setFrameCorrectness = value
end

function switchSetup(layout)
    local layoutName

    if layout == APP_LAYOUT_LAPTOP then
        layoutName = 'laptop'
    else
        layoutName = 'desktop'
    end

    -- Try to figure out why dock sometimes becomes hidden while in desktop mode.
    hs.notify.show('Switching setup', '', 'Switching to setup: ' .. layoutName)

    setDockAutoHiding(layout == APP_LAYOUT_LAPTOP)
    -- Allow time for dock show/hide anim to take effect.
    hs.timer.doAfter(0.5, function()
        setFrameCorrectness(true)
        hs.layout.apply(layout)
        setFrameCorrectness(false)
        setBluetoothState(layout ~= APP_LAYOUT_LAPTOP)
    end)
end

function launchApps()
    -- Iterate through apps in reverse order, opening them and waiting for each one
    -- to open so that the apps at the top of the layout list end up at the front.

    for i = #APP_DEFAULTS, 1, -1 do
        local id = APP_DEFAULTS[i]
        hs.application.open(id, 10, true)
    end

    if #hs.screen.allScreens() == 1 then
        hs.layout.apply(APP_LAYOUT_LAPTOP)
    else
        hs.layout.apply(APP_LAYOUT_DESKTOP)
    end
end
