-- Import section
Parser = require("utils.parser")
Inherits = require("utils.inherits")
SingleBlock = require("data.datasource.single-block")
local mock = require("data.mock.mock-energy-provider")
--

local EnergyProvider =
    Inherits(
    SingleBlock,
    {
        mock = mock,
        name = "EnergyProvider"
    }
)

function EnergyProvider:getBatteryCharge(slot)
    return self.block.getBatteryCharge(slot)
end

function EnergyProvider:getAllBatteryCharges()
    local batteryCharges = {}
    local i = 1
    while true do
        local successfull =
            pcall(
            function()
                table.insert(batteryCharges, self:getBatteryCharge(i))
            end
        )
        if (not successfull) then
            return batteryCharges
        end

        i = i + 1
    end
end

function EnergyProvider:getBatteryChargesSum()
    local batterySum = 0
    local i = 1
    while true do
        local successfull =
            pcall(
            function()
                batterySum = batterySum + self:getBatteryCharge(i)
            end
        )
        if (not successfull) then
            return batterySum
        end

        i = i + 1
    end
end

function EnergyProvider:getTotalEnergy()
    local sensorInformation = self:getSensorInformation()
    return Parser.parseStoredEnergy(sensorInformation[3])
end

function EnergyProvider:getAverageInput()
    local sensorInformation = self:getSensorInformation()
    return Parser.parseAverageInput(sensorInformation[5])
end

function EnergyProvider:getAverageOutput()
    local sensorInformation = self:getSensorInformation()
    return Parser.parseAverageOutput(sensorInformation[7])
end

return EnergyProvider
