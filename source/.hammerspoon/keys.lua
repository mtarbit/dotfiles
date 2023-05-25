local mush = {'cmd', 'alt'}
local mash = {'cmd', 'alt', 'ctrl'}

hs.hotkey.bind(mush, 'left', resizeWindowL50)
hs.hotkey.bind(mush, 'right', resizeWindowR50)
hs.hotkey.bind(mush, 'up', resizeWindowT50)
hs.hotkey.bind(mush, 'down', resizeWindowB50)

hs.hotkey.bind(mash, 'left', moveWindowScreenPrev)
hs.hotkey.bind(mash, 'right', moveWindowScreenNext)
hs.hotkey.bind(mash, 'up', resizeWindowMax)
hs.hotkey.bind(mash, 'down', resizeWindowC50)

hs.hotkey.bind(mush, 'd', searchDictionary)
hs.hotkey.bind(mash, 'd', searchDictionary)

hs.hotkey.bind(mush, 'p', function() searchPasswords('show') end)
hs.hotkey.bind(mash, 'p', function() searchPasswords('copy') end)
hs.hotkey.bind(mush, 'o', function() searchPasswords('copy-otp') end)
hs.hotkey.bind(mash, 'o', function() searchPasswords('copy-pass-and-otp') end)

hs.hotkey.bind(mash, 'r', hs.reload)
hs.hotkey.bind(mash, '/', hs.toggleConsole)
