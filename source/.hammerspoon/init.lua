
-- Notes & ideas:
--
-- DONE: General reference for a simple chooser UI.
-- https://gist.github.com/james2doyle/8cec2b2693f7909b36587327a85055d5
--
-- DONE(ish): Look up word in dictionary or similar.
-- https://github.com/nathancahill/Anycomplete/blob/master/anycomplete.lua
-- https://github.com/pasiaj/Translate-for-Hammerspoon/blob/master/gtranslate.lua
-- https://nshipster.com/dictionary-services/
-- https://discussions.apple.com/thread/6504132
-- http://lua-users.org/lists/lua-l/2016-11/msg00200.html
--
-- Progressively resizable windows.
-- https://github.com/miromannino/miro-windows-manager/blob/master/MiroWindowsManager.spoon/init.lua
--
-- DONE: Passwordstore interface.
-- https://github.com/wosc/pass-autotype/blob/master/hammerspoon.lua
-- https://github.com/CGenie/alfred-pass#setup
-- https://brianschiller.com/blog/2016/08/31/gnu-pass-alfred
--
-- DONE: Desktop layout chooser (open usual apps in usual locations)
-- https://github.com/anishathalye/dotfiles-local/blob/mac/hammerspoon/util.lua
-- https://github.com/anishathalye/dotfiles-local/blob/mac/hammerspoon/layout.lua
--
-- Project chooser
-- Automate iTerm2 to open common arrangement of splits and tabs.
-- Changing directories and triggering commands as needed.
-- https://news.ycombinator.com/item?id=13050933
-- Maybe better to handle this in Python than in Hammerspoon:
-- https://gitlab.com/gnachman/iterm2/-/issues/2304#note_161983594
--
-- DONE(ish): Some kind of less obnoxious stretchly/break reminder?
-- https://gitlab.com/NickBusey/dotfiles/-/blob/master/hammerspoon/timers.lua

require('util')
require('dict')
require('pass')
require('config')
require('window')
require('layout')
require('caffeinate')
require('breaks')
require('menu')
require('keys')
