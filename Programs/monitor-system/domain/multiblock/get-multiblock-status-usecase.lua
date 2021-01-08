-- Import section
Alarm = require("api.sound.alarm")
--

local function exec(multiblocks)
    local statuses = {}
    for _, multiblock in ipairs(multiblocks) do
        local problems = multiblock:getNumberOfProblems()
        if problems > 0 then
            Alarm()
        end

        statuses[multiblock.name] = {
            problems = problems,
            probablyUses = multiblock:getEnergyUsage(),
            efficiencyPercentage = multiblock:getEfficiencyPercentage()
        }
    end
    return statuses
end

return exec
