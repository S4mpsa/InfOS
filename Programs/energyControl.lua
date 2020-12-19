comp = require("component")
event = require("event")
screen = require("term")
computer = require("computer")
thread = require("thread")
uc = require("unicode")

local LSC = comp.gt_machine
local engaged = false
local function machine(address)
    machineAddress = comp.get(address)
    if (machineAddress ~= nil) then
        return comp.proxy(machineAddress)
    else
        return nil
    end
end
local function getPercentage()
    local currentEU = math.floor(string.gsub(LSC.getSensorInformation()[2], "([^0-9]+)", "") + 0)
    local maxEU = math.floor(string.gsub(LSC.getSensorInformation()[3], "([^0-9]+)", "") + 0)
    return currentEU / maxEU
end

local turbineRedstone = {
    [1] = machine("928880ed")
}
local function disengage()
    for i = 1, #turbineRedstone do
        turbineRedstone[i].setOutput(4, 0)
    end
    engaged = false
end
local function engage()
    for i = 1, #turbineRedstone do
        turbineRedstone[i].setOutput(4, 15)
    end
    engaged = true
end
local function checkLevels()
    local fill = getPercentage()
    if fill < 0.15 then
        if not engaged then
            engage()
        end
    elseif fill > 0.95 then
        if engaged then
            disengage()
        end
    end
end

disengage()
while true do
    checkLevels()
    os.sleep(5)
end
