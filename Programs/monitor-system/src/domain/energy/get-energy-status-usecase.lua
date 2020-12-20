-- Import section
local getConsumption = require("get-consumption-usecase")
local getProduction = require("get-production-usecase")
--

local function exec(energyProducers, energyBuffer)
    -- local comsumption = getConsumption(energyBuffer)
    -- local production = getProduction(energyBuffer)
    local consumption = energyBuffer:getAverageInput()
    local production = energyBuffer:getAverageOutput()
    local energyCapacity = energyBuffer:getTotalEnergy().maximum
    local timeToFull = (production - consumption) ~= 0 and energyCapacity / (production - consumption) or "-"
    return {
        consumption = consumption,
        production = production,
        timeToFull = timeToFull,
    }
end

return exec
