-- Import section
Machine = require("data.datasource.machines")
--

local function exec(address, name)
    local energyBuffer = Machine.getMachine(address, name)
    -- local comsumption = getConsumption(energyBuffer)
    -- local production = getProduction(energyBuffer)
    local consumption = energyBuffer:getAverageInput()
    local production = energyBuffer:getAverageOutput()
    local state = {name = "ON", color = Colors.workingColor}

    local changeRate = production - consumption

    local totalEnergy = energyBuffer:getTotalEnergy()
    local maximumEnergy = totalEnergy.maximum
    local currentEnergy = totalEnergy.current

    local energyLimit = changeRate > 0 and maximumEnergy or 0

    local timeToFull = changeRate > 0 and math.floor((energyLimit - currentEnergy) / changeRate) or nil
    local timeToEmpty = changeRate < 0 and math.floor((energyLimit - currentEnergy) / changeRate) or nil

    return {
        progress = currentEnergy,
        maxProgress = maximumEnergy,
        dProgress = changeRate,
        timeToFull = timeToFull,
        timeToEmpty = timeToEmpty,
        state = state
    }
end

return exec
