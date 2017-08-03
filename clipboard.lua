-- based on https://github.com/victorso/.hammerspoon/blob/master/tools/clipboard.lua
-- based on https://aldur.github.io/articles/hammerspoon-emojis/

local pasteboard = require("hs.pasteboard")
local history = {}
local historySize = 10
local lastChange = pasteboard.changeCount()
local now = lastChange
local register = {}

local function focusLastFocused()
    local filter = hs.window.filter
    local lastFocused = filter.defaultCurrentSpace:getWindows(filter.sortByFocusedLast)
    if #lastFocused > 0 then
        lastFocused[1]:focus()
    end
end

local chooser = hs.chooser.new(function (choice)
    if choice then
        pasteboard.setContents(choice.text)
    end
    focusLastFocused()
    hs.eventtap.keyStroke({"cmd"}, "v")
end)

function clearSizeOver()
    while (#history >= historySize) do
        table.remove(history, #history)
    end
end

function storeCopy()

    clearSizeOver()

    now = pasteboard.changeCount()

    if not (now > lastChange) then
        return
    end

    local content = pasteboard.getContents()

    if #history < 1 or not (history[#history].text == content) then
        table.insert(history, 1, {text = content})
    end
    lastChange = now
end

copy = hs.hotkey.bind({"cmd"}, "c", function()
    copy:disable()
    hs.eventtap.keyStroke({"cmd"}, "c")
    copy:enable()
    hs.timer.doAfter(0.1, storeCopy)
end)

local obj = {}

function obj.showList()
    chooser:choices(history)
    chooser:show()
end

function obj.clear()
    history = {}
    now = pasteboard.changeCount()
    chooser:cancel()
    focusLastFocused()
end

function obj.setSize(num)
    historySize = num
end

return obj
