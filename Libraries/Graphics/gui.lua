local draw = require("graphics")
local event = require("event")
local thread = require("thread")
local uc = require("unicode")
local comp = require("component")
GPU = comp.proxy(comp.get("f26678f4"))
local colors = require("colors")

local gui, quit, editing = {}, false, false
local currentWindows = {}
local activeWindow
local keyInput, mouseInput, drag, inContextMenu
function checkCollision(x, y)
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

function contextMenu(GPU, x, y, data)
    function filterClicks(event)
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
    local contextWindow = createWindow(GPU, longestData, #data * 2, "ContextMenu" .. contextMenus)
    GPU.setActiveBuffer(contextWindow)
    draw.rect(GPU, 1, 1, longestData, #data * 2, colors.lightGray)
    for i = 1, #data do
        draw.text(GPU, 1, 1 + i * 2 - 2, colors.cyan, data[i])
    end
    currentWindows["ContextMenu" .. contextMenus].x = x
    currentWindows["ContextMenu" .. contextMenus].y = y
    GPU.setActiveBuffer(0)
end

function keyboardListener()
    function processKey(event, address, key, code, player)
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
    return event.listen("key_up", processKey)
end

function processCommand(GPU, window, option)
    local pageNumber = currentWindows[window].page
    if currentWindows["ColorBox"] == nil then
        createWindow(GPU, 10, 10, "ColorBox")
        currentWindows["ColorBox"].x = 10
        currentWindows["ColorBox"].y = 10
    end
    GPU.setActiveBuffer(currentWindows["ColorBox"].page)
    if option == 1 then
        draw.rect(GPU, 1, 1, 10, 10, colors.red)
    end
    if option == 2 then
        draw.rect(GPU, 1, 1, 10, 10, colors.blue)
    end
    if option == 3 then
        draw.rect(GPU, 1, 1, 10, 10, colors.green)
    end
    GPU.setActiveBuffer(0)
end

local i, xOffset, yOffset = 1, 0, 0
function mouseListener()
    function processClick(event, address, x, y, key, player)
        activeWindow = checkCollision(x, y)
        draw.text(GPU, 1, 1, colors.cyan, "Active window: " .. activeWindow)
        if key == 1.0 and editing then
            if inContextMenu then
                contextMenus = 0
            end
            contextMenu(GPU, x, y, {[1] = "Red", [2] = "Blue", [3] = "Green"})
        else
            if inContextMenu then
                local cont = currentWindows["ContextMenu1"]
                if x >= cont.x and x < cont.x + cont.w and y >= cont.y and y < cont.y + math.ceil(cont.h / 2) then
                    processCommand(GPU, activeWindow, y - cont.y + 1)
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
    return event.listen("touch", processClick)
end

function dragListener()
    function processDrag(event, address, x, y, key, player)
        if editing and inContextMenu == false then
            local window = currentWindows[activeWindow]
            currentWindows[activeWindow].x = x - xOffset
            currentWindows[activeWindow].y = y - yOffset
        end
    end
    return event.listen("drag", processDrag)
end

function dropListener()
    function processDrop(event, address, x, y, key, player)
    end
    return event.listen("drop", processDrop)
end

function createWindow(GPU, width, height, name)
    local pageNumber = GPU.allocateBuffer(width, math.ceil(height / 2))
    currentWindows[name] = {page = pageNumber, x = 1, y = 1, w = width, h = height}
    return pageNumber
end

function compose(GPU)
    local stateBuffer = currentWindows["State"].page
    GPU.setActiveBuffer(stateBuffer)
    if editing then
        copyWindow(GPU, 1, 1, currentWindows["Black"].page)
    end
    for window, params in pairs(currentWindows) do
        if params.w > 0 then
            copyWindow(GPU, params.x, params.y, params.page, stateBuffer)
        end
    end
    if inContextMenu then
        local cont = currentWindows["ContextMenu1"]
        copyWindow(GPU, cont.x, cont.y, cont.page)
    end
    GPU.setActiveBuffer(0)
end

function copyWindow(GPU, x, y, page, destination)
    destination = 0 or destination
    GPU.bitblt(destination, x, y, 160, 50, page, 1, 1)
end

--return gui

GPU = comp.proxy(comp.get("de837fec"))
screen = comp.get("48ce2988")
GPU.bind(screen)
GPU.freeAllBuffers()
keyInput, mouseInput, drag = keyboardListener(), mouseListener(), dragListener()
createWindow(GPU, 160, 100, "Black")
GPU.setActiveBuffer(currentWindows["Black"].page)
draw.rect(GPU, 1, 1, 160, 100, 0x000000)
currentWindows["Black"].w = 0
currentWindows["Black"].h = 0
GPU.setActiveBuffer(0)
createWindow(GPU, 160, 100, "State")
GPU.setActiveBuffer(currentWindows["State"].page)
draw.rect(GPU, 1, 1, 160, 100, 0x000000)
currentWindows["State"].w = 0
currentWindows["State"].h = 0
GPU.setActiveBuffer(0)
copyWindow(GPU, 1, 1, currentWindows["Black"].page)

while true do
    if quit then
        event.cancel(keyInput)
        break
    end
    compose(GPU)
    os.sleep(0.1)
end
