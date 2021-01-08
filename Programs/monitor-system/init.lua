-- Import section
MultiBlock = require("data.datasource.multi-block")
SingleBlock = require("data.datasource.single-block")
EnergyProvider = require("data.datasource.energy-provider")
Colors = require("graphics.colors")
Unicode = require("unicode")
local doubleBuffer = require("graphics.doubleBuffering")
--

local cleanroomAddresses = require("config.addresses.cleanroom")
local multiBlockAddresses = require("config.addresses.multi-blocks")
local energyBufferAddresses = require("config.addresses.energy-buffers")

local protectCleanroomRecipes = require("domain.cleanroom.protect-recipes-usecase")
local getMultiblockStatuses = require("domain.multiblock.get-multiblock-status-usecase")
local getEnergyStatus = require("domain.energy.get-energy-status-usecase")
local listMiners = require("domain.miner.list-miners-usecase")
local getMinersStatuses = require("domain.miner.get-miner-status-usecase")
--

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

local component = {
    name = "Machine",
    working = true,
    leftInfo = "LV",
    middleInfo = "something",
    rightInfo = "16 / 32 s",
    progress = 0,
    maxProgress = 16000
}

local width = 40
local height = 10
local function drawWidget(index, component, scale)
    scale = scale or 1
    local x = width + width * ((index - 1) % 3)
    local y = height * math.ceil((index) / 3)
    doubleBuffer.drawRectangle(
        x + 1,
        y + 1,
        width * scale - 1,
        height - 1,
        Colors.machineBackground,
        Colors.machineBackground,
        "█"
    )
    doubleBuffer.drawFrame(x + 1, y + 1, width * scale - 1, height - 1, Colors.labelColor)
    doubleBuffer.drawLine(x + 3, y + 5, x + width * scale - 3, y + 5, Colors.machineBackground, Colors.mainColor, "─")
    doubleBuffer.drawText(x + 3, y + 2, Colors.labelColor, component.name)
    doubleBuffer.drawText(
        x + 3,
        y + 7,
        component.working and Colors.workingColor or Colors.errorColor,
        component.leftInfo
    )
    if component.middleInfo then
        doubleBuffer.drawText(
            x + width * scale / 2 - Unicode.len(component.middleInfo) + 3,
            y + height - 3,
            Colors.accentB,
            component.middleInfo
        )
    end
    if component.rightInfo then
        doubleBuffer.drawText(
            x + width * scale - Unicode.len(tostring(component.rightInfo)) - 3,
            y + height - 3,
            Colors.accentA,
            tostring(component.rightInfo)
        )
    end
end

while true do
    component.progress = component.progress + math.random(0, 1000)
    component.rightInfo = component.progress .. " / " .. component.maxProgress
    if component.progress >= component.maxProgress then
        component.progress = 0
    end
    for index = 1, 10 do
        if index < 10 then
            drawWidget(index, component, 1)
        elseif index == 10 then
            drawWidget(index, component, 2)
        end
    end
    doubleBuffer.drawChanges()
    os.sleep(0.5)
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
