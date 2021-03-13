-- Import section
Inherits = require("utils.inherits")
MockSingleBlock = require("data.mock.mock-single-block")
--

local MockMultiBlock =
    Inherits(
    MockSingleBlock,
    {
        name = "MockMultiBlock",
        isBroken = false
    }
)

function MockMultiBlock.getSensorInformation()
    MockMultiBlock.workProgress = MockMultiBlock.workProgress + 1
    if MockMultiBlock.workProgress > MockMultiBlock.workMaxProgress then
        MockMultiBlock.workProgress = 0
    end
    if MockMultiBlock.workAllowed and not MockMultiBlock.isBroken and math.random(1000) > 999 then
        MockMultiBlock.workMaxProgress = math.random(500)
    end
    MockMultiBlock.isBroken = MockMultiBlock.isBroken or math.random(100000) > 99999
    return {
        "Progress: §a" .. MockMultiBlock.workProgress .. "§r s / §e" .. MockMultiBlock.workMaxProgress .. "§r s",
        "Stored Energy: §a1000§r EU / §e1000§r EU",
        "Probably uses: §c4§r EU/t",
        "Max Energy Income: §e128§r EU/t(x2A) Tier: §eMV§r",
        "Problems: §c" .. (MockMultiBlock.isBroken and 1 or 0) .. "§r Efficiency: §e100.0§r %",
        "Pollution reduced to: §a0§r %",
        n = 6
    }
end

function MockMultiBlock.setWorkAllowed(allow)
    if MockMultiBlock.isBroken then
        MockMultiBlock.isBroken = false
    end
    MockMultiBlock.workAllowed = allow
end

return MockMultiBlock
