component = require("component")
event = require("event")
term = require("term")

local assemblyUtil = {}

local function addEntries(file, prompt, amount, type)
    local a, b, c
    for i = 1, amount, 1 do
        term.write(prompt .. " " .. i .. " ")
        a, b, c = event.pull()
        while a ~= "component_added" do
            a, b, c = event.pull()
            os.sleep()
        end
        file:write(type .. i .. "," .. b .. "\n")
        term.write(b .. "\n")
    end
end
local function addAuxilary(file, proxy, type)
    if proxy == nil then
        term.write("Cant find a valid " .. type .. "! Exiting...\n")
        os.exit()
    else
        file:write(type .. "," .. proxy.address .. "\n")
    end
end
local function split(s, sep)
    local fields = {}
    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(
        s,
        pattern,
        function(c)
            fields[#fields + 1] = c
        end
    )
    return fields
end
local function proxy(address)
    machineAddress = component.get(address)
    if (machineAddress ~= nil) then
        return component.proxy(machineAddress)
    else
        return nil
    end
end
local function configureClient()
    local file = io.open("addresses", "w")
    addEntries(file, "Add item interface", 15, "input")
    addEntries(file, "Add fluid interface", 4, "fluid")
    addEntries(file, "Add item transposer", 15, "inputTransposer")
    addEntries(file, "Add fluid transposer", 4, "fluidTransposer")
    addAuxilary(file, component.me_interface, "items")
    addAuxilary(file, component.database, "database")
    addAuxilary(file, component.gt_machine, "controller")
end
function assemblyUtil.buildClient()
    term.write("Starting Assembly Line initalization...")
    local assemblyStructure = {}
    local file = io.open("addresses", "r")
    if file == nil then
        term.write(" no address configuration found, configuring:\n")
        configureClient()
        file = io.lines("addresses")
    else
        file = io.lines("addresses")
    end
    for line in file do
        term.write(".")
        local tokens = split(line, ",")
        assemblyStructure[tokens[1]] = proxy(tokens[2])
    end
    term.write("\n")
    return assemblyStructure
end
local function voltageToTier(voltage)
    local maxTier = 15
    local tier = maxTier
    voltage = voltage - 1
    local tierVoltage = 32 * math.pow(4, tier - 1)
    while voltage % tierVoltage == voltage do
        tier = tier - 1
        tierVoltage = 32 * math.pow(4, tier - 1)
    end
    return tier + 1
end
--[[
function copyPattern(interface, slot, recipe, database)
    for i = 1, recipe.inputs, 1 do
        local item = recipe["input" .. i]
        local name = item.name
        if dictionary[name] ~= nil then
            name = dictionary[name]
        end
        interface.setInterfacePatternInput(slot, database, databaseMap[name], item.amount, i)
    end
end
--]]
function getControllerTier(assemblyData)
    local controller = assemblyData["controller"]
    return voltageToTier(
        math.floor(
            string.gsub(
                string.sub(
                    controller.getSensorInformation()[4],
                    1,
                    string.find(controller.getSensorInformation()[4], "/") - 1
                ),
                "([^0-9]+)",
                ""
            ) + 0
        )
    )
end
local function addRecipe(recipelist, slot, source, sourceSide)
    if source.getStackInSlot(sourceSide, slot) ~= nil then
        local pattern = source.getStackInSlot(sourceSide, slot)
        recipelist[pattern.output] = {}
        recipelist[pattern.output]["label"] = pattern.output
        recipelist[pattern.output]["time"] = pattern.time
        recipelist[pattern.output]["inputs"] = 0
        recipelist[pattern.output]["fluids"] = 0
        recipelist[pattern.output]["tier"] = voltageToTier(pattern.eu)
        if pattern.inputItems ~= nil then
            local items = pattern.inputItems
            for i = 1, #items, 1 do
                recipelist[pattern.output]["input" .. i] = {name = items[i][1], amount = items[i][2]}
                recipelist[pattern.output]["inputs"] = recipelist[pattern.output]["inputs"] + 1
            end
        end
        if pattern.inputFluids ~= nil then
            local fluids = pattern.inputFluids
            for i = 1, #fluids do
                recipelist[pattern.output]["fluid" .. i] = {name = fluids[i][1], amount = fluids[i][2]}
                recipelist[pattern.output]["fluids"] = recipelist[pattern.output]["fluids"] + 1
            end
        end
    end
end
function assemblyUtil.getRecipes(recipelist)
    for address, type in pairs(component.list()) do
        if type == "transposer" then
            local dataSource = proxy(address)
            for side = 0, 5 do
                if dataSource.getInventorySize(side) ~= nil then
                    local slots = dataSource.getInventorySize(side)
                    for slot = 1, slots, 1 do
                        addRecipe(recipelist, slot, dataSource, side)
                    end
                end
            end
        end
    end
end
return assemblyUtil
