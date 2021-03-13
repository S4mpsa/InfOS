Graphics = require("graphics.graphics")
Event = require("event")
local uc = require("unicode")
Component = require("component")
GPU = Component.gpu
Colors = require("colors")

local gui, quit, editing = {}, false, false
local currentWindows = Graphics.currentWindows
local activeWindow
local keyInput, mouseInput, drag, inContextMenu

function gui.checkCollision(x, y)
    for window, params in pairs(currentWindows) do
        if x >= params.x and x <= params.x + params.w - 1 then
            if y >= params.y and y <= params.y + math.ceil(params.h / 2) - 1 then
                return window
            end
        end
    end
    return nil
end

local contextMenus = 0

function gui.contextMenu (GPU, x, y, data)
    local function filterClicks(event)
        return event == "touch"
    end
    inContextMenu = true
    contextMenus = contextMenus + 1
    local longestData = 0
    for i, data in pairs(data) do
        if #data > longestData then
            longestData = #data
        end
    end
    local contextWindow = gui.createWindow(GPU, longestData, #data * 2, "ContextMenu" .. contextMenus)
    GPU.setActiveBuffer(contextWindow)
    Graphics.rectangle(GPU, 1, 1, longestData, #data * 2, Colors.lightGray)
    for i = 1, #data do
        Graphics.text(GPU, 1, 1 + i * 2 - 2, Colors.cyan, data[i])
    end
    currentWindows["ContextMenu" .. contextMenus].x = x
    currentWindows["ContextMenu" .. contextMenus].y = y
    GPU.setActiveBuffer(0)
end

function gui.keyboardListener ()
    local function processKey(event, address, key, code, player)
        local value = uc.char(key)
        if value == "." then
            quit = true
        end
        if value == "e" then
            if editing then
                editing = false
            else
                editing = true
            end
        end
    end
    return Event.listen("key_up", processKey)
end

function gui.processCommand(GPU, window, option)
    local pageNumber = currentWindows[window].page
    if currentWindows["ColorBox"] == nil then
        Graphics.createWindow(GPU, 10, 10, "ColorBox")
        currentWindows["ColorBox"].x = 10
        currentWindows["ColorBox"].y = 10
    end
    GPU.setActiveBuffer(currentWindows["ColorBox"].page)
    if option == 1 then
        Graphics.rectangle(GPU, 1, 1, 10, 10, Colors.red)
    end
    if option == 2 then
        Graphics.rectangle(GPU, 1, 1, 10, 10, Colors.blue)
    end
    if option == 3 then
        Graphics.rectangle(GPU, 1, 1, 10, 10, Colors.green)
    end
    GPU.setActiveBuffer(0)
end

local i, xOffset, yOffset = 1, 0, 0
function gui.mouseListener()
    local function processClick(event, address, x, y, key, player)
        activeWindow = gui.checkCollision(x, y)
        Graphics.text(GPU, 1, 1, Colors.cyan, "Active window: " .. activeWindow)
        if key == 1.0 and editing then
            if inContextMenu then
                contextMenus = 0
            end
            gui.contextMenu(GPU, x, y, {[1] = "Red", [2] = "Blue", [3] = "Green"})
        else
            if inContextMenu then
                local cont = currentWindows["ContextMenu1"]
                if x >= cont.x and x < cont.x + cont.w and y >= cont.y and y < cont.y + math.ceil(cont.h / 2) then
                    gui.processCommand(GPU, activeWindow, y - cont.y + 1)
                else
                    inContextMenu = false
                    for j = 1, contextMenus do
                        currentWindows["ContextMenu" .. j] = nil
                    end
                    contextMenus = 0
                end
            else
                if activeWindow ~= "None                " then
                end
                xOffset = x - currentWindows[activeWindow].x
                yOffset = y - currentWindows[activeWindow].y
            end
        end
    end
    return Event.listen("touch", processClick)
end

function gui.dragListener()
    local function processDrag(event, address, x, y, key, player)
        if editing and inContextMenu == false then
            local window = currentWindows[activeWindow]
            currentWindows[activeWindow].x = x - xOffset
            currentWindows[activeWindow].y = y - yOffset
        end
    end
    return Event.listen("drag", processDrag)
end

function gui.dropListener()
    local function processDrop(event, address, x, y, key, player)
    end
    return Event.listen("drop", processDrop)
end

function gui.compose(GPU)
    local stateBuffer = currentWindows["State"].page
    GPU.setActiveBuffer(stateBuffer)
    if editing then
        Graphics.copyWindow(GPU, 1, 1, currentWindows["Black"].page)
    end
    for window, params in pairs(currentWindows) do
        if params.w > 0 then
            Graphics.copyWindow(GPU, params.x, params.y, params.page, stateBuffer)
        end
    end
    if inContextMenu then
        local cont = currentWindows["ContextMenu1"]
        Graphics.copyWindow(GPU, cont.x, cont.y, cont.page)
    end
    GPU.setActiveBuffer(0)
end


GPU.freeAllBuffers()
keyInput, mouseInput, drag = gui.keyboardListener(), gui.mouseListener(), gui.dragListener()
Graphics.createWindow(GPU, 160, 100, "Black")
GPU.setActiveBuffer(currentWindows["Black"].page)
Graphics.rectangle(GPU, 1, 1, 160, 100, 0x000000)
currentWindows["Black"].w = 0
currentWindows["Black"].h = 0
GPU.setActiveBuffer(0)
Graphics.createWindow(GPU, 160, 100, "State")
GPU.setActiveBuffer(currentWindows["State"].page)
Graphics.rectangle(GPU, 1, 1, 160, 100, 0x000000)
currentWindows["State"].w = 0
currentWindows["State"].h = 0
GPU.setActiveBuffer(0)
Graphics.copyWindow(GPU, 1, 1, currentWindows["Black"].page)

while true do
    if quit then
        Event.cancel(keyInput)
        break
    end
    gui.compose(GPU)
    os.sleep(0.1)
end

return gui
