-- Import section
parser = require("utils.parser")
inherits = require("utils.inherits")
SingleBlock = require("data.datasource.single-block")
local mock = require("data.mock.mock-multi-block")
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
