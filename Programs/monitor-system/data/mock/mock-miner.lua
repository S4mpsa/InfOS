-- Import section
Inherits = require("utils.inherits")
MockSingleBlock = require("data.mock.mock-single-block")
--

local MockMiner =
    Inherits(
    MockSingleBlock,
    {
        name = "MockMiner"
    }
)

function MockMiner.getSensorInformation()
    return {
        "§9Multiblock Miner§r",
        "Work Area: §a2x2§r Chunks",
        n = 2
    }
end

return MockMiner
