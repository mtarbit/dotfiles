local mash = {'cmd', 'alt', 'ctrl'}
local mush = {'cmd', 'alt'}

hs.hotkey.bind(mash, 'left', moveWindowWest)
hs.hotkey.bind(mash, 'right', moveWindowEast)
hs.hotkey.bind(mash, 'up', resizeWindowMax)
hs.hotkey.bind(mash, 'down', resizeWindowMid)

hs.hotkey.bind(mush, 'left', resizeWindowL50)
hs.hotkey.bind(mush, 'right', resizeWindowR50)
hs.hotkey.bind(mush, 'up', resizeWindowT50)
hs.hotkey.bind(mush, 'down', resizeWindowB50)

hs.hotkey.bind(mash, 'd', searchDictionary)
hs.hotkey.bind(mash, 'p', function() searchPasswords('copy') end)
hs.hotkey.bind(mush, 'p', function() searchPasswords('show') end)
hs.hotkey.bind(mash, 'r', hs.reload)
hs.hotkey.bind(mash, '/', hs.toggleConsole)
