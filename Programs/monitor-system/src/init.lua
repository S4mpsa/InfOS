-- Import section
computer = require("computer")
comp = require("component")
MultiBlock = require("data.datasource.multi-block")
SingleBlock = require("data.datasource.single-block")
EnergyProvider = require("data.datasource.energy-provider")

local cleanroomAddresses = require("cleanroom")
local multiBlockAddresses = require("multi-blocks")
local energyBufferAddress = require("energy-buffer")

local protectCleanroomRecipes = require("domain.cleanroom.protect-recipes-usecase")
local getMultiblockStatuses = require("domain.multiblock.get-status-usecase")
local getEnergyStatus = require("domain.energy.get-energy-status-usecase")
--

local cleanroom = MultiBlock:new(multiBlockAddresses.cleanroom)
local cleanroomMachines = {}
for _, address in pairs(cleanroomAddresses) do
    table.insert(cleanroomMachines, SingleBlock:new(address))
end

local EBF11 = MultiBlock:new(multiBlockAddresses.EBF11)

local multiblocks = {cleanroom, EBF11}

local energyBuffer = EnergyProvider:new(energyBufferAddress.batteryBuffer1)

local energyProducers = {}

for i = 0, 100 do
    print(i)
    protectCleanroomRecipes(cleanroom, cleanroomMachines)
    local multiblockStatuses = getMultiblockStatuses(multiblocks)
    local energyStatus = getEnergyStatus(energyProducers, energyBuffer)
    os.sleep(0)
    i = i + 1
end
