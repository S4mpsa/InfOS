comp=require("component"); event=require("event"); screen=require("term"); computer = require("computer"); thread = require("thread")
dict=require("dictionary"); line = require("transport"); config = require("configure")
function machine(address)
    machineAddress = comp.get(address)
    if(machineAddress ~= nil) then return comp.proxy(machineAddress) else return nil end
end
function findAddress(type)
    for address, component in comp.list() do
        if component == type then return address end
    end
end
recipes = {}
fluidMap = {["fluid.molten.solderingalloy"] = {index = 81, size = 144},
    ["fluid.lubricant"] = {index = 80, size = 250},
    ["IC2 Coolant"] = {index = 79, size = 1000},
    ["fluid.molten.styrenebutadienerubber"] = {index = 78, size = 720},
    ["fluid.molten.niobiumtitanium"] = {index = 77, size = 144},
    ["fluid.molten.tritanium"] = {index = 76, size = 144},
    ["fluid.Neon"] = {index = 75, size = 1000}

}
local function addRecipe(slot, source, sourceSide)
    if source.getStackInSlot(sourceSide, slot) ~= nil then
        --screen.write("Adding a recipe\n")
        local pattern = source.getStackInSlot(sourceSide, slot)
        recipes[pattern.output] = {}
        recipes[pattern.output]["label"] = pattern.output
        recipes[pattern.output]["time"] = pattern.time
        recipes[pattern.output]["inputs"] = 0
        recipes[pattern.output]["fluids"] = 0
        recipes[pattern.output]["tier"] = voltageToTier(pattern.eu)
        if pattern.inputItems ~= nil then
            local items = pattern.inputItems
            for i = 1, #items, 1 do
                --screen.write("Item "..i.." :"..items[i][1].." - "..items[i][2].."\n")
                recipes[pattern.output]["input"..i] = {name = items[i][1], amount = items[i][2]}
                recipes[pattern.output]["inputs"] = recipes[pattern.output]["inputs"] + 1
            end
        end
        if pattern.inputFluids ~= nil then
            local fluids = pattern.inputFluids
            for i = 1, #fluids do
                --screen.write("Fluid "..i.." :"..fluids[i][1].." - "..fluids[i][2].."\n")
                recipes[pattern.output]["fluid"..i] = {name = fluids[i][1], amount = fluids[i][2]}
                recipes[pattern.output]["fluids"] = recipes[pattern.output]["fluids"] + 1
            end
        end
    end
end
function getRecipes(assemblyData)
    if assemblyData["data"] ~= nil then
        for i = 1, 16 do
            addRecipe(i, assemblyData["data"], 0)
        end
    end
end
function copyPattern(interface, slot, recipe, database)
    for i = 1, recipe.inputs, 1 do
        local item = recipe["input"..i]
        local name = item.name
        if dictionary[name] ~= nil then name = dictionary[name] end
        interface.setInterfacePatternInput(slot, database, databaseMap[name], item.amount, i)
    end
end
local latestRecipe = {}
function processRecipe(assemblyData, recipe)
    local inventory, database = assemblyData["inventory"], assemblyData["database"]
    local needsConfiguring = false
    if latestRecipe ~= nil then
        if latestRecipe.label ~= recipe.label then
            needsConfiguring = true
            if latestRecipe.inputs ~= nil then
                if latestRecipe.inputs > recipe.inputs then
                    line.clearInterfaces(assemblyData, recipe.inputs + 1, latestRecipe.inputs, latestRecipe.fluids - recipe.fluids, 4)
                elseif latestRecipe.fluids > recipe.fluids then
                    line.clearInterfaces(assemblyData, 0, 0, recipe.fluids + 1, latestRecipe.fluids)
                end
            end
        end
    else
        needsConfiguring = true
    end
    if needsConfiguring then
        for i = 1, recipe["inputs"], 1 do
            local item = recipe["input"..i]
            local name = item.name
            if dictionary[name] ~= nil then name = dictionary[name] end
            if databaseMap[name] == nil then screen.write(" Updating database..."); updateDatabase(assemblyData, databaseMap); end
            assemblyData["input"..i].setInterfaceConfiguration(1, database.address, databaseMap[name], item.amount)
            screen.write(".")
        end
        for i = 1, recipe["fluids"], 1 do
            local fluid = recipe["fluid"..i]
            assemblyData["fluid"..i].setInterfaceConfiguration(1, database.address, fluidMap[fluid.name].index, fluid.amount/fluidMap[fluid.name].size)
            screen.write(".")
        end
        if assemblyData["input15"].getInterfacePattern(1) ~= nil then
            copyPattern(assemblyData["input15"], 1, recipe, database.address)
        end
    end
    screen.write(" Inserting ...")
    for i = 1, recipe["inputs"], 1 do
        local item = recipe["input"..i]
        assemblyData["inputTransposer"..i].transferItem(0, 1, item.amount, 1, 16)
        screen.write(".")
    end
    for i = 1, recipe["fluids"], 1 do
        local fluid = recipe["fluid"..i]
        assemblyData["fluidTransposer"..i].transferItem(0, 1, fluid.amount/fluidMap[fluid.name].size, 1, 1)
        screen.write(".")
    end
    os.sleep(1)
    for i = 1, recipe["fluids"], 1 do
        local fluid = recipe["fluid"..i]
        assemblyData["fluidTransposer"..i].transferItem(1, 0, fluid.amount/fluidMap[fluid.name].size, 2, 9)
        screen.write(".")
    end
    local recipeTicks = (recipe.time / math.pow(2, assemblyData.tier - recipe.tier))
    if needsConfiguring == false then
        os.sleep(recipeTicks / 20 - 1.5)
    end
    latestRecipe = recipe
    line.waitForAssemblyline(recipeTicks - 50 , assemblyData["controller"])
