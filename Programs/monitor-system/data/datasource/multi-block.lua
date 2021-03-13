-- Import section
Parser = require("utils.parser")
Inherits = require("utils.inherits")
SingleBlock = require("data.datasource.single-block")
local mock = require("data.mock.mock-multi-block")
--

local MultiBlock =
    Inherits(
    SingleBlock,
    {
        mock = mock,
        name = "MultiBlock"
    }
)

function Parser.parseProgress(progressString)
    local current = string.sub(progressString, string.find(progressString, "%ba§"))
    current = tonumber((string.gsub(string.gsub(current, "a", ""), "§", "")))

    local maximum = string.sub(progressString, string.find(progressString, "%be§", (string.find(progressString, "/"))))
    maximum = tonumber((string.gsub(string.gsub(maximum, "e", ""), "§", "")))

    return {current = current, maximum = maximum}
end

function MultiBlock:getNumberOfProblems()
    local sensorInformation = self:getSensorInformation()
    return Parser.parseProblems(sensorInformation[5])
end

function MultiBlock:getProgress()
    local sensorInformation = self:getSensorInformation()
    return Parser.parseProgress(sensorInformation[1])
end

function MultiBlock:getEfficiencyPercentage()
    local sensorInformation = self:getSensorInformation()
    return Parser.parseEfficiency(sensorInformation[5])
end

function MultiBlock:getEnergyUsage() -- EU/t
    local maxProgress = self:getWorkMaxProgress() or 0
    if maxProgress > 0 then
        local sensorInformation = self:getSensorInformation()
        return Parser.parseProbablyUses(sensorInformation[3])
    else
        return 0
    end
end

return MultiBlock
