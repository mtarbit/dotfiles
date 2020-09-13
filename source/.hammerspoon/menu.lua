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
  {title='-'}, -- separator
  {title='Launch default apps', fn=launchApps},
  {title='Layout: Docked', fn=function() applyLayout(APP_LAYOUT_DOCKED) end},
  {title='Layout: Laptop', fn=function() applyLayout(APP_LAYOUT_LAPTOP) end},
  {title='-'}, -- separator
  {title='Hammerspoon: Reload config', fn=hs.reload},
  {title='Hammerspoon: Open console', fn=hs.toggleConsole},
}

function menuBarUpdate()
    menuBar:setMenu(menuBarMenu)
end

menuBarUpdate()
