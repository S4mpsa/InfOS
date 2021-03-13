-- Import section
New = require("utils.new")
--

local MockSingleBlock = {
    name = "MockSingleBlock",
    workAllowed = true,
    workProgress = 3,
    workMaxProgress = 4,
    storedEU = 1234,
    active = true,
    outputVoltage = 0,
    outputAmperage = 1,
    EUCapacity = 2048
}

function MockSingleBlock.setWorkAllowed(allow)
    MockSingleBlock.workAllowed = allow
end

function MockSingleBlock.isWorkAllowed()
    return MockSingleBlock.workAllowed
end

function MockSingleBlock.getAverageElectricInput()
    return 0.0
end

function MockSingleBlock.getOwnerName()
    return "gordominossi"
end

function MockSingleBlock.getEUStored()
    return MockSingleBlock.storedEU
end

function MockSingleBlock.getWorkMaxProgress()
    return MockSingleBlock.workMaxProgress
end

function MockSingleBlock.getSensorInformation()
    return {
        "§9gt.recipe.laserengraver§r",
        "Progress:",
        "§a2§r s / §e5§r s",
        "Stored Energy:",
        "§a1000§r EU / §e1000§r EU",
        "Probably uses: §c0§r EU/t at §c0§r A",
        n = 6
    }
end

function MockSingleBlock.getEUOutputAverage()
    return MockSingleBlock.EUOutputAverage
end

function MockSingleBlock.getEUInputAverage()
    return MockSingleBlock.EUInputAverage
end

function MockSingleBlock.getStoredEU()
    return MockSingleBlock.storedEU
end

function MockSingleBlock.isMachineActive()
    return MockSingleBlock.active
end

function MockSingleBlock.getOutputVoltage()
    return MockSingleBlock.outputVoltage
end

function MockSingleBlock.getAverageElectricOutput()
    return 0.0
end

function MockSingleBlock.hasWork()
    return MockSingleBlock.workProgress < MockSingleBlock.workMaxProgress
end

function MockSingleBlock.getOutputAmperage()
    return MockSingleBlock.outputAmperage
end

function MockSingleBlock.getEUCapacity()
    return MockSingleBlock.EUCapacity
end

function MockSingleBlock.getWorkProgress()
    return MockSingleBlock.workProgress
end

function MockSingleBlock.getEUMaxStored()
    return MockSingleBlock.EUCapacity
end

MockSingleBlock.__index = MockSingleBlock

function MockSingleBlock:new()
    return New(self)
end

function MockSingleBlock:getEfficiencyPercentage()
    return 100
end

return MockSingleBlock
