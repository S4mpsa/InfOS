-- Import section
local component = require("component")
local mock = require("data.mock.mock-single-block")
--

local SingleBlock = {
    mock = mock,
    name = "SingleBlock"
}

function SingleBlock:setWorkAllowed(allow)
    self.block.setWorkAllowed(allow)
end

function SingleBlock:isWorkAllowed()
    return self.block.isWorkAllowed()
end

function SingleBlock:getAverageElectricInput()
    return self.block.getAverageElectricInput()
end

function SingleBlock:getOwnerName()
    return self.block.getOwnerName()
end

function SingleBlock:getEUStored()
    return self.block.getEUStored()
end

function SingleBlock:getWorkMaxProgress()
    return self.block.getWorkMaxProgress()
end

function SingleBlock:getSensorInformation()
    return self.block.getSensorInformation()
end

function SingleBlock:getEUOutputAverage()
    return self.block.getEUOutputAverage()
end

function SingleBlock:getEUInputAverage()
    return self.block.getEUInputAverage()
end

function SingleBlock:getStoredEU()
    return self.block.getStoredEU()
end

function SingleBlock:isMachineActive()
    return self.block.isMachineActive()
end

function SingleBlock:getOutputVoltage()
    return self.block.getOutputVoltage()
end

function SingleBlock:getAverageElectricOutput()
    return self.block.getAverageElectricOutput()
end

function SingleBlock:hasWork()
    return self.block.hasWork()
end

function SingleBlock:getOutputAmperage()
    return self.block.getOutputAmperage()
end

function SingleBlock:getEUCapacity()
    return self.block.getEUCapacity()
end

function SingleBlock:getWorkProgress()
    return self.block.getWorkProgress()
end

function SingleBlock:getEUMaxStored()
    return self.block.getEUMaxStored()
end

function SingleBlock:new(partialAdress)
    local machine = {}
    setmetatable(machine, self)

    if (partialAdress == "") then
        partialAdress = nil
    end

    local successfull =
        pcall(
        function()
            machine.block = component.proxy(component.get(partialAdress))
        end
    )
    if (not successfull) then
        machine.block = self.mock:new()
    end

    return machine
end

return SingleBlock
