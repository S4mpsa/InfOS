component = require("component")
computer = require("computer")

function cycle()
    component.redstone.setOutput(2, 15)
    os.sleep(1)
    component.redstone.setOutput(2, 0)
end

component.gpu.setResolution(80, 40)

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

function setDestination(destination)
end

function unload(index)
    local transposer = component.transposer
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
function copyWindow(GPU, x, y, page, destination)
    destination = 0 or destination
    GPU.bitblt(destination, x, y, 160, 46, page, 1, 1)
end
windows = {}
function doStartupSequence()
    local gpu = component.gpu
    gpu.freeAllBuffers()
    local colors = {
        [0] = colors.steelBlue,
        [1] = colors.black
    }
    local buffer = gpu.allocateBuffer()
    gpu.setActiveBuffer(buffer)
    for i = 2, 20, 1 do
        if i % 2 == 0 then
            copyWindow(gpu, 0, 0, buffer, 0)
        end
        gpu.setForeground(colors[i % 2])
        component.gpu.fill(2 + i * 2, 1 + i, 80 - i * 4, 40 - i * 2, "█")
        os.sleep(0.1)
    end
    gpu.setActiveBuffer(0)
    os.sleep(0.5)
    gpu.setForeground(0x000000)
    gpu.fill(0, 0, 100, 50, "█")
    gpu.setForeground(0xFFFFFF)
end
local starting = false
function send()
    local transposer = component.transposer
    if transposer.getStackInSlot(controller, 1) == nil then
        --screen.write("The operating cell is missing!\n")
    else
        doStartupSequence()
        cycle()
        os.sleep(0.2)
        transposer.transferItem(controller, sending, 1, 2, 1)
    end
end
function checkArrivals()
    local transposer = component.transposer
    for i = 1, 26 do
        if transposer.getStackInSlot(incoming, i) ~= nil then
            return i
        end
    end
    return 0
end
local lastActivation = 0
function setStarting()
    starting = false
end
function activateTeleporter()
    if starting == false then
        starting = true
        send()
        event.timer(10, setStarting)
    end
    lastActivation = computer.uptime()
end
event.listen("walk", activateTeleporter)
component.gpu.fill(0, 0, 100, 50, " ")
while true do
    local arrival = checkArrivals()
    if arrival ~= 0 then
        starting = true
        event.timer(10, setStarting)
        unload(arrival)
    end
    os.sleep(0.5)
end
