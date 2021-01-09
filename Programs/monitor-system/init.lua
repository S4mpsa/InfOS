-- Import section
MultiBlock = require("data.datasource.multi-block")
SingleBlock = require("data.datasource.single-block")
EnergyProvider = require("data.datasource.energy-provider")
Colors = require("graphics.colors")
Unicode = require("unicode")
Graphics = require("graphics.graphics")
DoubleBuffer = require("graphics.doubleBuffering")

local cleanroomAddresses = require("config.addresses.cleanroom")
local multiBlockAddresses = require("config.addresses.multi-blocks")
local energyBufferAddresses = require("config.addresses.energy-buffers")

local protectCleanroomRecipes = require("domain.cleanroom.protect-recipes-usecase")
local getMultiblockStatuses = require("domain.multiblock.get-multiblock-status-usecase")
local getEnergyStatus = require("domain.energy.get-energy-status-usecase")
local listMiners = require("domain.miner.list-miners-usecase")
local getMinersStatuses = require("domain.miner.get-miner-status-usecase")

local GPU = Component.gpu
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
local component = {
    name = "Machine",
    state = true,
    leftInfo = "ON",
    middleInfo = "something",
    rightInfo = "16 / 32 s",
    progress = 0,
    maxProgress = 1000
}

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

local function drawWidget(index, component, scale)
    local globalWidth = baseWidth
    scale = scale or 1
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
    DoubleBuffer.drawText(
        x + 3,
        y + 7,
        component.state and Colors.workingColor or Colors.idleColor,
        component.leftInfo
    )
    if component.middleInfo then
        DoubleBuffer.drawText(
            x + 3 + 3 + Unicode.len("IDLE"),
            y + height - 3,
            Colors.textColor,
            component.middleInfo
        )
    end
    if component.rightInfo then
        DoubleBuffer.drawText(
            x + width - Unicode.len(tostring(component.rightInfo)) - 3,
            y + height - 3,
            Colors.accentA,
            tostring(component.rightInfo)
        )
    end
end

drawTitle("Overview")
while true do
    component.progress = component.progress + 1
    if component.progress >= component.maxProgress then
        component.progress = 0
        component.state = false
        component.leftInfo = "IDLE"
        component.maxProgress = 0
        os.sleep(0.5)
    end
    component.rightInfo = component.progress .. "/" .. component.maxProgress .. " s"
    for index = 1, 10 do
        if index < 10 then
            drawWidget(index, component, 1)
        elseif index == 10 then
            drawWidget(index, component, 2)
        end
    end
    DoubleBuffer.drawChanges()
    if not component.state then
        component.state = true
        component.leftInfo = "ON"
        component.maxProgress = 1000
        os.sleep(3.5)
    end
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
