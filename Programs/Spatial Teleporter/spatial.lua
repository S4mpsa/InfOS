Component = require("component")
Computer = require("computer")
Graphics = require("graphics.graphics")
GPU = Component.gpu

local function cycle()
    Component.redstone.setOutput(2, 15)
    os.sleep(1)
    Component.redstone.setOutput(2, 0)
end

Component.gpu.setResolution(80, 40)

local incoming = 4
local sending = 3
local controller = 5
local ticket = 1
--while true do
--    a, b, c = event.pull()
--    if a == "walk" then
--        screen.write("Screen walked on")
--    end
--end

local function setDestination(destination)
end

local function unload(index)
    local transposer = Component.transposer
    if transposer.getStackInSlot(controller, 1) ~= nil then
        --Using a return ticket
        cycle()
        os.sleep(0.2)
        --Move cell out of the way
        transposer.transferItem(controller, incoming, 1, 2, 27)
        os.sleep(0.2)
        --Insert incoming arrival
        transposer.transferItem(incoming, controller, 1, index, 1)
        os.sleep(0.2)
        --Unload arrival
        cycle()
        os.sleep(0.2)
        --Return ticket
        transposer.transferItem(controller, ticket, 1, 2, 1)
        --Return operating cell
        transposer.transferItem(incoming, controller, 1, 27, 1)
    else
        --Normal operation
        transposer.transferItem(incoming, controller, 1, index, 1)
    end
end
Graphics.windows = {}
local function doStartupSequence()
    GPU.freeAllBuffers()
    local colors = {
        [0] = Colors.steelBlue,
        [1] = Colors.black
    }
    local buffer = GPU.allocateBuffer()
    GPU.setActiveBuffer(buffer)
    for i = 2, 20, 1 do
        if i % 2 == 0 then
            Graphics.copyWindow(GPU, 0, 0, buffer, 0)
        end
        GPU.setForeground(colors[i % 2])
        Component.gpu.fill(2 + i * 2, 1 + i, 80 - i * 4, 40 - i * 2, "█")
        os.sleep(0.1)
    end
    GPU.setActiveBuffer(0)
    os.sleep(0.5)
    GPU.setForeground(0x000000)
    GPU.fill(0, 0, 100, 50, "█")
    GPU.setForeground(0xFFFFFF)
end
local starting = false
local function send()
    local transposer = Component.transposer
    if transposer.getStackInSlot(controller, 1) == nil then
        --screen.write("The operating cell is missing!\n")
    else
        doStartupSequence()
        cycle()
        os.sleep(0.2)
        transposer.transferItem(controller, sending, 1, 2, 1)
    end
end
local function checkArrivals()
    local transposer = Component.transposer
    for i = 1, 26 do
        if transposer.getStackInSlot(incoming, i) ~= nil then
            return i
        end
    end
    return 0
end
local lastActivation = 0
local function setStarting()
    starting = false
end
local function activateTeleporter()
    if starting == false then
        starting = true
        send()
        Event.timer(10, setStarting)
    end
    lastActivation = Computer.uptime()
end
Event.listen("walk", activateTeleporter)
Component.gpu.fill(0, 0, 100, 50, " ")
while true do
    local arrival = checkArrivals()
    if arrival ~= 0 then
        starting = true
        Event.timer(10, setStarting)
        unload(arrival)
    end
    os.sleep(0.5)
end
