-- Import section
Machine = require("data.datasource.machine")
--

local function exec(address, name)
    local multiblock = Machine.getMachine(address, name, Machine.types.multiblock)
    local status = {}
    local problems = multiblock:getNumberOfProblems()

    local state = {}
    if multiblock:isWorkAllowed() then
        if multiblock:hasWork() then
            state = Machine.states.ON
        else
            state = Machine.states.IDLE
        end
    else
        state = Machine.states.OFF
    end

    if problems > 0 then
        state = Machine.states.BROKEN
    end

    local totalProgress = multiblock:getProgress()

    status = {
        progress = totalProgress.current,
        maxProgress = totalProgress.maximum,
        problems = problems,
        probablyUses = multiblock:getEnergyUsage(),
        efficiencyPercentage = multiblock:getEfficiencyPercentage(),
        state = state
    }
    return status
end

return exec
