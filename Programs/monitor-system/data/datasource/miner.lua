-- Import section
parser = require("utils.parser")
inherits = require("utils.inherits")
SingleBlock = require("data.datasource.single-block")
local mock = require("data.mock.mock-miner")
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
    return parser.parseName(sensorInformation[1])
end

function Miner:getWorkArea()
    local sensorInformation = self:getSensorInformation()
    return parser.parseWorkArea(sensorInformation[2])
end

return Miner
