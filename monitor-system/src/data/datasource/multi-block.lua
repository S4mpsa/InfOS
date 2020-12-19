-- Import section
local parser = require("util.parser")
local inherits = require("util.class.inherits")
local SingleBlock = require("data.datasource.single-block")
local mock = require("data.mock.mock-multi-block")
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
