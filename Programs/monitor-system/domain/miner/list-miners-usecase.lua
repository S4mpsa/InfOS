-- Import section
Event = require("event")
local minerDatasource = require("data.datasource.miner")
local oneUp = require("api.sound.mario-one-up")
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

Event.listen("touch", oneUp)
Event.listen("component_added", addToMinerList)
Event.listen("component_removed", removeMinerFromList)

local function exec()
    return minerList
end

return exec
