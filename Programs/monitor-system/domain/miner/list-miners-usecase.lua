-- Import section
event = require("event")
local minerDatasource = require("data.datasource.miner")
--
local minerList = {}
local newMiners = {}

local function addToMinerList(_, address, machine)
    if minerDatasource.getName(machine.getSensorInformation()) == "Multiblock Miner" then
        if minerList[address] == nil then
            newMiners[address] = machine
        else
            newMiners[address] = nil
        end
        minerList[address] = machine
    end
end

event.listen("component_added", addToMinerList)

local function exec()
    return minerList, newMiners
end

return exec
