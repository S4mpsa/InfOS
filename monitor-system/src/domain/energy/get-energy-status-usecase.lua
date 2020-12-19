-- Import section
local getConsumption = require("domain.energy.get-consumption-usecase")
local getProduction = require("domain.energy.get-production-usecase")
--

local function exec(energyProducers, energyBuffer)
    -- local comsumption = getConsumption(energyBuffer)
    -- local production = getProduction(energyBuffer)
    local consumption = energyBuffer:getAverageInput()
    local production = energyBuffer:getAverageOutput()
    local energyCapacity = energyBuffer:getTotalEnergy().maximum
    local timeToFull = energyCapacity / (production - consumption)
    local timetoEmpty = -timeToFull
    return {
        consumption = consumption,
        production = production,
        timeToFull = timeToFull,
        timetoEmpty = timetoEmpty
    }
end

return exec
