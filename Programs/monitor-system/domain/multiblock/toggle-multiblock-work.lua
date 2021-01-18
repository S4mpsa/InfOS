-- Import section
Machine = require("data.datasource.machine")
Alarm = require("api.sound.alarm")
--

local function exec(address, name)
    local multiblock = Machine.getMachine(address, name, Machine.types.multiblock)
    local workAllowed = multiblock:isWorkAllowed()
    multiblock:setWorkAllowed(not workAllowed)
end

return exec
