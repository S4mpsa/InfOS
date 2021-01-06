component = require("component")
local transposer = component.transposer
local players = {["Sampsa"] = 3, ["Dark"] = 2}
local function findEmptyCans(player)
    local allItems = transposer.getAllStacks(players[player]).getAll()
    if #allItems > 30 then
        for i = 0, 39, 1 do
            if allItems[i].label == "Tin Can" then
                return i + 1
            end
        end
    end
    return nil
end

local function checkLevel(player)
    local itemStack = transposer.getStackInSlot(players[player], 28)
    if itemStack ~= nil then
        return itemStack.size
    else
        return nil
    end
end

local function transferFood(player)
    transposer.transferItem(0, players[player], 64, 1, 28)
end
local function transferEmpty(player)
    local slot = findEmptyCans(player)
    if slot ~= nil then
        transposer.transferItem(players[player], 0, 64, slot, 2)
    end
end

local function check(player)
    if transposer.getInventorySize(players[player]) == 40 then
        local inInventory = checkLevel(player)
        if inInventory ~= nil then
            if inInventory < 40 then
                transferFood(player)
            end
            os.sleep(0.2)
            transferEmpty(player)
        end
    end
end

while true do
    check("Sampsa")
    check("Dark")
    os.sleep(2)
end
