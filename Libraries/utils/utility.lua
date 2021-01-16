Component = require("component")
Event = require("event")
local uc = require("unicode")
local utility = {}

function utility.machine(address)
    local machineAddress = Component.get(address)
    if (machineAddress ~= nil) then
        return Component.proxy(machineAddress)
    else
        return nil
    end
end

function utility.getPercent(number)
    return (math.floor(number * 1000) / 10) .. "%"
end

function utility.time(number) --Returns a given number formatted as  Hours Minutes Seconds
    if number == 0 then
        return 0
    else
        return math.floor(number / 3600) ..
            "h " .. math.floor((number - math.floor(number / 3600) * 3600) / 60) .. "min " .. (number % 60) .. "s"
    end
end

function utility.splitNumber(number) --Returns given number formatted as XXX,XXX,XXX
    local formattedNumber = {}
    local string = tostring(math.abs(number))
    local sign = number / math.abs(number)
    for i = 1, #string do
        local n = string:sub(i, i)
        formattedNumber[i] = n
        if ((#string - i) % 3 == 0) and (#string - i > 0) then
            formattedNumber[i] = formattedNumber[i] .. ","
        end
    end
    if (sign < 0) then
        table.insert(formattedNumber, 1, "-")
    end
    return table.concat(formattedNumber, "")
end

function utility.tier(number)
    local values = {
        [1] = "LV",
        [2] = "MV",
        [3] = "HV",
        [4] = "EV",
        [5] = "IV",
        [6] = "LuV",
        [7] = "ZPM",
        [8] = "UV",
        [9] = "UHV"
    }
    return values[number]
end

function utility.exit(key)
    local function processKey(event, address, key, code, player)
        local value = uc.char(key)
        if value == "e" then
            Run = false
        end
        return false
    end
    Event.listen("key_up", processKey)
end

function utility.componentChange(broadcastPort)
    local function sendAddress(event, address, type)
        Component.modem.broadcast(broadcastPort, event, address, type)
    end
    Event.listen("component_added", sendAddress)
end

function utility.progressText(current, max)
    return current .. "/" .. max .. "s"
end

function utility.tps()
    local function time()
        local f = io.open("/tmp/TPS", "w")
        f:write("test")
        f:close()
        return (require("filesystem").lastModified("/tmp/TPS"))
    end
    local realTimeOld = time()
    os.sleep(1)
    return 20000 / (time() - realTimeOld)
end

return utility
