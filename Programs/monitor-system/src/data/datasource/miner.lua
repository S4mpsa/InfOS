-- Import section
parser = require("parser")
inherits = require("inherits")
SingleBlock = require("single-block")
local mock = require("mock-multi-block")
--

local Miner =
    inherits(
    SingleBlock,
    {
        mock = mock,
        name = "MultiBlock"
    }
)

function Miner:getName()
    local sensorInformation = self:getSensorInformation()
    return parser.parseProblems(sensorInformation[1])
end

function Miner:getWoarkArea()
    local sensorInformation = self:getSensorInformation()
    return parser.parseWorkArea(sensorInformation[2])
end

return Miner
