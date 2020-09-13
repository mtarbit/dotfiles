function toggleCaffeinate(modifiers, menuItem)
    local enabled = hs.caffeinate.toggle('displayIdle')
    if enabled then
        hs.notify.show('Caffeinate', '', 'Caffeinate turned on')
    else
        hs.notify.show('Caffeinate', '', 'Caffeinate turned off')
    end
    menuItem.checked = enabled
    menuBarUpdate()
end
