-- Import section
parser = require("parser")
inherits = require("inherits")
SingleBlock = require("single-block")
local mock = require("mock-multi-block")
--

local MultiBlock =
    inherits(
    SingleBlock,
    {
        mock = mock,
        name = "MultiBlock"
    }
)

function MultiBlock:getNumberOfProblems()
    local sensorInformation = self:getSensorInformation()
    return parser.parseProblems(sensorInformation[5])
end

function MultiBlock:getEfficiencyPercentage()
    local sensorInformation = self:getSensorInformation()
    return parser.parseEfficiency(sensorInformation[5])
end

return MultiBlock
