-- Import section
local mock = require("data.mock.mock-energy-provider")
EnergyProvider = require("data.datasource.energy-provider")
Inherits = require("utils.inherits")
--

local machine =
    Inherits(
    EnergyProvider,
    {
        mock = mock,
        name = "Generic Machine"
    }
)
local machines = {}

function machine.getMachine(address, name)
    if machines[address] then
        return machines[address]
    else
        local mach = machine:new(address, name)
        machines[address] = mach
        return mach
    end
end

return machine
