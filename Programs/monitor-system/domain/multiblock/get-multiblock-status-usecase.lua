local function exec(multiblocks)
    local statuses = {}
    for _, multiblock in ipairs(multiblocks) do
        statuses[multiblock.name] = {
            problems = multiblock:getNumberOfProblems(),
            efficiencyPercentage = multiblock:getEfficiencyPercentage()
        }
    end
    return statuses
end

return exec
