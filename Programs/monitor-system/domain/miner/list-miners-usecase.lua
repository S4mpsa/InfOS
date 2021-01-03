-- Import section
event = require("event")
local minerDatasource = require("data.datasource.miner")
local oneUp = require("resources.sound.mario-one-up")
--
local minerList = {}

local function addToMinerList(_, address, machine)
    if minerDatasource.getName(machine.getSensorInformation()) == "Multiblock Miner" then
        minerList[address] = machine
        oneUp()
    end
end

local function removeMinerFromList(_, address, machine)
    if minerDatasource.getName(machine.getSensorInformation()) == "Multiblock Miner" then
        minerList[address] = nil
    end
end

event.listen("touch", require("resources.sound.mario-one-up"))
event.listen("component_added", addToMinerList)
event.listen("component_removed", removeMinerFromList)

local function exec()
    return minerList
end

return exec
