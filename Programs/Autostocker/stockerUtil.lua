component = require("component")
graphics = require("graphics")
local tx = require("transforms")
GPU = component.gpu
local interface = component.me_interface
local sUtil = {}
local itemsToStock = {}
function sUtil.refreshCraftables()
    local craftables = interface.getCraftables()
    local max = 0
    if max > 0 then
        craftables = tx.sub(craftables, 1, max)
    end
    for i, craftable in pairs(craftables) do
        if i ~= "n" then
            if i % 10 == 0 then
                graphics.centeredText(
                    GPU,
                    graphics.currentWindows["Number"].x + 25,
                    graphics.currentWindows["Number"].y * 2 + 3,
                    0xFFFFFF,
                    "Discovering Patterns: " .. i .. " / " .. #craftables
                )
            end
        end
        if craftable ~= #craftables then
            craftables[craftable.getItemStack().label] = craftable.request
        end
    end
    graphics.centeredText(GPU, 86, 85, 0xFFFFFF, "Patterns in memory: " .. #craftables)
end
local cachedAmounts = {}
function sUtil.updateCache()
    local itemList = interface.getItemsInNetwork()
    for i = 1, #itemList, 1 do
        if i % 200 == 0 then
            os.sleep()
        end
        cachedAmounts[itemList[i].label] = itemList[i].size
        itemList[i] = nil
    end
end
function sUtil.getAmount(itemLabel)
    if cachedAmounts[itemLabel] == nil then
        return 0
    else
        return cachedAmounts[itemLabel]
    end
end
function sUtil.uniques()
    return #cachedAmounts
end
function sUtil.update(label, oldAmount, newAmount)
    local file = io.open("configured", "r")
    local fileContent = {}
    local lineNumber = 0
    local i = 1
    for line in file:lines() do
        if line == label .. "," .. oldAmount then
            lineNumber = i
        end
        table.insert(fileContent, line)
        i = i + 1
    end
    io.close(file)
    file = io.open("configured", "w")
    for index, value in ipairs(fileContent) do
        if index ~= lineNumber then
            file:write(value .. "\n")
        else
            file:write(label .. "," .. newAmount .. "\n")
        end
    end
    io.close(file)
end
function sUtil.addPattern(label, amount)
    local file = io.open("configured", "a")
    file:write(label .. "," .. amount .. "\n")
    file:close()
    itemsToStock[label] = amount
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
function sUtil.loadPatterns()
    local file = io.open("configured", "r")
    for line in file:lines() do
        local tokens = split(line, ",")
        itemsToStock[tokens[1]] = tokens[2]
    end
end

return sUtil
