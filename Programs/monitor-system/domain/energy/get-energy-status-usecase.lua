-- Import section
Machine = require("data.datasource.machine")
--

local function exec(address, name)
    local energyBuffer = Machine.getMachine(address, name, Machine.types.energy)

    local consumption = energyBuffer:getAverageInput()
    local production = energyBuffer:getAverageOutput()
    local changeRate = production - consumption

    local totalEnergy = energyBuffer:getTotalEnergy()
    local maximumEnergy = totalEnergy.maximum
    local currentEnergy = totalEnergy.current

    local energyLimit = changeRate > 0 and maximumEnergy or 0

    local state = {}
    if (currentEnergy == maximumEnergy) then
        state = {name = changeRate .. " EU/s", color = Colors.workingColor}
    elseif currentEnergy == 0 then
        state = {name = changeRate .. " EU/s", color = Colors.errorColor}
    elseif changeRate > 0 then
        state = {name = "+" .. changeRate .. " EU/s", color = Colors.idleColor}
    else
        state = {name = changeRate .. " EU/s", color = Colors.offColor}
    end

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
