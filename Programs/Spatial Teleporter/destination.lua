destinations = {
    [1] = {name = "Earth", id = 3001, color = 0xFF0022},
    [2] = {name = "Pluto", id = 3002, color = 0x22FF00},
    [3] = {name = "Venus", id = 3003},
    [4] = {name = "Piky's Base", id = 2000, color = 0xFF7800},
    [5] = {name = "Test", id = 3004},
    [6] = {name = "Test", id = 3004}
}

local util = require("utility")
graphics = require("graphics")
local GPU = component.gpu
GPU.setResolution(80, 25)

local boundingBoxes = {}
function createDestination(x, y, index)
    local width, height = 18, 6
    local page = GPU.allocateBuffer(width, math.ceil(height / 2))
    GPU.setActiveBuffer(page)
    graphics.rectangle(GPU, 1, 1, 18, 6, 0x111111)
    local destinationColor = destinations[index].color or 0x0055FF
    graphics.rectangle(GPU, 3, 3, 14, 2, 0x000000)
    graphics.centeredText(GPU, 10, 3, destinationColor, destinations[index].name)
    windows[index] = {GPU = GPU, page = page, address = "", x = x, y = y, w = width, h = height}
    GPU.setActiveBuffer(0)
end
function setDestination(code)
    for address, type in pairs(component.list()) do
        if type == "ender_chest" then
            util.machine(address).setFrequency(code)
        end
    end
end
function checkClick(_, address, x, y, button, name)
    for i = 1, #boundingBoxes, 1 do
        local xb, yb = boundingBoxes[i].x, math.ceil(boundingBoxes[i].y / 2)
        if x >= xb and x < xb + 21 and y >= yb and y < yb + 3 then
            graphics.rectangle(GPU, boundingBoxes[i].x + 2, boundingBoxes[i].y + 2, 14, 2, 0x00CC00)
            local destinationColor = destinations[i].color or 0x0055FF
            setDestination(destinations[i].id)
            graphics.rectangle(GPU, 30, 43, 22, 2, 0x000000)
            graphics.centeredText(GPU, 40, 43, destinationColor, destinations[i].name)
            event.timer(0.2, graphics.update)
            return i
        end
    end
end
function addBoundingBox(index)
    boundingBoxes[index] = {x = 2 + ((index - 1) % 5) * 20, y = 3 + math.floor((index - 1) / 4) * 8}
end
function getDestination()
    for address, type in pairs(component.list()) do
        if type == "ender_chest" then
            return util.machine(address).getFrequency()
        end
    end
end
event.listen("touch", checkClick)
GPU.freeAllBuffers()
GPU.fill(0, 0, 100, 100, " ")
graphics.rectangle(GPU, 28, 41, 26, 6, 0x111111)
graphics.rectangle(GPU, 30, 43, 22, 2, 0x000000)
graphics.text(GPU, 31, 39, 0xFFFFFF, "Current  Destination")
for i = 1, #destinations, 1 do
    addBoundingBox(i)
    createDestination(boundingBoxes[i].x, boundingBoxes[i].y, i)
    graphics.update()
end
while true do
    os.sleep()
end
