-- Import section
local mock = require("data.mock.mock-energy-provider")
EnergyProvider = require("data.datasource.energy-provider")
Inherits = require("utils.inherits")
--

local machine = Inherits(EnergyProvider)
local machines = {}
machine.types = {
    energy = "energy",
    multiblock = "multiblock",
    singleblock = "singleblock"
}

function machine.getMachine(address, name, type)
    if machines[address] then
        return machines[address]
    else
        local mach = {}
        if type == machine.types.energy then
            print(machine.name)
        elseif type == machine.types.multiblock then
        end
        mach = machine:new(address, name)
        machines[address] = mach
        return mach
    end
end

return machine
