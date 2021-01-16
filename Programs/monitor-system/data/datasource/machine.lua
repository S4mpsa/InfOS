-- Import section
local mock = require("data.mock.mock-energy-provider")
EnergyProvider = require("data.datasource.energy-provider")
MultiBlock = require("data.datasource.multi-block")
Inherits = require("utils.inherits")
--

local machine = Inherits(EnergyProvider)
local machines = {}

machine.types = {
    energy = "energy",
    multiblock = "multiblock",
    singleblock = "singleblock"
}

machine.states = {
    ON = {name = "ON", color = Colors.workingColor},
    FULL = {name = "FULL", color = Colors.workingColor},
    IDLE = {name = "IDLE", color = Colors.idleColor},
    FILLING = {name = "FILLING", color = Colors.idleColor},
    OFF = {name = "OFF", color = Colors.offColor},
    DRAINING = {name = "DRAINING", color = Colors.offColor},
    BROKEN = {name = "BROKEN", color = Colors.errorColor},
    EMPTY = {name = "EMPTY", color = Colors.errorColor}
}

function machine.getMachine(address, name, type)
    if machines[address] then
        return machines[address]
    else
        local mach = {}
        if type == machine.types.energy then
            mach = EnergyProvider:new(address, name)
        elseif type == machine.types.multiblock then
            mach = MultiBlock:new(address, name)
        end
        machines[address] = mach
        return mach
    end
end

return machine
