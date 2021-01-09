-- Import section
-- MultiBlock = require("data.datasource.multi-block")
-- SingleBlock = require("data.datasource.single-block")
-- EnergyProvider = require("data.datasource.energy-provider")
Colors = require("graphics.colors")
Unicode = require("unicode")
Graphics = require("graphics.graphics")
DoubleBuffer = require("graphics.doubleBuffering")

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

local function fakeComponent()
    return {
        name = fakeNames[math.random(10)] .. " " .. math.random(3),
        state = states[math.random(4)],
        progress = 0,
        maxProgress = math.random(500),
        idleTime = 0
    }
end

local components = {}

for i = 1, 9 do
    table.insert(components, fakeComponent())
end
table.insert(
    components,
    {
        name = "Power",
        state = states[1],
        progress = math.random(16000000),
        maxProgress = 16000000,
        idleTime = 0,
        scale = 2
    }
)

local baseWidth = 40
local baseHeight = 10

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

local function drawWidget(index, component)
    local globalWidth = baseWidth
    local scale = component.scale or 1
    local x = globalWidth + globalWidth * ((index - 1) % 3)
    local width = globalWidth * scale
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
    drawProgress(x, 2 * y, width - 1, 2 * (height - 1), component.progress, component.maxProgress, Colors.barColor)

    DoubleBuffer.drawLine(x + 3, y + 5, x + width - 3, y + 5, Colors.machineBackground, Colors.textColor, "─")
    DoubleBuffer.drawText(x + 3, y + 3, Colors.labelColor, component.name)
    DoubleBuffer.drawText(x + 3, y + 7, component.state.color, component.state.state)
    if component.state == states[4] then
        drawProgress(x, 2 * y, width - 1, 2 * (height - 1), 1, 1, Colors.errorColor)
    else
        if component.middleInfo then
            DoubleBuffer.drawText(
                x + 3 + 3 + Unicode.len("IDLE"),
                y + height - 3,
                Colors.textColor,
                component.middleInfo
            )
        end
        DoubleBuffer.drawText(
            x + width - Unicode.len(component.progress .. "/" .. component.maxProgress) - 3,
            y + height - 3,
            Colors.accentA,
            component.progress .. "/" .. component.maxProgress
        )
    end
end

drawTitle("Overview")
while true do
    for index, component in ipairs(components) do
        local breakComponent = math.random(10000) > 9999
        if breakComponent then
            component.state = states[4]
        end
        if component.state == states[1] then
            component.progress = component.progress + 1
            if component.progress >= component.maxProgress then
                component.progress = 0
                component.state = states[2]
                component.maxProgress = 0
                component.idleTime = 0
            end
        elseif component.state == states[2] then
            component.idleTime = component.idleTime + 1
            if component.idleTime > math.random(1000) then
                component.state = states[1]
                component.maxProgress = math.random(500)
            end
        end

        drawWidget(index, component)
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
