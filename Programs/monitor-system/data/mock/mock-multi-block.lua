-- Import section
Inherits = require("utils.inherits")
MockSingleBlock = require("data.mock.mock-single-block")
--

local MockMultiBlock =
    Inherits(
    MockSingleBlock,
    {
        name = "MockMultiBlock"
    }
)

function MockMultiBlock.getSensorInformation()
    return {
        "Progress: §a2§r s / §e5§r s",
        "Stored Energy: §a1000§r EU / §e1000§r EU",
        "Probably uses: §c4§r EU/t",
        "Max Energy Income: §e128§r EU/t(x2A) Tier: §eMV§r",
        "Problems: §c0§r Efficiency: §e100.0§r %",
        "Pollution reduced to: §a0§r %",
        n = 6
    }
end

return MockMultiBlock
