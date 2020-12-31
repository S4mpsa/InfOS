-- Import section
MockSingleBlock = require("mock-single-block")
inherits = require("inherits")
--

local MockMiner =
    inherits(
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
