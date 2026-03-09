-- See `hs.screen.find()` for notes on use of '%' here:
-- https://www.hammerspoon.org/docs/hs.screen.html#find

-- SCREEN_MACBOOK = 'Built%-in Retina Display'
-- SCREEN_MACBOOK = '5DA908AD-E526-82CA-BA70-B36377A262C4'
SCREEN_MACBOOK = '37D8832A-2D66-02CA-B9F7-8F30A301B230'
-- SCREEN_DESKTOP = 'LG UltraFine'
-- SCREEN_DESKTOP = '2C89607A-254C-BFC7-958B-A07D111936FA'
SCREEN_DESKTOP = '9D6E5FCE-F4D3-4088-87D6-3221B877B953'


-- Using bundle IDs rather than app names here because iTerm2 doesn't
-- respond to the name that it returns via app:name() for some reason.

APP_ID_KITTY    = 'net.kovidgoyal.kitty'
APP_ID_FIREFOX  = 'org.mozilla.firefox'
APP_ID_MAIL     = 'com.apple.mail'
APP_ID_SLACK    = 'com.tinyspeck.slackmacgap'
APP_ID_WHATSAPP = 'net.whatsapp.WhatsApp'
APP_ID_SPOTIFY  = 'com.spotify.client'
APP_ID_DOCKER   = 'com.docker.docker'
APP_ID_DOCKER_DESKTOP = 'com.electron.dockerdesktop'
APP_ID_TRANSMISSION = 'org.m0k.transmission'
APP_ID_JELLYFIN = 'Jellyfin.Server'
APP_ID_REMINDERS = 'com.apple.reminders'
APP_ID_CONTACTS = 'com.apple.AddressBook'
APP_ID_KINDLE   = 'com.amazon.Lassen'
APP_ID_FINDER   = 'com.apple.finder'
APP_ID_PREVIEW  = 'com.apple.Preview'


-- A base app layout table we'll use in `generateAppLayout` to generate
-- the fussier app layout table format expected by `hs.layout.apply()`.

APP_LAYOUT = {
    {APP_ID_KITTY,        SCREEN_DESKTOP, hs.layout.maximized},
    {APP_ID_FIREFOX,      SCREEN_DESKTOP, hs.layout.maximized},
    {APP_ID_MAIL,         SCREEN_MACBOOK, hs.layout.maximized},
    {APP_ID_SLACK,        SCREEN_MACBOOK, hs.layout.maximized},
    {APP_ID_WHATSAPP,     SCREEN_MACBOOK, hs.layout.right50},
    {APP_ID_SPOTIFY,      SCREEN_MACBOOK, hs.layout.maximized},
    {APP_ID_TRANSMISSION, SCREEN_MACBOOK, hs.layout.left50},
    {APP_ID_REMINDERS,    SCREEN_MACBOOK, hs.layout.left50},
    {APP_ID_CONTACTS,     SCREEN_MACBOOK, hs.layout.left50},
    {APP_ID_KINDLE,       SCREEN_DESKTOP, hs.layout.maximized},
    {APP_ID_FINDER,       SCREEN_DESKTOP, hs.layout.right50},
    {APP_ID_PREVIEW,      SCREEN_DESKTOP, hs.layout.maximized},
}


-- Note that apps should be listed in the order we want them to be opened
-- (e.g. because they may depend on each other or for stacking purposes).

APP_GROUP_DEFAULT = {APP_ID_SLACK, APP_ID_MAIL, APP_ID_WHATSAPP, APP_ID_FIREFOX, APP_ID_KITTY, APP_ID_DOCKER, APP_ID_DOCKER_DESKTOP}
APP_GROUP_STORAGE = {APP_ID_JELLYFIN, APP_ID_TRANSMISSION}

APP_GROUP_STORAGE_ONLY_ON_QUIT = {APP_ID_DOCKER_DESKTOP}
APP_GROUP_STORAGE_ONLY_DESKTOP = {APP_ID_JELLYFIN, APP_ID_TRANSMISSION}


-- Just some constants to avoid passing "magic strings" around.

LAYOUT_DESKTOP = 'desktop'
LAYOUT_LAPTOP = 'laptop'


function generateAppLayout(layoutName)
    -- Get app layout table for passing to `hs.layout.apply()`:
    -- https://www.hammerspoon.org/docs/hs.layout.html#apply
    local layout = {}

    for index, table in ipairs(APP_LAYOUT) do
        bundleID = table[1]
        screenUUID = table[2]
        unitRectFn = table[3]

        if layoutName == LAYOUT_LAPTOP then
            -- If the external monitor isn't available then all apps
            -- will be placed on the built-in laptop screen instead.
            screenUUID = SCREEN_MACBOOK
        end

        layout[index] = {bundleID, nil, screenUUID, unitRectFn, nil, nil}
    end

    return layout
end


-- Volume paths as seen in `hs.fs.volume.allVolumes()`.

VOLUME_STORAGE = "/Volumes/File Storage"
VOLUME_BACKUPS = "/Volumes/Time Machine Backups"

VOLUME_PATHS = {VOLUME_STORAGE, VOLUME_BACKUPS}


