-- See `hs.screen.find()` for notes on use of '%' here:
-- https://www.hammerspoon.org/docs/hs.screen.html#find

-- SCREEN_MACBOOK = 'Built%-in Retina Display'
SCREEN_MACBOOK = '5DA908AD-E526-82CA-BA70-B36377A262C4'
-- SCREEN_DESKTOP = 'LG UltraFine'
SCREEN_DESKTOP = '2C89607A-254C-BFC7-958B-A07D111936FA'

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
    {APP_ID_FIREFOX, nil, SCREEN_DESKTOP, hs.layout.maximized, nil, nil},
    {APP_ID_MAIL,    nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_SLACK,   nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_SPOTIFY, nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
}

APP_LAYOUT_LAPTOP = {
    {APP_ID_KITTY,   nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
    {APP_ID_FIREFOX, nil, SCREEN_MACBOOK, hs.layout.maximized, nil, nil},
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
    hs.notify.show('Setting bluetooth state', '', (value and "On" or "Off"))

    local action

    if value then
        action = 'Turn Bluetooth On'
    else
        action = 'Turn Bluetooth Off'
    end

    return runJavaScript([[

        var systemPrefs = Application("System Preferences");

        systemPrefs.activate();
        systemPrefs.panes.byName("Bluetooth").reveal();

        var systemPrefsUI = Application("System Events").processes.byName("System Preferences");
        var bluetoothUI = systemPrefsUI.windows.byName("Bluetooth");
        var button;

        delay(2.5);

        try {
            button = bluetoothUI.buttons.byName("{{ action }}");
            button.click();
        } catch (e) {
            if (e.message != "Can't get object.") {
                throw e;
            }
        }

        systemPrefs.quit();

        delay(1.0);

    ]], {action=action})
end

function setScrollDirection(value)
    hs.notify.show('Setting scroll direction', '', (value and "Trackpad" or "Mouse"))

    return runJavaScript([[

        // To find the properties and paths needed for UI elements
        // referenced here you can try pasting part of this script
        // into `Script Editor.app` and then try methods like
        // `.properties()` and `.entireContents()`. You can see
        // output from calls to console.log in the "messages" tab.

        // Also try `osascript -l Javascript -i`. See:
        // https://www.macstories.net/tutorials/getting-started-with-javascript-for-automation-on-yosemite/

        var systemPrefs = Application("System Preferences");

        systemPrefs.activate();
        systemPrefs.panes.byName("Trackpad").reveal();

        var systemPrefsUI = Application("System Events").processes.byName("System Preferences");
        var trackpadUI = systemPrefsUI.windows.byName("Trackpad").tabGroups.at(0);

        delay(2.5);

        trackpadUI.radioButtons.byName("Scroll & Zoom").click();

        if (trackpadUI.checkboxes.at(0).value() != {{ value }}) {
            trackpadUI.checkboxes.at(0).click();
        }

        systemPrefs.quit();

        delay(1.0);

    ]], {value=(value and 1 or 0)})
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
    hs.timer.doAfter(3.0, function()
        setFrameCorrectness(true)
        hs.layout.apply(layout)
        setFrameCorrectness(false)
        setBluetoothState(layout ~= APP_LAYOUT_LAPTOP)
        setScrollDirection(layout == APP_LAYOUT_LAPTOP)
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
