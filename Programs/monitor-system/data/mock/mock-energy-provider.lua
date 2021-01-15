-- Import section
Inherits = require("utils.inherits")
MockSingleBlock = require("data.mock.mock-single-block")
Utility = require("utils.utility")
--

local MockEnergyProvider =
    Inherits(
    MockSingleBlock,
    {
        name = "MockEnergyProvider"
    }
)

local progress = math.random(1608388608)
local input = math.random(16000)
local output = math.random(16000)
function MockEnergyProvider.getSensorInformation()
    input = input + math.random(-100, 100)
    output = input + math.random(-100, 100)
    progress = progress + input - output > 0 and progress + input - output or 0
    return {
        "§9Insane Voltage Battery Buffer§r",
        "Stored Items:",
        "§a" .. Utility.splitNumber(progress) .. "§r EU / §e1,608,388,608§r EU",
        "Average input:",
        Utility.splitNumber(input) .. " EU/t",
        "Average output:",
        Utility.splitNumber(output) .. " EU/t",
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
