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
  {title='Caffeinate', fn=toggleCaffeinate, checked=false},
  {title='Break reminders', fn=toggleBreaks, checked=false},
  {title='Eject external HDD', fn=function() ejectExternalHDD() end},
  {title='-'}, -- separator
  {title='Setup', menu={
      {title='Desktop', fn=function() switchSetup(LAYOUT_DESKTOP) end},
      {title='Laptop', fn=function() switchSetup(LAYOUT_LAPTOP) end},
  }},
  {title='Layout', menu={
      {title='Desktop', fn=function() setAppLayout(LAYOUT_DESKTOP) end},
      {title='Laptop', fn=function() setAppLayout(LAYOUT_LAPTOP) end},
  }},
  {title='Launch', menu={
      {title='Default', fn=function() launchApps(APP_GROUP_DEFAULT, true, true) end},
      {title='Storage', fn=function() launchApps(APP_GROUP_STORAGE, false, true) end},
  }},
  {title='-'}, -- separator
  {title='Hammerspoon', menu={
      {title='Reload config', fn=hs.reload},
      {title='Open console', fn=hs.toggleConsole},
  }},
}

function menuBarUpdate()
    menuBar:setMenu(menuBarMenu)
end

menuBarUpdate()
