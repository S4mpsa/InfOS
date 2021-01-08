Graphics = require("graphics")
local util = require("utility")
Colors = require("colors")

local widgets = {}

function widgets.gtMabchineInit(GPU, name, address)
    local maintenanceIndex = 0
    local machine = util.machine(address)
    Graphics.rectangle(GPU, 1, 1, 28, 9, Colors.background)
    Graphics.text(GPU, 4, 3, Colors.mainColor, name)
    if machine ~= nil then
        for i = 1, #machine.getSensorInformation() do --Get maintenance index
            if string.match(machine.getSensorInformation()[i], "Problems") ~= nil then
                maintenanceIndex = i
            end
        end
        if maintenanceIndex ~= 0 and #machine.getSensorInformation() >= 7 then
            --Check for tier on Processing Arrays
            if string.match(machine.getSensorInformation()[6], "tier") ~= nil then
                local tier = util.tier((string.gsub(machine.getSensorInformation()[6], "([^0-9]+)", "") - 1) / 10)
                if tier ~= nil then
                    Graphics.text(GPU, 4, 5, Colors.accentB, "" .. tier)
                end
            end
            --Check for parallel on Processing Arrays
            if string.match(machine.getSensorInformation()[7], "Parallel") ~= nil then
                local parallel = string.gsub(machine.getSensorInformation()[7], "([^0-9]+)", "")
                if parallel ~= nil then
                    Graphics.text(GPU, 11 + -(#parallel) .. "", 5, Colors.mainColor, parallel .. "x")
                end
            end
        end
    else
        Graphics.text(GPU, 4, 5, Colors.errorColor, "Unknown")
    end
    Graphics.rectangle(GPU, 3, 2, 3, 1, Colors.barColor)
    Graphics.rectangle(GPU, 2, 2, 1, 7, Colors.barColor)
    Graphics.rectangle(GPU, 3, 8, 20, 1, Colors.barColor)
    Graphics.rectangle(GPU, 24, 8, 3, 1, Colors.barColor)
    Graphics.rectangle(GPU, 27, 2, 1, 7, Colors.barColor)
    Graphics.rectangle(GPU, 7, 2, 21, 1, Colors.barColor)
    return maintenanceIndex
end

function widgets.gtMachine(GPU, name, address)
    local machine = util.machine(address)
    local char, f, b
    if machine ~= nil then
        if machine.hasWork() then
            local currentProgress = math.ceil(30 * (machine.getWorkProgress() / machine.getWorkMaxProgress()))
            local barAmount = currentProgress
            --First Straight
            _, f, _ = GPU.get(3, 1)
            if f ~= Colors.mainColor then
                local bars1 = math.max(0, math.min(3, barAmount))
                Graphics.rectangle(GPU, 3, 2, 3, 1, Colors.barColor)
                Graphics.rectangle(GPU, 24, 8, 3, 1, Colors.barColor)
                Graphics.rectangle(GPU, 2, 2, 1, 7, Colors.barColor)
                Graphics.rectangle(GPU, 27, 2, 1, 7, Colors.barColor)
                Graphics.rectangle(GPU, 3, 8, 20, 1, Colors.barColor)
                Graphics.rectangle(GPU, 7, 2, 20, 1, Colors.barColor)
                Graphics.rectangle(GPU, 6 - bars1, 2, bars1, 1, Colors.mainColor)
                Graphics.rectangle(GPU, 24, 8, bars1, 1, Colors.mainColor)
            end
            _, f, _ = GPU.get(2, 4)
            if barAmount > 3 and f ~= Colors.mainColor then --Vertical
                local bars2 = math.max(0, math.min(7, barAmount - 3))
                Graphics.rectangle(GPU, 2, 2, 1, 7, Colors.barColor)
                Graphics.rectangle(GPU, 27, 2, 1, 7, Colors.barColor)
                Graphics.rectangle(GPU, 3, 8, 20, 1, Colors.barColor)
                Graphics.rectangle(GPU, 7, 2, 20, 1, Colors.barColor)
                Graphics.rectangle(GPU, 2, 2, 1, bars2, Colors.mainColor)
                Graphics.rectangle(GPU, 27, 9 - bars2, 1, bars2, Colors.mainColor)
            end
            if barAmount > 10 then --Long Straight
                local bars3 = math.max(0, barAmount - 10)
                Graphics.rectangle(GPU, 3, 8, 20, 1, Colors.barColor)
                Graphics.rectangle(GPU, 7, 2, 20, 1, Colors.barColor)
                Graphics.rectangle(GPU, 3, 8, bars3, 1, Colors.mainColor)
                Graphics.rectangle(GPU, 27 - bars3, 2, bars3, 1, Colors.mainColor)
            end
            local progressString =
                tostring(math.floor(machine.getWorkProgress() / 20)) ..
                "/" .. tostring(math.floor(machine.getWorkMaxProgress() / 20)) .. "s"
            Graphics.rectangle(GPU, 18, 5, 8, 2, Colors.background)
            Graphics.text(GPU, 26 - #progressString, 5, Colors.accentA, progressString)
        else --No work
            _, f, _ = GPU.get(5, 1)
            if f ~= Colors.barColor then
                Graphics.rectangle(GPU, 18, 5, 8, 2, Colors.background)
                Graphics.rectangle(GPU, 3, 2, 3, 1, Colors.barColor)
                Graphics.rectangle(GPU, 2, 2, 1, 7, Colors.barColor)
                Graphics.rectangle(GPU, 3, 8, 20, 1, Colors.barColor)
                Graphics.rectangle(GPU, 24, 8, 3, 1, Colors.barColor)
                Graphics.rectangle(GPU, 27, 2, 1, 7, Colors.barColor)
                Graphics.rectangle(GPU, 7, 2, 20, 1, Colors.barColor)
            end
        end
        _, f, _ = GPU.get(6, 1)
        if
            ((Graphics.windows[name].data == 0 or
                string.match(machine.getSensorInformation()[Graphics.windows[name].data], ".*c0.*")) and
                machine.isWorkAllowed()) == true
         then
            if f ~= Colors.background then
                Graphics.rectangle(GPU, 6, 2, 1, 1, Colors.background)
                Graphics.rectangle(GPU, 23, 8, 1, 1, Colors.background)
            end
        else
            if (machine.isWorkAllowed()) then
                if f ~= Colors.accentA then
                    Graphics.rectangle(GPU, 6, 2, 1, 1, Colors.accentA)
                    Graphics.rectangle(GPU, 23, 8, 1, 1, Colors.accentA)
                end
            else
                if f ~= Colors.errorColor then
                    Graphics.rectangle(GPU, 6, 2, 1, 1, Colors.errorColor)
                    Graphics.rectangle(GPU, 23, 8, 1, 1, Colors.errorColor)
                end
            end
        end
    end
end

function widgets.create(GPU, x, y, name, dataAddress, widget)
    local width, height = widget.width, widget.height
    local page = GPU.allocateBuffer(width, math.ceil(height / 2))
    GPU.setActiveBuffer(page)
    local widgetData = widget.initialize(GPU, name, dataAddress)
    Graphics.windows[name] = {
        GPU = GPU,
        page = page,
        address = dataAddress,
        x = x,
        y = y,
        w = width,
        h = height,
        update = widget.update,
        data = widgetData
    }
    GPU.setActiveBuffer(0)
end

return widgets
