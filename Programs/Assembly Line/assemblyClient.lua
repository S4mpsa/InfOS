comp=require("component"); event=require("event"); screen=require("term"); computer = require("computer"); thread = require("thread")
local AU = require("util")
local AT = require("transport")
local S = require("serialization"); local uc = require("unicode")
local D = require("dictionary")
local network = comp.modem
local id, AD
local function requestID()
    network.broadcast(100, "requestID")
    local _, _, _, _, _, messageType, value = event.pull("modem_message");
    while messageType ~= "sendID" do
        _, _, _, _, _, messageType, value = event.pull("modem_message")
        os.sleep(0.2)
    end
    return value
end

function checkRepeat(recipe)
    local correctItems = 0
    for i = 1, recipe.inputs, 1 do
        if AT.isEmpty(AD["inputTransposer"..i], 16) then 
            if AT.check(AD["inputTransposer"..i], recipe["input"..i].name, recipe["input"..i].amount) then
                correctItems = correctItems + 1
            else return false end
        else return false end
    end
    for i = 1, recipe.fluids, 1 do
        if AT.isEmpty(AD["fluidTransposer"..i], 1) then 
            if AT.check(AD["fluidTransposer"..i], fluidMap[recipe["fluid"..i].name].name, recipe["fluid"..i].amount / fluidMap[recipe["fluid"..i].name].size) then
                correctItems = correctItems + 1
            else return false end
        else return false end
    end
    if correctItems == recipe.inputs + recipe.fluids then return true else return false end
end

local function processRecipe(recipe)
    local database, interface = AD.database, AD.input1
    local function insert()
        for i = 1, recipe.fluids, 1 do AT.move(AD["fluidTransposer"..i], recipe["fluid"..i].amount / fluidMap[recipe["fluid"..i].name].size, 1) end
        for i = 1, recipe.inputs, 1 do AT.move(AD["inputTransposer"..i], recipe["input"..i].amount, 16) end
        for i = 1, recipe.fluids, 1 do AT.empty(AD["fluidTransposer"..i]) end
    end
    for i = 1, recipe.inputs, 1 do
        database.clear(i)
        interface.store({label = recipe["input"..i].name}, database.address, i, 1)
    end
    for i = 1, recipe.fluids, 1 do
        database.clear(20+i)
        interface.store({label = fluidMap[recipe["fluid"..i].name].name}, database.address, 20+i, 1)
    end
    for i = 1, recipe.inputs, 1 do
        AT.set(AD["input"..i], database, i, recipe["input"..i].amount)
    end
    for i = 1, recipe.fluids, 1 do
        AT.set(AD["fluid"..i], database, 20+i, recipe["fluid"..i].amount / fluidMap[recipe["fluid"..i].name].size)
    end
    ::insertRecipes::
    insert()
    while checkRepeat(recipe) do
        insert()
    end
    local wait = computer.uptime()
    while not AD.controller.hasWork() and computer.uptime() < wait + 5 do
        os.sleep(0.2)
    end
    if not AD.controller.hasWork() then
        screen.write(" ... Error with starting assembly!")
        network.broadcast(id, "jammed")
    else
        screen.write(" ... Assembly Started")
        while AD.controller.hasWork() do os.sleep(0.1) end
        if checkRepeat(recipe) then goto insertRecipes end
    end
    AT.clearAll(AD)
    screen.write(" ... finished task!\n")
    network.broadcast(id, "complete")
end

local function processMessage(localAddress, remoteAddress, port, distance, type, eventType, value2, value3)
    if eventType == "startAssembly" then
        local recipe = S.unserialize(value2)
        screen.write("Starting assembly of "..recipe.label)
        processRecipe(recipe)
    elseif eventType == "clear" then
        AT.clearAll(AD)
    end
end

local function quit()
    screen.write("Quitting...")
    event.ignore("modem_message", processMessage)
    event.ignore("key_up", processKey)
    os.exit()
end

function processKey(event, address, key, code, player)
    local value = uc.char(key)
    if value == "." then
        quit()
    end
end

local function startAssembly()
    network.open(100)
    local storedID = io.open("ID", "r")
    if storedID == nil then
        id = requestID()
        storedID = io.open("ID", "w")
        storedID:write(id)
    else
    for line in io.lines("ID") do id = line + 0 end
    end
    storedID:close()
    network.open(id)
    AD = AU.buildClient()
    AT.clearAll(AD)
end

startAssembly()
event.listen("modem_message", processMessage)
event.listen("key_up", processKey)