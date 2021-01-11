-- Import section
-- Event = require("event")
-- Colors = require("graphics.colors")
-- Widget = require("api.gui.widget")
Page = require("api.gui.page")
-- Graphics = require("graphics.graphics")
-- MultiBlock = require("data.datasource.multi-block")
-- SingleBlock = require("data.datasource.single-block")
-- EnergyProvider = require("data.datasource.energy-provider")

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

Page.fake()

while true do
    Page.update()
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
