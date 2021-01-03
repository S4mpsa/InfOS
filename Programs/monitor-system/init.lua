-- Import section
computer = require("computer")
comp = require("component")
MultiBlock = require("data.datasource.multi-block")
SingleBlock = require("data.datasource.single-block")
EnergyProvider = require("data.datasource.energy-provider")

local cleanroomAddresses = require("config.addresses.cleanroom")
local multiBlockAddresses = require("config.addresses.multi-blocks")
local energyBufferAddress = require("config.addresses.energy-buffers")

local protectCleanroomRecipes = require("domain.cleanroom.protect-recipes-usecase")
local getMultiblockStatuses = require("domain.multiblock.get-multiblock-status-usecase")
local getEnergyStatus = require("domain.energy.get-energy-status-usecase")
local listMiners = require("domain.miner.list-miners-usecase")
local getMinersStatuses = require("domain.miner.get-miner-status-usecase")
--

local cleanroom = MultiBlock:new(multiBlockAddresses.cleanroom)
cleanroom.name = "cleanroom"
local cleanroomMachines = {}
for _, address in pairs(cleanroomAddresses) do
    table.insert(cleanroomMachines, SingleBlock:new(address))
end

local EBF11 = MultiBlock:new(multiBlockAddresses.EBF11)
EBF11.name = "EBF11"

local multiblocks = {cleanroom, EBF11}

local energyBuffer = EnergyProvider:new(energyBufferAddress.batteryBuffer1)

local energyProducers = {}
local multiblocksStatuses = {}

for i = 1, 100 do
    print(i)

    protectCleanroomRecipes(cleanroom, cleanroomMachines)
    multiblocksStatuses = getMultiblockStatuses(multiblocks)
    local energyStatus = getEnergyStatus(energyProducers, energyBuffer)

    local minersList = listMiners()
    local minersStatuses = getMinersStatuses(minersList)

    os.sleep(0)
    i = i + 1
end

for multiblock, status in pairs(multiblocksStatuses) do
    print(multiblock .. ": \
    problems: " .. status.problems .. "\
    efficiency: " .. status.efficiencyPercentage)
end
require("resources.sound.zelda-secret")()
