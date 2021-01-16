-- Import section
Machine = require("data.datasource.machine")
Alarm = require("api.sound.alarm")
--

local function exec(address, name)
    local multiblock = Machine.getMachine(address, name, Machine.types.multiblock)
    local status = {}
    local problems = multiblock:getNumberOfProblems()

    local state = {}
    if multiblock:isMachineEnabled() then
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
    local maxProgress = totalProgress.maximum
    local progress = totalProgress.current

    status[multiblock.name] = {
        progress = progress,
        maxProgress = maxProgress,
        problems = problems,
        probablyUses = multiblock:getEnergyUsage(),
        efficiencyPercentage = multiblock:getEfficiencyPercentage(),
        state = state
    }
    return status
end

return exec