end
function matchRecipe(recipeList, assemblyData, priority)
    priority = priority or nil
    local network = assemblyData["items"].getItemsInNetwork()
    local size = #network * 2
    if size == 0 then size = 1 end
    foundItems = {}
    for i = 1, #network, 1 do
        foundItems[network[i].label] = network[i].size end
    for i = 1, 15, 1 do
        if assemblyData["inputTransposer"..i].getStackInSlot(0, 1) ~= nil then
            local interfaceItem = assemblyData["inputTransposer"..i].getStackInSlot(0, 1)
            if interfaceItem.size ~= nil then
                if foundItems[interfaceItem.label] == nil then
                    foundItems[interfaceItem.label] = interfaceItem.size
                else
                    foundItems[interfaceItem.label] = foundItems[interfaceItem.label] + interfaceItem.size
                end
            end
        end
    end
    for recipeLabel, v in pairs(recipeList) do 
        local recipe, found = recipeList[recipeLabel], 0
        local inputs = recipe.inputs
        if debugMode then screen.write("Checking match for: "..recipeLabel.." with required N of "..recipe.inputs.."\n") end
        for i = 1, inputs, 1 do
            local label, requiredAmount = recipe["input"..i].name, recipe["input"..i].amount
            if dictionary[label] ~= nil then label = dictionary[label] end
            if debugMode then screen.write("    Searching for "..requiredAmount.." "..label) end
            if foundItems[label] == nil then if debugMode then screen.write("\n") end break
            else
                local existingAmount = foundItems[label]
                if existingAmount >= requiredAmount then
                    found = found + 1
                    if debugMode then screen.write(" | Found!: "..label.." N: "..found.."\n") end
                else if debugMode then screen.write(" | Didn't find enough: "..existingAmount.."\n") end
                end
            end
        end
        if found == inputs then
            if priority == nil then
                return recipe
            else
                if priority.label == recipe.label then return recipe end
            end
        end
    end
    return nil
end
function voltageToTier(voltage)
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
function getControllerTier(assemblyData)
    local controller = assemblyData["controller"]
    return voltageToTier(math.floor(string.gsub(string.sub(controller.getSensorInformation()[4], 1, string.find(controller.getSensorInformation()[4], "/")-1), "([^0-9]+)", "") + 0))
end
function refreshDatabase(assemblyData, databaseRef)
    local database = assemblyData["database"]
    local i = 2
    local entry = database.get(i)
    while database.get(i) ~= nil do
        screen.write(".")
        databaseRef[entry.label] = i
        i = i + 1
        entry = database.get(i)
    end
end
function updateDatabase(assemblyData, databaseMap)
    local chestSide = 5
    if assemblyData["inventory"] ~= nil and assemblyData["database"] ~= nil then
        local inventory, database = assemblyData["inventory"], assemblyData["database"]
        for i = 1, inventory.getInventorySize(chestSide), 1 do
            if inventory.getStackInSlot(chestSide, i) ~= nil then
                inventory.store(chestSide, i, database.address, 1)
                local hash = database.computeHash(1)
                database.clear(1)
                local index = database.indexOf(hash)
                if index < 0 then
                    local j = 2
                    while database.get(j) ~= nil do
                        j = j + 1
                    end
                    inventory.store(chestSide, i, database.address, j)
                    databaseMap[inventory.getStackInSlot(chestSide, i).label] = j
                end
            end
        end
    end
end
function split(s, sep)
    local fields = {}; local sep = sep or " "; local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    return fields
end
function buildAssembly()
    screen.write("Starting Assembly Line initalization...")
    local assemblyStructure = {}
    local file = io.open("addresses", "r")
    if file == nil then
        screen.write(" no address configuration found, configuring:\n")
        config.getAddresses()
        file = io.lines("addresses")
    else
        file = io.lines("addresses")
    end
    for line in file do
        screen.write(".")
        local tokens = split(line, ",")
        assemblyStructure[tokens[1]] = machine(tokens[2])
    end
    screen.write("\n")
    return assemblyStructure
end
function startAssembly(assemblyData)
    assemblyData["tier"] = getControllerTier(assemblyData)
    screen.write("Fetching recipes ... "); getRecipes(assemblyData); screen.write("Done")
    databaseMap = {}
    screen.write(" | Refreshing database ..."); refreshDatabase(assemblyData, databaseMap); screen.write(" Done")
    screen.write(" | Clearing interfaces ... "); line.clearInterfaces(assemblyData); screen.write("Done")
    debugMode = false
    local cyclesSinceRefresh = 0
    local configured = false
    screen.write(" | Beginning operation\n")
    while true do
        local foundRecipe = matchRecipe(recipes, assemblyData)
        if foundRecipe ~= nil then
            screen.write("Starting assembly of "..foundRecipe.label.." ...")
            processRecipe(assemblyData, foundRecipe)
            screen.write(" Done!\n")
            configured = true
        else
            if cyclesSinceRefresh > 20 then
                getRecipes(assemblyData)
                cyclesSinceRefresh = 0
            end
            cyclesSinceRefresh = cyclesSinceRefresh + 1
            if configured then
                configured = false
                line.clearInterfaces(assemblyData)
                latestRecipe = nil
            end
            os.sleep(5)
        end
    end
end
local assemblyLine = buildAssembly()
startAssembly(assemblyLine)

--Things to add:
--Make pattern match check for item sums instead of on a stack basis
--Add sanity check that everything was moved 100%