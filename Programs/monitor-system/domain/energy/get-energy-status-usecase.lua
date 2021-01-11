-- Import section
local getConsumption = require("domain.energy.get-consumption-usecase")
local getProduction = require("domain.energy.get-production-usecase")
--

local function exec(energyBuffer)
    -- local comsumption = getConsumption(energyBuffer)
    -- local production = getProduction(energyBuffer)
    local consumption = energyBuffer:getAverageInput()
    local production = energyBuffer:getAverageOutput()

    local changeRate = production - consumption

    local totalEnergy = energyBuffer:getTotalEnergy()
    local maximumEnergy = totalEnergy.maximum
    local currentEnergy = totalEnergy.current

    local energyLimit = changeRate > 0 and maximumEnergy or 0

    local timeToFull = changeRate > 0 and (energyLimit - currentEnergy) / changeRate or nil
    local timeToEmpty = changeRate < 0 and (energyLimit - currentEnergy) / changeRate or nil

    return {
        consumption = consumption,
        production = production,
        timeToFull = timeToFull,
        timeToEmpty = timeToEmpty
    }
end

return exec
