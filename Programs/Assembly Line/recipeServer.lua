comp = require("component")
event = require("event")
screen = require("term")
computer = require("computer")
thread = require("thread")
uc = require("unicode")
AU = require("util")
local S = require("serialization")
local D = require("dictionary")
local network = comp.modem
local mainChannel = 100
-- mainChannel = Main channel for bi-directional communication

local knownAssemblyLines = 0
local assemblyStatus = {}
local run = true
local function getIDs()
    local knownIDs = io.open("IDs", "r")
    if knownIDs == nil then
        knownAssemblyLines = 0
    else
        for line in io.lines("IDs") do
            knownAssemblyLines = knownAssemblyLines + 1
            network.open(mainChannel + knownAssemblyLines)
            assemblyStatus[mainChannel + knownAssemblyLines] = false
        end
    end
end
local function contains(t, value)
    for k, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end
local function getFree()
    for i = mainChannel, mainChannel + knownAssemblyLines, 1 do
        if assemblyStatus[i] == false then
            return i
        end
    end
    return nil
end

local function processMessage(type, localAddress, remoteAddress, port, distance, eventType, value2, value3)
    if eventType == "requestID" then
        knownAssemblyLines = knownAssemblyLines + 1
        local newID = mainChannel + knownAssemblyLines
        assemblyStatus[newID] = false
        network.broadcast(mainChannel, "sendID", newID)
        local knownIDs = io.open("IDs", "a")
        knownIDs:write(newID .. "\n")
        knownIDs:close()
    elseif eventType == "complete" then
        assemblyStatus[port] = false
    end
end

local function quit()
    screen.write("Quitting...")
    event.ignore("modem_message", processMessage)
    event.ignore("key_up", processKey)
    run = false
end

function processKey(event, address, key, code, player)
    local value = uc.char(key)
    if value == "." then
        quit()
    elseif value == "a" then
        AU.getRecipes(RL)
    end
end

function startAssembly(assemblyport, recipe)
    assemblyStatus[assemblyport] = recipe.label
    network.broadcast(assemblyport, "startAssembly", S.serialize(recipe))
end
local function spairs(t, order)
    local keys = {}
    for k in pairs(t) do
        keys[#keys + 1] = k
    end
    if order then
        table.sort(
            keys,
            function(a, b)
                return order(t, a, b)
            end
        )
    else
        table.sort(keys)
    end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
function matchRecipe(recipes)
    local items = comp.me_interface.getItemsInNetwork()
    local foundItems = {}
    if #items > 0 then
        for i = 1, #items, 1 do
            foundItems[items[i].label] = items[i].size
        end
    end
    for outputLabel, recipe in spairs(
        recipes,
        function(t, a, b)
            return t[b].inputs < t[a].inputs
        end
    ) do
        local found = 0
        local craftable = 1000
        for i = 1, recipe.inputs, 1 do
            local label, requiredAmount = recipe["input" .. i].name, recipe["input" .. i].amount
            if dictionary[label] ~= nil then
                label = dictionary[label]
            end
            if foundItems[label] == nil then
                break
            else
                local existingAmount = foundItems[label]
                if existingAmount >= requiredAmount then
                    found = found + 1
                    craftable = math.min(math.floor(existingAmount / requiredAmount), craftable)
                end
            end
        end
        for i = 1, recipe.fluids, 1 do
            local label, requiredAmount
            if fluidMap[recipe["fluid" .. i].name] ~= nil then
                label, requiredAmount =
                    fluidMap[recipe["fluid" .. i].name].name,
                    recipe["fluid" .. i].amount / fluidMap[recipe["fluid" .. i].name].size
            else
                break
            end
            if foundItems[label] == nil then
                break
            else
                local existingAmount = foundItems[label]
                if existingAmount >= requiredAmount then
                    found = found + 1
                    craftable = math.min(math.floor(existingAmount / requiredAmount), craftable)
                end
            end
        end
        if found == recipe.inputs + recipe.fluids then
            return recipe, craftable
        end
    end
    return nil
end
RL = {}
local function scheduleTasks()
    local recipe, craftable = matchRecipe(RL)
    if recipe ~= nil then
        if craftable <= 8 then
            if not contains(assemblyStatus, recipe.label) then
                local taskid = getFree()
                if taskid ~= nil then
                    screen.write("Started assembly of " .. recipe.label .. " with AL #" .. taskid .. "\n")
                    startAssembly(taskid, recipe)
                else
                    screen.write("No free assembly lines.\n")
                end
            end
            return true
        else
            while craftable > 0 do
                local taskid = getFree()
                if taskid ~= nil then
                    startAssembly(taskid, recipe)
                    screen.write("Started assembly of " .. recipe.label .. " with AL #" .. taskid .. "\n")
                else
                    screen.write("No free assembly lines.\n")
                end
                craftable = craftable - 8
            end
        end
        return true
    else
        return false
    end
end

--"gt.metaitem.01.32606.name"
local function initializeServer()
    network.open(mainChannel)
    getIDs()
    AU.getRecipes(RL)
end

initializeServer()
event.listen("modem_message", processMessage)
event.listen("key_up", processKey)

while run do
    scheduleTasks()
    os.sleep(2)
end
