-- Import section
-- MultiBlock = require("data.datasource.multi-block")
-- SingleBlock = require("data.datasource.single-block")
-- EnergyProvider = require("data.datasource.energy-provider")
Colors = require("graphics.colors")
Unicode = require("unicode")
-- Graphics = require("graphics.graphics")
DoubleBuffer = require("graphics.doubleBuffering")
Event = require("event")

-- local cleanroomAddresses = require("config.addresses.cleanroom")
-- local multiBlockAddresses = require("config.addresses.multi-blocks")
-- local energyBufferAddresses = require("config.addresses.energy-buffers")

-- local protectCleanroomRecipes = require("domain.cleanroom.protect-recipes-usecase")
-- local getMultiblockStatuses = require("domain.multiblock.get-multiblock-status-usecase")
-- local getEnergyStatus = require("domain.energy.get-energy-status-usecase")
-- local listMiners = require("domain.miner.list-miners-usecase")
-- local getMinersStatuses = require("domain.miner.get-miner-status-usecase")

-- local GPU = Component.gpu
--

--[[
local cleanroomMachines = {}
for name, address in pairs(cleanroomAddresses) do
    table.insert(cleanroomMachines, SingleBlock:new(address, name))
end

local multiblocks = {}
for name, address in pairs(multiBlockAddresses) do
    table.insert(multiblocks, MultiBlock:new(address, name))
end

local batteryBuffers = {}
for name, address in pairs(energyBufferAddresses) do
    table.insert(batteryBuffers, EnergyProvider:new(address, name))
end

local multiblocksStatuses = {}

for i = 1, 100 do
    print(i)

    protectCleanroomRecipes(multiblocks[1], cleanroomMachines)
    multiblocksStatuses = getMultiblockStatuses(multiblocks)
    -- local energyStatus = getEnergyStatus(batteryBuffers[1])

    local minersList = listMiners()
    local minersStatuses = getMinersStatuses(minersList)

    os.sleep(0)
    i = i + 1
end

for multiblockName, status in pairs(multiblocksStatuses) do
    print(
        multiblockName .. ":",
        "\n    problems: " .. status.problems,
        "\n    efficiency: " .. status.efficiencyPercentage,
        "\n    probably uses: " .. status.probablyUses
    )
end

require("api.sound.zelda-secret")()
--]]
local baseWidth = 40
local baseHeight = 10

local states = {
    {state = "ON", color = Colors.workingColor},
    {state = "IDLE", color = Colors.idleColor},
    {state = "OFF", color = Colors.offColor},
    {state = "BROKEN", color = Colors.errorColor}
}

local fakeNames = {
    "Cleanroom",
    "Electric Blast Furnace",
    "Miner",
    "Vacuum Freezer",
    "Multi Smelter",
    "Sifter",
    "Large Chemical Reactor",
    "Distillery",
    "Oil Cracking Unit",
    "Implosion Compressor"
}

local function fakewidget()
    local state = states[math.random(4)]
    return {
        name = fakeNames[math.random(10)] .. " " .. math.random(3),
        state = state,
        progress = 0,
        maxProgress = state ~= states[3] and state ~= states[4] and math.random(500) or 0,
        area = {height = baseHeight, width = baseWidth}
    }
end

local widgets = {}

for i = 1, 9 do
    local widget = fakewidget()
    widget.area.x = baseWidth + baseWidth * ((i - 1) % 3)
    widget.area.y = baseHeight * math.ceil(i / 3)
    table.insert(widgets, fakewidget())
end
table.insert(
    widgets,
    {
        name = "Power",
        state = states[1],
        progress = math.random(16000000),
        maxProgress = 16000000,
        scale = 2,
        area = {x = baseWidth, y = baseHeight * 5, width = baseWidth * 2, height = baseHeight}
    }
)
widgets[11] = widgets[10]

Event.listen(
    "touch",
    function(_, _, x, y)
        local index =
            1 + (math.floor(2 * ((x - baseWidth) / baseWidth + 3 * math.floor((y - baseHeight) / baseHeight)))) / 2
        local widget = widgets[index] or widgets[index - 0.5]

        widget.progress = 0
        widget.maxProgress = 0
        if widget.state == states[1] or widget.state == states[2] then
            widget.state = states[3]
        elseif widget.state == states[3] or widget.state == states[4] then
            widget.state = states[2]
        end
    end
)

local function drawTitle(title)
    local x = baseWidth
    local y = 0
    local scale = 3
    local width = baseWidth * scale
    local height = baseHeight
    DoubleBuffer.drawRectangle(
        x + 1,
        y + 1,
        width - 1,
        height - 1,
        Colors.machineBackground,
        Colors.machineBackground,
        "█"
    )
    DoubleBuffer.drawFrame(x + 1, y + 1, width - 1, height - 1, Colors.labelColor)
    DoubleBuffer.drawLine(x + 3, y + 6, x + width - 3, y + 6, Colors.machineBackground, Colors.textColor, "─")
    DoubleBuffer.drawText(x + (width - Unicode.len(title)) / 2, y + 5, Colors.mainColor, title)
