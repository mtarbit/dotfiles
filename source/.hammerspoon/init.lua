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
-- Some kind of less obnoxious stretchly/break reminder?
--
-- Desktop layout chooser (open usual apps in usual locations)


-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, "W", function()
--     hs.notify.new({title="Hammerspoon", informativeText="Hello, World!"}):send()
-- end)

-- function resizeWindow(dx, dy, dw, dh)
--     local w = hs.window.focusedWindow()
--     local s = w:screen()

--     local wf = w:frame()
--     local sf = s:frame()

--     wf.x = (sf.w * dx) + sf.x
--     wf.y = (sf.h * dy) + sf.y
--     wf.w = (sf.w * dw)
--     wf.h = (sf.h * dh)

--     w:setFrame(wf, 0)
-- end

-- hs.hotkey.bind(hyper, "R", hs.reload)
-- hs.hotkey.bind(hyper, "H", function() hs.window.focusedWindow():moveToScreen(hs.window.focusedWindow():screen():previous(), false, true, 0) end)
-- hs.hotkey.bind(hyper, "L", function() hs.window.focusedWindow():moveToScreen(hs.window.focusedWindow():screen():next(), false, true, 0) end)
--


function watchConfig(files)
    shouldReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            shouldReload = true
        end
    end
    if shouldReload then
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
