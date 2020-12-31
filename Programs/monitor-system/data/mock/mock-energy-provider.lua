-- Import section
inherits = require("utils.inherits")
MockSingleBlock = require("data.mock.mock-single-block")
--

local MockEnergyProvider =
    inherits(
    MockSingleBlock,
    {
        name = "MockEnergyProvider"
    }
)

function MockEnergyProvider.getSensorInformation()
    return {
        "§9Insane Voltage Battery Buffer§r",
        "Stored Items:",
        "§a1,608,383,129§r EU / §e1,608,388,608§r EU",
        "Average input:",
        "11,396 EU/t",
        "Average output:",
        "11,158 EU/t",
        n = 7
    }
end

function MockEnergyProvider.getBatteryCharge(slot)
    return 1000
end

function MockEnergyProvider.getTotalEnergy()
    return 10000
end

return MockEnergyProvider