end

local function drawProgress(x, y, width, height, progress, maxProgress, color)
    progress = math.floor(progress * (width + height - 2) / (maxProgress ~= 0 and maxProgress or 1))

    local lengths = {
        first = progress > 5 and 5 or progress,
        second = progress > height - 2 + 5 and height - 2 or progress - (5),
        third = progress > width - 7 + height - 2 + 5 and width - 7 or progress - (height - 2 + 5)
    }
    DoubleBuffer.drawSemiPixelRectangle(x + 6 - lengths.first, y + 1, lengths.first, 1, color)
    DoubleBuffer.drawSemiPixelRectangle(x + 1, y + 2, 1, lengths.second, color)
    DoubleBuffer.drawSemiPixelRectangle(x + 1, y + height, lengths.third, 1, color)
    DoubleBuffer.drawSemiPixelRectangle(x + width - 4, y + height, lengths.first, 1, color)
    DoubleBuffer.drawSemiPixelRectangle(x + width, y + height - lengths.second, 1, lengths.second, color)
    DoubleBuffer.drawSemiPixelRectangle(x + 1 + width - lengths.third, y + 1, lengths.third, 1, color)
end

local function drawWidget(index, widget)
    if index > 10 then
        return
    end
    local scale = widget.scale or 1
    local x = baseWidth + baseWidth * ((index - 1) % 3)
    local width = baseWidth * scale
    local height = baseHeight
    local y = height * math.ceil((index) / 3)
    DoubleBuffer.drawRectangle(
        x + 1,
        y + 1,
        width - 1,
        height - 1,
        Colors.machineBackground,
        Colors.machineBackground,
        "█"
    )

    drawProgress(x, 2 * y, width - 1, 2 * (height - 1), 1, 1, Colors.progressBackground)
    drawProgress(x, 2 * y, width - 1, 2 * (height - 1), widget.progress, widget.maxProgress, Colors.barColor)

    DoubleBuffer.drawLine(x + 3, y + 5, x + width - 3, y + 5, Colors.machineBackground, Colors.textColor, "─")
    DoubleBuffer.drawText(x + 3, y + 3, Colors.labelColor, widget.name)
    DoubleBuffer.drawText(x + 3, y + 7, widget.state.color, widget.state.state)
    if widget.state == states[4] then
        drawProgress(x, 2 * y, width - 1, 2 * (height - 1), 1, 1, Colors.errorColor)
    else
        if widget.middleInfo then
            DoubleBuffer.drawText(x + 3 + 3 + Unicode.len("IDLE"), y + height - 3, Colors.textColor, widget.middleInfo)
        end
        DoubleBuffer.drawText(
            x + width - Unicode.len(widget.progress .. "/" .. widget.maxProgress .. " s") - 3,
            y + height - 3,
            Colors.accentA,
            widget.progress .. "/" .. widget.maxProgress .. " s"
        )
    end
end

drawTitle("Overview")
while true do
    for index, widget in ipairs(widgets) do
        local breakWidget = math.random(10000) > 9999
        if breakWidget and index ~= 10 and index ~= 11 and widget.state ~= states[3] then
            widget.state = states[4]
        end
        if widget.state == states[1] then
            widget.progress = widget.progress + 1
            if widget.progress >= widget.maxProgress then
                widget.progress = 0
                widget.state = states[2]
                widget.maxProgress = 0
            end
        elseif widget.state == states[2] then
            if math.random(1000) > 999 then
                widget.state = states[1]
                widget.maxProgress = math.random(500)
            end
        end

        drawWidget(index, widget)
    end
    DoubleBuffer.drawChanges()
    os.sleep(0)
end
--[[
Page = require("api.gui.page")
Notifications = {}
local components = {}
local function getComponents()
    local multiBlockAddresses = require("config.addresses.multi-blocks")
    local energyBufferAddresses = require("config.addresses.energy-buffers")

    local multiblocks = {}
    for name, address in pairs(multiBlockAddresses) do
        table.insert(multiblocks, MultiBlock:new(address, name))
    end

    local batteryBuffers = {}
    for name, address in pairs(energyBufferAddresses) do
        table.insert(batteryBuffers, EnergyProvider:new(address, name))
    end

    return {table.unpack(multiblocks), batteryBuffers}
end

local function setup()
    components = getComponents()
    Page.overview.setup()
end

local function loop()
    while true do
        for index, component in ipairs(components) do
            local updated, notification = component:update()
            if updated then
                Page:draw(component, index)
            end
            if notification then
                table.insert(Notifications, 1, {notification, os.time()})
            end
        end
        Page:render()
    end
end

setup()
loop()
--]]
