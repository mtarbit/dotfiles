local menuBar = nil
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

menuBarMenu = {
  {title='Break reminders', fn=toggleBreaks, checked=false},
  {title='Caffeinate', fn=toggleCaffeinate, checked=false},
  {title='-'}, -- separator
  {title='Eject external HDD', fn=function() ejectExternalHDD() end},
  {title='Launch apps: Default', fn=function() launchApps(APP_GROUP_DEFAULT) end},
  {title='Launch apps: Storage', fn=function() launchApps(APP_GROUP_STORAGE, false) end},
  {title='Setup: Desktop', fn=function() switchSetup(APP_LAYOUT_DESKTOP) end},
  {title='Setup: Laptop', fn=function() switchSetup(APP_LAYOUT_LAPTOP) end},
  {title='-'}, -- separator
  {title='Hammerspoon: Reload config', fn=hs.reload},
  {title='Hammerspoon: Open console', fn=hs.toggleConsole},
}

function menuBarUpdate()
    menuBar:setMenu(menuBarMenu)
end

menuBarUpdate()
