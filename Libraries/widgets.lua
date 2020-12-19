comp = require("component")
screen = require("term")
computer = require("computer")
event = require("event")
draw = require("graphics")
util = require("utility")

local mainColor = color.purple
local background = color.black
local accentA = color.cyan
local accentB = color.red
local barColor = color.blue

local widgets = {}

function widgets.gtMachineInit(GPU, name, address)
    local maintenanceIndex = 0
    local machine = util.machine(address)
    draw.rect(GPU, 1, 1, 28, 9, background)
    draw.text(GPU, 4, 3, mainColor, name)
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
                    draw.text(GPU, 4, 5, accentB, "" .. tier)
                end
            end
            --Check for parallel on Processing Arrays
            if string.match(machine.getSensorInformation()[7], "Parallel") ~= nil then
                local parallel = string.gsub(machine.getSensorInformation()[7], "([^0-9]+)", "")
                if parallel ~= nil then
                    draw.text(GPU, 11 + -(#parallel) .. "", 5, mainColor, parallel .. "x")
                end
            end
        end
    else
        draw.text(GPU, 4, 5, errorColor, "Unknown")
    end
    draw.rect(GPU, 3, 2, 3, 1, barColor)
    draw.rect(GPU, 2, 2, 1, 7, barColor)
    draw.rect(GPU, 3, 8, 20, 1, barColor)
    draw.rect(GPU, 24, 8, 3, 1, barColor)
    draw.rect(GPU, 27, 2, 1, 7, barColor)
    draw.rect(GPU, 7, 2, 21, 1, barColor)
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
            if f ~= mainColor then
                local bars1 = math.max(0, math.min(3, barAmount))
                draw.rect(GPU, 3, 2, 3, 1, barColor)
                draw.rect(GPU, 24, 8, 3, 1, barColor)
                draw.rect(GPU, 2, 2, 1, 7, barColor)
                draw.rect(GPU, 27, 2, 1, 7, barColor)
                draw.rect(GPU, 3, 8, 20, 1, barColor)
                draw.rect(GPU, 7, 2, 20, 1, barColor)
                draw.rect(GPU, 6 - bars1, 2, bars1, 1, mainColor)
                draw.rect(GPU, 24, 8, bars1, 1, mainColor)
            end
            _, f, _ = GPU.get(2, 4)
            if barAmount > 3 and f ~= mainColor then --Vertical
                bars2 = math.max(0, math.min(7, barAmount - 3))
                draw.rect(GPU, 2, 2, 1, 7, barColor)
                draw.rect(GPU, 27, 2, 1, 7, barColor)
                draw.rect(GPU, 3, 8, 20, 1, barColor)
                draw.rect(GPU, 7, 2, 20, 1, barColor)
                draw.rect(GPU, 2, 2, 1, bars2, mainColor)
                draw.rect(GPU, 27, 9 - bars2, 1, bars2, mainColor)
            end
            if barAmount > 10 then --Long Straight
                local bars3 = math.max(0, barAmount - 10)
                draw.rect(GPU, 3, 8, 20, 1, barColor)
                draw.rect(GPU, 7, 2, 20, 1, barColor)
                draw.rect(GPU, 3, 8, bars3, 1, mainColor)
                draw.rect(GPU, 27 - bars3, 2, bars3, 1, mainColor)
            end
            progressString =
                tostring(math.floor(machine.getWorkProgress() / 20)) ..
                "/" .. tostring(math.floor(machine.getWorkMaxProgress() / 20)) .. "s"
            middlePoint = math.min(9, 12 - #progressString / 2)
            draw.rect(GPU, 18, 5, 8, 2, background)
            draw.text(GPU, 26 - #progressString, 5, accentA, progressString)
        else --No work
            _, f, _ = GPU.get(5, 1)
            if f ~= barColor then
                draw.rect(GPU, 18, 5, 8, 2, background)
                draw.rect(GPU, 3, 2, 3, 1, barColor)
                draw.rect(GPU, 2, 2, 1, 7, barColor)
                draw.rect(GPU, 3, 8, 20, 1, barColor)
                draw.rect(GPU, 24, 8, 3, 1, barColor)
                draw.rect(GPU, 27, 2, 1, 7, barColor)
                draw.rect(GPU, 7, 2, 20, 1, barColor)
            end
        end
        _, f, _ = GPU.get(6, 1)
        if
            ((windows[name].data == 0 or string.match(machine.getSensorInformation()[windows[name].data], ".*c0.*")) and
                machine.isWorkAllowed()) == true
         then
            if f ~= background then
                draw.rect(GPU, 6, 2, 1, 1, background)
                draw.rect(GPU, 23, 8, 1, 1, background)
            end
        else
            if (machine.isWorkAllowed()) then
                if f ~= accentA then
                    draw.rect(GPU, 6, 2, 1, 1, accentA)
                    draw.rect(GPU, 23, 8, 1, 1, accentA)
                end
            else
                if f ~= errorColor then
                    draw.rect(GPU, 6, 2, 1, 1, errorColor)
                    draw.rect(GPU, 23, 8, 1, 1, errorColor)
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
    windows[name] = {
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

GTMachine = {width = 28, height = 9, initialize = widgets.gtMachineInit, update = widgets.gtMachine}

return widgets
