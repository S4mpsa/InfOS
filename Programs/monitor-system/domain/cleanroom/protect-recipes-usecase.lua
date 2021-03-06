-- Import section
Alarm = require("api.sound.alarm")
--

local function halt(machines)
    Alarm()
    for _, machine in ipairs(machines) do
        machine:setWorkAllowed(false)
    end
end

local function resume(machines)
    for _, machine in ipairs(machines) do
        machine:setWorkAllowed(true)
    end
end

local function exec(cleanroom, machines)
    if (tonumber(cleanroom:getEfficiencyPercentage()) < 100) then
        if (not cleanroom.isHalted) then
            halt(machines)
            cleanroom.isHalted = true
        end
    else
        if (cleanroom.isHalted) then
            resume(machines)
            cleanroom.isHalted = false
        end
    end
end

return exec
