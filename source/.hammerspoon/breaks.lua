local webview = nil
local enabled = true
local debug = false

local isLongBreak = function(t) return t.sec == 0 and t.min % 60 == 0 end
local isMiniBreak = function(t) return t.sec == 0 and t.min % 20 == 0 end

local isWeekDay = function(t) return t.wday > 1 and t.wday < 7 end
local isWeekDay = function(t) return true end
local isWorkingHours = function(t) return t.hour > 9 and t.hour < 18 end

local durations = {mini=20, long=300}

if debug then
    -- Debug predicates:
    local isLongBreak = function(t) return t.sec == 0 and t.min % 3 == 0 end
    local isMiniBreak = function(t) return t.sec == 0 and t.min % 1 == 0 end

    -- Debug durations:
    local durations = {mini=2,  long=30}
end

local suggestions = {

    -- These break ideas were borrowed and adapted from Stretchly.app:
    -- https://github.com/hovancik/stretchly/tree/master/app/utils

    mini={
        "Go grab a glass of water.",
        "Slowly look all the way left, then right.",
        "Slowly look all the way up, then down.",
        "Close your eyes and take few deep breaths.",
        "Close your eyes and relax.",
        "Stretch your legs.",
        "Stretch your arms.",
        "Is your sitting posture correct?",
        "Slowly turn head to side and hold for 10 seconds.",
        "Slowly tilt head to side and hold for 5-10 seconds.",
        "Stand from your chair and stretch.",
        "Refocus your eyes on an object at least 20 meters away.",
        "Take a moment to think about something you appreciate.",
        "Take a moment to smile at being alive.",
        "A truly ergonomic workstation is one that you regularly push away from.",
        "Close your eyes and count your breaths.",
        "Close your eyes and name the things you hear.",
        "Place your fingertips on your shoulders. Roll your shoulders forward for 10 seconds, then backward.",
        "Raise your right arm, stretch it over your head to the left, and hold for 10 seconds. Repeat on the other side.",
        "With your right hand, grab each finger of your left hand in turn and squeeze. Repeat on the other side.",
        "Stand up and do a lunge. Hold for 10 seconds, then do the other leg.",
        "Close your eyes and simply notice whatever arises in current moment, without judgement.",
        "One should focus every 20 minutes for 20 seconds on an object that is 20 feet distance.",
        "If you need help, ask for it.",
        "Do one thing at a time.",
    },

    long={
        "Try taking a break with a companion. Taking breaks together can increase productivity and make it easier to stick to breaks.",
        "Do you ever notice how your brain can figure things out by itself? All it takes is to step away from the computer and take a break to think about something totally unrelated.",
        "Rest is a key component in ensuring the performance of the musculoskeletal system. Frequent breaks can decrease the duration of a task and help lower the exposure to ergonomic injury risk.",
        "Research studies suggest that mindfulness-based exercises help decrease anxiety, depression, stress, and pain, and help improve general health, mental health, and quality of life. Not sure how to start? There are numerous apps to help you out.",
        "Looking at screens for a long time causes you to blink less, thus exposing your eyes to the air. Blink rapidly for a few seconds to refresh the tear film and clear dust from the eye surface.",
        "Improper height and angle of the keyboard, mouse, monitor or working surface can cause health problems. Take some time to read about desk ergonomics.",
        "There are a lot of ways you can exercise within your office. Try marching in place or doing desk push-ups.",
        "Do you have a stability ball or standing work desk? Consider replacing your desk chair with them for a while.",
        "Daydreaming or having trouble focusing can be a sign that you need to take a break.",
        "How about going for a walk without your phone?",
        "Sitting for long periods of time is bad for your health. Taking regular walking breaks can help your circulation.",
        "How about moving meetings from the conference room to the concourse? Walking not only burns calories but it may even foster a sense of collaboration.",
        "How about a healthy snack? Maybe some fruit or nuts.",
        "Try building a little bit of exercise into your bathroom breaks.",
        "Going on coffee break? Consider doing a 5-minute walk every time you go for one.",
        "Don't email or message office colleagues, walk to their desks to communicate with them.",
        "Researchers have found that taking short breaks, early and often, can help our brains learn new skills.",
        "Evidence suggests small amounts of regular exercise can bring dramatic health benefits, including measurably reducing stress.",
        "Have you found your break routine? Don't forget to repeat it more than once to better fight effects of prolonged sitting.",
        "Extend your arms with the palms facing towards you, then slowly rotate the hands four times clockwise, then four times counter-clockwise.",
        "Join your hands behind your head, then lift them together up above your head ending with your palms facing upward.",
        "For every thirty minutes of stagnation, you should have at least one minute of stimulation.",
        "Raise your pulse rate to 120 beats per minute for 20 straight minutes four or five times a week doing anything you enjoy. Regularly raising your heart rate results in improved cardiovascular health.",
        "Studies have shown that climbing the stairs, which is considered vigorous-intensity physical activity, burns more calories per minute than jogging.",
        "Art therapy is known to have great mental health benefits, especially when it comes to stress management. How about writing a quick poem, taking a picture or painting something small?",
        "A clean space helps your focus at work and is often linked to positive emotions like happiness.",
        "Nature is linked to positive emotions and decreased stress and anxiety. Whenever possible, try to take your daily lunch break outside, surrounded by some greenery.",
    }
}

local breakReminderShow = function(breakType)
    local textCount = #suggestions[breakType]
    local textIndex = math.random(textCount - 1)
    local text = suggestions[breakType][textIndex]
    local secs = durations[breakType]

    local unit = hs.geometry.unitrect(0, 0, 1, 1)
    local rect = unit:fromUnitRect(hs.screen.find(SCREEN_MACBOOK):fullFrame())
    local html = '<link href="https://fonts.googleapis.com/css2?family=Merriweather:wght@300;400;700&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">'
              .. '<style>' .. readFile('assets/breaks/style.css') .. '</style>'
              .. '<div class="break-reminder"><div class="break-reminder-text">' .. text .. '</div></div>'

    if webview then
        webview:delete()
    end

    hs.notify.show('Break reminder', '', 'Time to take a ' .. breakType .. ' break')

    webview = hs.webview.new(rect)
    webview:deleteOnClose(true)

    webview:html(html)
    webview:show()
    webview:bringToFront(true)

    hs.timer.doAfter(secs, function()
        if webview then
            webview:delete()
        end
    end)
end

local breakReminderTest = function()
    local t = os.date('*t')

    if debug then
        print(string.format('%02d:%02d:%02d', t.hour, t.min, t.sec), enabled, isWeekDay(t), isWorkingHours(t), isLongBreak(t), isMiniBreak(t))
    end

    if enabled and isWeekDay(t) and isWorkingHours(t) then
        if isLongBreak(t) then
            breakReminderShow('long')
        elseif isMiniBreak(t) then
            breakReminderShow('mini')
        end
    end
end

function toggleBreaks(modifiers, menuItem)
    enabled = not enabled
    if enabled then
        hs.notify.show('Break reminder', '', 'Break reminders turned on')
    else
        hs.notify.show('Break reminder', '', 'Break reminders turned off')
    end
    menuItem.checked = enabled
    menuBarUpdate()
end

hs.timer.doEvery(1, breakReminderTest)
