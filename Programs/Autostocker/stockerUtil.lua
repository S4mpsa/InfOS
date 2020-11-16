comp=require("component");screen=require("term");computer=require("computer");event=require("event"); thread = require("thread"); sides = require("sides")
get=require("utility"); ARG=require("ARGraphics"); G = require("graphics")
local uc = require("unicode"); tx = require("transforms")
config = require("config")
local GPU = comp.gpu
local sUtil = {}
function sUtil.refreshCraftables()
    local c = comp.me_interface.getCraftables()
    local max = 0
    if max > 0 then
        c = tx.sub(c, 1, max)
    end
    for i, craftable in pairs(c) do
        if i ~= "n" then
            if i % 10 == 0 then 
                G.centeredText(GPU, currentWindows["Number"].x+25, currentWindows["Number"].y*2+3, 0xFFFFFF, "Discovering Patterns: "..i.." / "..#c)
            end
        end
        if craftable ~= #c then
            craftables[craftable.getItemStack().label] = craftable.request
        end
    end
    G.centeredText(GPU, 86, 85, 0xFFFFFF, "Patterns in memory: "..#c)
end
local cachedAmounts = {}
function sUtil.updateCache()
    local itemList = interface.getItemsInNetwork()
    for i = 1, #itemList, 1 do
        if i % 200 == 0 then os.sleep() end
        cachedAmounts[itemList[i].label] = itemList[i].size
        itemList[i] = nil
    end
end
function sUtil.getAmount(itemLabel)
    if cachedAmounts[itemLabel] == nil then return 0 else return cachedAmounts[itemLabel] end
end
function sUtil.uniques()
    return #cachedAmounts
end
function sUtil.update(label, oldAmount, newAmount)
    local file = io.open("configured", 'r')
    local fileContent = {}
    local lineNumber = 0
    local i = 1
    for line in file:lines() do
        if line == label..","..oldAmount then lineNumber = i end
        table.insert (fileContent, line)
        i = i + 1
    end
    io.close(file)
    file = io.open("configured", 'w')
    for index, value in ipairs(fileContent) do
        if index ~= lineNumber then
            file:write(value..'\n')
        else
            file:write(label..","..newAmount..'\n')
        end
    end
    io.close(file)
end
function sUtil.addPattern(label, amount)
    local file = io.open("configured", "a")
    file:write(label..","..amount.."\n")
    file:close()
    itemsToStock[label] = amount
end
local function split(s, sep)
    local fields = {}; local sep = sep or " "; local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    return fields
end
function sUtil.loadPatterns()
    local file = io.open("configured", "r")
    for line in file:lines() do
        local tokens = split(line, ",")
        itemsToStock[tokens[1]] = tokens[2]
    end
end

return sUtil