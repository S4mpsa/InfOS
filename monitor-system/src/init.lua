-- Import section
Computer = require("computer")
Component = require("component")
MultiBlock = require("data.datasource.multi-block")
SingleBlock = require("data.datasource.single-block")
EnergyProvider = require("data.datasource.energy-provider")

local cleanroomAddresses = require("data.database.cleanroom")
local multiBlockAddresses = require("data.database.multi-blocks")
local energyBufferAddress = require("data.database.energy-buffer")
local protectCleanroomRecipes = require("domain.cleanroom.protect-recipes-usecase")
local getMultiblockStatuses = require("domain.multiblock.get-status-usecase")
local getEnergyStatus = require("domain.energy.get-energy-status-usecase")
--

local cleanroom = MultiBlock:new(multiBlockAddresses.cleanroom)
local cleanroomMachines = {}
for address in pairs(cleanroomAddresses.machines) do
    table.insert(cleanroomMachines, SingleBlock:new(address))
end

local EBF11 = MultiBlock:new(multiBlockAddresses.EBF11)

local multiblocks = {cleanroom, EBF11}

local energyBuffer = EnergyProvider:new(energyBufferAddress)

local energyProducers = {}

local i = 1
while true do
    if (i > 100) then
        break
    end
    print(i)
    protectCleanroomRecipes(cleanroom, cleanroomMachines)
    local multiblockStatuses = getMultiblockStatuses(multiblocks)
    local energyStatus = getEnergyStatus(energyProducers, energyBuffer)
    os.sleep(0)
    i = i + 1
end
