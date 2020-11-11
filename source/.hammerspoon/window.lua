hs.window.animationDuration = 0

function resizeWindowTo(unitrect) hs.window.focusedWindow():moveToUnit(unitrect) end

function resizeWindowL50() resizeWindowTo(hs.layout.left50) end
function resizeWindowR50() resizeWindowTo(hs.layout.right50) end
function resizeWindowT50() resizeWindowTo(hs.geometry.unitrect(0.0, 0.0, 1.0, 0.5)) end
function resizeWindowB50() resizeWindowTo(hs.geometry.unitrect(0.0, 0.5, 1.0, 0.5)) end
function resizeWindowMax() resizeWindowTo(hs.layout.maximized) end
function resizeWindowMid() resizeWindowTo(hs.geometry.unitrect(0.125, 0.125, 0.75, 0.75)) end

-- Seems to have stopped working after a hammerspoon update?
function moveWindowWest() hs.window.focusedWindow():moveOneScreenWest(false, true) end
function moveWindowEast() hs.window.focusedWindow():moveOneScreenEast(false, true) end

function moveWindowScreenPrev()
    local w = hs.window.focusedWindow()
    local s = w:screen():previous()
    w:moveToScreen(s, false, true)
end

function moveWindowScreenNext()
    local w = hs.window.focusedWindow()
    local s = w:screen():next()
    w:moveToScreen(s, false, true)
end
