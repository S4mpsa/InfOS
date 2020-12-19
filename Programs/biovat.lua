local comp = require("component")
local event = require("event")
local screen = require("term")
local computer = require("computer")

local transposers = {}
function configureTransposers()
    for address, type in pairs(comp.list()) do
        if type == "transposer" then
            local transposer = comp.proxy(comp.get(address))
            local foundTanks = {}
            for side = 0, 5, 1 do
                if transposer.getTankCapacity(side) > 0 then
                    foundTanks[#foundTanks + 1] = {side = side, capacity = transposer.getTankCapacity(side)}
                end
            end
            if #foundTanks == 2 then
                if foundTanks[1].capacity > foundTanks[2].capacity then
                    transposers[address] = {source = foundTanks[2].side, sink = foundTanks[1].side}
                else
                    transposers[address] = {source = foundTanks[1].side, sink = foundTanks[2].side}
                end
            else
                screen.write("Some transposers have more than two tanks! FIX IT!\n")
            end
        end
    end
    screen.write("Found " .. countTransposers() .. " output hatches to keep at 50%\n")
end
function countTransposers()
    local count = 0
    for address, type in pairs(comp.list()) do
        if type == "transposer" then
            count = count + 1
        end
    end
    return count
end
function tick()
    for address, sides in pairs(transposers) do
        local transposer = comp.proxy(comp.get(address))
        local sourceCurrent, sourceMax = transposer.getTankLevel(sides.source), transposer.getTankCapacity(sides.source)
        if sourceCurrent / sourceMax > 0.5 then
            local fluidToRemove = sourceCurrent - sourceMax / 2
            transposer.transferFluid(sides.source, sides.sink, fluidToRemove)
        end
    end
end
configureTransposers()
local count = countTransposers()
local tempCount = 0
while true do
    tempCount = countTransposers()
    if count ~= tempCount then
        configureTransposers()
    end
    count = tempCount
    tick()
    os.sleep()
end
