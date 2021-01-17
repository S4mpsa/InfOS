-- Import section
Inherits = require("utils.inherits")
MockSingleBlock = require("data.mock.mock-single-block")
--

local MockMultiBlock =
    Inherits(
    MockSingleBlock,
    {
        name = "MockMultiBlock",
        progress = 0,
        maxProgress = 0,
    }
)

function MockMultiBlock:getSensorInformation()
    self.progress = self.progress + 1
    if self.progress > self.maxProgress then
        self.maxProgress = math.random(500)
        self.progress = 0
    end
    self.isBroken = self.isBroken or math.random(100000) > 99999
    return {
        "Progress: §a" .. self.progress .. "§r s / §e" .. self.maxProgress .. "§r s",
        "Stored Energy: §a1000§r EU / §e1000§r EU",
        "Probably uses: §c4§r EU/t",
        "Max Energy Income: §e128§r EU/t(x2A) Tier: §eMV§r",
        "Problems: §c" .. self.isBroken and 1 or 0 .. "§r Efficiency: §e100.0§r %",
        "Pollution reduced to: §a0§r %",
        n = 6
    }
end

function MockMultiBlock:setWorkAllowed(allow)
    if self.isBroken then
       self.isBroken = false
    end
    self.workAllowed = allow
end

return MockMultiBlock