function screenWatcherFn()
    -- Switch setup when number of screens changes.
    if screenIsLocked then
        return
    end
    local latestScreens = #hs.screen.allScreens()
    if currentScreens ~= latestScreens then
        currentScreens = latestScreens
        if currentScreens == 1 then
            switchSetup(LAYOUT_LAPTOP)
        else
            switchSetup(LAYOUT_DESKTOP)
        end
    end
end

function lockedWatcherFn(eventType)
    if eventType == hs.caffeinate.watcher.screensDidLock then
        screenIsLocked = true
    elseif eventType == hs.caffeinate.watcher.screensDidUnlock then
        screenIsLocked = false
        screenWatcherFn()
    end
end

function volumeWatcherFn(eventType, volume)
    -- TODO: Toggle disabled state for "eject external HDD" option
    -- in menubar when VOLUME_STORAGE is mounted/unmounted.
    if volume["path"] == VOLUME_STORAGE then
        if eventType == hs.fs.volume.didMount then
            launchApps(APP_GROUP_STORAGE, false)
        -- elseif eventType == hs.fs.volume.willUnmount then
            -- print("Volume willUnmount:")
            -- print(pprint(volume))
            -- quitApps(APP_GROUP_STORAGE)
        end
    end
end

screenIsLocked = nil
currentScreens = #hs.screen.allScreens()

screenWatcher = hs.screen.watcher.new(screenWatcherFn)
screenWatcher:start()

lockedWatcher = hs.caffeinate.watcher.new(lockedWatcherFn)
lockedWatcher:start()

volumeWatcher = hs.fs.volume.new(volumeWatcherFn)
volumeWatcher:start()

function setBluetoothState(value)
    hs.notify.show('Setting bluetooth state', '', (value and "On" or "Off"))

    return setSystemSetting("Bluetooth", [[

        var checkbox = settingsUI.scrollAreas.at(0).groups.at(0).checkboxes.byName("Bluetooth");
        if (checkbox.value() != {{ value }}) {
            checkbox.click();
        }

    ]], {value=(value and 1 or 0)})
end

function setScrollDirection(value)
    hs.notify.show('Setting scroll direction', '', (value and "Trackpad" or "Mouse"))

    return setSystemSetting("Trackpad", [[

        settingsUI.tabGroups.at(0).radioButtons.at(1).click();

        delay(1.0)

        var checkbox = settingsUI.scrollAreas.at(0).groups.at(0).checkboxes.byName("Natural scrolling");
        if (checkbox.value() != {{ value }}) {
            checkbox.click();
        }

    ]], {value=(value and 1 or 0)})
end

function setSystemSetting(label, script, table)
    return runJavaScript([[

        // To find the properties and paths needed for UI elements
        // referenced here you can try pasting part of this script
        // into `Script Editor.app` and then try methods like
        // `.properties()` and `.entireContents()`. You can see
        // output from calls to console.log in the "messages" tab.

        // Also try `osascript -l JavaScript -i`. See:
        // https://www.macstories.net/tutorials/getting-started-with-javascript-for-automation-on-yosemite/

        var settings = Application("System Settings");

        settings.activate();
        settings.panes.byName("{{ label }}").reveal();

        var settingsWindowUI = Application("System Events").processes.byName("System Settings").windows.at(0);
        var settingsUI = settingsWindowUI.groups.at(0).splitterGroups.at(0).groups.at(1).groups.at(0);

        delay(1.0);

        {{ script }}

        // Allow time for checkbox toggle animation
        // before continuing with anything else.

        delay(1.0);

        settings.quit();

    ]], {label=label, script=template(script, table)})
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

        // Allow time for dock show/hide animation
        // before continuing with anything else.

        delay(3.0);
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

function setAppLayout(layoutName)
    if layoutName == nil then
        if #hs.screen.allScreens() == 1 then
            layoutName = LAYOUT_LAPTOP
        else
            layoutName = LAYOUT_DESKTOP
        end
    end

    setFrameCorrectness(true)
    hs.layout.apply(generateAppLayout(layoutName))
    setFrameCorrectness(false)
end

function switchSetup(layoutName)
    hs.notify.show("Switching setup", "", "Switching to setup: " .. layoutName)

    setDockAutoHiding(layoutName == LAYOUT_LAPTOP)
    setBluetoothState(layoutName == LAYOUT_DESKTOP)
    setScrollDirection(layoutName == LAYOUT_LAPTOP)
    setAppLayout(layoutName)
end

function launchApps(appGroup, shouldWait, shouldLayout)
    for i, bundleID in ipairs(appGroup) do
        local shouldOpen = true

        if table.contains(APP_GROUP_STORAGE_ONLY_ON_QUIT, bundleID) then
            shouldOpen = false
        end

        if table.contains(APP_GROUP_STORAGE_ONLY_DESKTOP, bundleID) and currentScreens == 1 then
            shouldOpen = false
        end

        if shouldOpen then
            if shouldWait then
                hs.application.open(bundleID, 10, true)
            else
                hs.application.open(bundleID)
            end
        end
    end

    if shouldLayout then
        setAppLayout()
    end
end

function quitApps(appGroup)
    for i, bundleID in pairs(appGroup) do
        local app = hs.application.get(bundleID)
        if app then app:kill() end
    end
end

function ejectExternalHDD()
    quitApps(APP_GROUP_STORAGE)
    for i, volumePath in pairs(VOLUME_PATHS) do
        hs.fs.volume.eject(volumePath)
    end
end
