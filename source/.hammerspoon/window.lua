hs.window.animationDuration = 0

-- If this stops working, try restarting the app whose windows aren't resizing correctly.
function resizeWindowTo(unitrect)
    local window = hs.window.focusedWindow()

    window:moveToUnit(unitrect)

    if unitrect == hs.layout.right50 then
        -- Hack around whatsapp's windows now having a minimum width which
        -- is greater than half of a macbook pro's available screen width,
        -- so aligning a window to the right of the screen will mean some
        -- of it is off the edge.

        local expectedFrame = unitrect:fromUnitRect(window:screen():frame())
        local receivedFrame = window:frame()

        -- local logger = hs.logger.new('window', 'debug')
        -- logger.i(unitrect)
        -- logger.i(expectedFrame)
        -- logger.i(receivedFrame)

        if receivedFrame.w > expectedFrame.w then
            local x = expectedFrame.x - (receivedFrame.w - expectedFrame.w)
            local y = expectedFrame.y
            window:setTopLeft(hs.geometry.point(x, y))
        end
    end
end

function resizeWindowL50() resizeWindowTo(hs.layout.left50) end
function resizeWindowR50() resizeWindowTo(hs.layout.right50) end
function resizeWindowT50() resizeWindowTo(hs.geometry.unitrect(0.0, 0.0, 1.0, 0.5)) end
function resizeWindowB50() resizeWindowTo(hs.geometry.unitrect(0.0, 0.5, 1.0, 0.5)) end
function resizeWindowC50() resizeWindowTo(hs.geometry.unitrect(0.25, 0.0, 0.5, 1.0)) end
function resizeWindowMax() resizeWindowTo(hs.layout.maximized) end

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
