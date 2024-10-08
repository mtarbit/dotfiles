
-- This is a chooser interface for "Pass: The Standard Unix Password Manager"
-- so that I can avoid a common situation where I have a vestigial terminal
-- window or split hanging around just for accessing heavily used passwords.
-- https://www.passwordstore.org/

local tab = nil
local chooser = nil
local choices = {}
local webview = nil
local focused = nil

local longestCommonPrefix = function(choices)
    local length = math.huge
    local result = ""
    local charA, charB

    -- Find the length of the shortest string.
    for _, choice in pairs(choices) do
        local n = choice.text:len()
        if n < length then length = n end
    end

    -- Compare choices until we find a conflict.
    for charIndex = 1, length do
        if choices[1] then
            charA = choices[1].text:sub(charIndex, charIndex)
        else
            return result
        end

        for choiceIndex = 2, #choices do
            charB = choices[choiceIndex].text:sub(charIndex, charIndex)
            if charA ~= charB then
                return result
            end
        end

        result = result .. charA
    end

    return result
end

local copyPassword = function(output, name, title)
    hs.pasteboard.setContents(output)
    hs.notify.show(title .. " copied", '', name)
end

local showPassword = function(output)
    local unit = hs.geometry.unitrect(0.3, 0.2, 0.4, 0.6)
    local rect = unit:fromUnitRect(hs.screen.primaryScreen():frame())
    local html = '<style>' .. readFile('assets/pass/style.css') .. '</style>'
              .. '<div class="markdown-body">' .. hs.doc.markdown.convert(output) .. '</div>'

    local userContent = hs.webview.usercontent.new('openBrowser')

    userContent:setCallback(function(message)
        hs.execute("open '" .. message.body .. "'")
    end)

    userContent:injectScript({injectionTime = 'documentEnd', source = [[
        document.addEventListener("click", function(event){
            var link = event.target.closest("a");
            if (link && link.href) {
                webkit.messageHandlers.openBrowser.postMessage(link.href);
                event.preventDefault();
            }
        })
    ]]})

    if webview ~= nil then
        webview:delete()
        webview = nil
    end

    focused = hs.window.focusedWindow()
    webview = hs.webview.newBrowser(rect, {}, userContent)
    webview:shadow(true)
    webview:closeOnEscape(true)

    -- webview:windowCallback(function(action, webview)
    --     if action == 'closing' then
    --         focused:focus()
    --     end
    -- end)

    webview:html(html)
    webview:show()

    -- webview:hswindow():raise()
    -- webview:hswindow():focus()
    webview:bringToFront()

end

local chooserSelect = function(mode, choice)
    if tab then tab:delete() end
    if choice ~= nil then
        local name = choice.text

        -- Note that this is a bit finicky. Calling the `pass` command will
        -- trigger a pinentry dialog when needed, presuming pinentry-mac is
        -- installed, and it looks like the hs.chooser steals focus back
        -- from this dialog just after it's launched unless we add a small
        -- delay to make sure that the command happens after the chooser is
        -- closed instead of before.
        --
        -- Also, this uses a pbcopy pipeline instead of `pass show -c`
        -- because that seems to cause issues of its own (crash/beachball).
        -- A side effect of this is that the clipboard won't automatically
        -- be cleared, since `pass` usually handles that.

        hs.timer.doAfter(0.000001, function()
            if mode == 'show' then

                -- Show the contents of the password file in a window.
                local output, status = hs.execute("pass show " .. name .. " | tail +2", true)

                if status ~= nil then
                    showPassword(output)
                end

            elseif mode == 'copy' then

                -- Copy the password to the clipboard.
                local output, status = hs.execute("pass show " .. name .. " | head -1 | tr -d '\n'", true)

                if status ~= nil then
                    copyPassword(output, name, "Password")
                end

            elseif mode == 'copy-otp' then

                -- Copy the OTP to the clipboard.
                local output, status = hs.execute("pass otp " .. name .. " | tr -d '\n'", true)

                if status ~= nil then
                    copyPassword(output, name, "OTP")
                end

            elseif mode == 'copy-pass-and-otp' then

                -- Copy the password and OTP to the clipboard.
                local outputA, statusA = hs.execute("pass show " .. name .. " | head -1 | tr -d '\n'", true)
                local outputB, statusB = hs.execute("pass otp " .. name .. " | tr -d '\n'", true)

                if statusA ~= nil and statusB ~= nil then
                    local output = outputA .. "|" .. outputB
                    copyPassword(output, name, "Password and OTP")
                end

            end
        end)
    end
end

local chooserUpdate = function()
    local query = chooser:query()
    local path = os.getenv('HOME') .. '/.password-store'
    local results = ''

    if query:len() < 1 then
        choices = {}
    else
        choices = {}
        results = hs.execute("find " .. path .. " -name '*.gpg' | sed 's|" .. path .. '/' .. "||' | grep '^" .. query .. "' | sort")

        for s in results:gmatch('[^\n]+') do
            table.insert(choices, {text = s:sub(0, -5)})
        end
    end

    chooser:choices(choices)
end

local chooserComplete = function()
    local prefix = longestCommonPrefix(choices)
    local choice = chooser:selectedRowContents()
    local query = chooser:query()

    -- if prefix == chooser:query() then
    --     -- If we've tab-completed the longest prefix already then
    --     -- a 2nd tab-press should select the top item in the list.
    --     chooser:query(choice.text)
    -- else
    --     chooser:query(prefix)
    -- end

    chooser:query(prefix)
    chooserUpdate()
end

function searchPasswords(mode)
    tab = hs.hotkey.bind('', 'tab', chooserComplete)
    chooser = hs.chooser.new(partial(chooserSelect, mode))
    chooser:queryChangedCallback(chooserUpdate)
    chooser:placeholderText("Search for a password…")
    chooser:show()
end
