Component = require("component")
Term = require("term")
Computer = require("computer")
Event = require("event")
local sides = require("sides")
Graphics = require("graphics.graphics")
S = require("stockerUtil")
local uc = require("unicode")
GPU = Component.gpu
local transposer = Component.transposer
local itemsToStock = {}
local craftables = {}
local currentlyCrafting = {}
local drawerItem
local number = ""
local inNumberBox = false
local function mouseListener()
    local function processClick(event, address, x, y, key, player)
        local activeWindow = Graphics.checkCollision(nil, x, y)
        if activeWindow ~= nil then
            if activeWindow == "Button" then
                GPU.setActiveBuffer(0)
                if drawerItem == nil or number == "" then
                    Graphics.rectangle(
                        GPU,
                        Graphics.currentWindows["Button"].x + 2,
                        Graphics.currentWindows["Button"].y * 2 + 1,
                        6,
                        6,
                        Colors.negativeEUColor
                    )
                else
                    Graphics.rectangle(
                        GPU,
                        Graphics.currentWindows["Button"].x + 2,
                        Graphics.currentWindows["Button"].y * 2 + 1,
                        6,
                        6,
                        Colors.positiveEUColor
                    )
                    if itemsToStock[drawerItem] ~= nil then
                        S.update(drawerItem, itemsToStock[drawerItem], number)
                        itemsToStock[drawerItem] = number
                    elseif number + 0.0 > 0 then
                        S.addPattern(drawerItem, number)
                        itemsToStock[drawerItem] = number
                    else
                        itemsToStock[drawerItem] = nil
                    end
                end
                number = ""
                os.sleep(0.3)
                Graphics.refresh(GPU)
            elseif activeWindow == "Number" then
                GPU.setActiveBuffer(0)
                if drawerItem == nil then
                    Graphics.centeredText(
                        GPU,
                        Graphics.currentWindows["Number"].x + 25,
                        Graphics.currentWindows["Number"].y * 2 + 3,
                        0xFFFFFF,
                        "Pattern refresh requested..."
                    )
                    S.refreshCraftables()
                end
                inNumberBox = true
                Graphics.rectangle(
                    GPU,
                    Graphics.currentWindows["Number"].x + 2,
                    Graphics.currentWindows["Number"].y * 2 + 1,
                    46,
                    6,
                    0x333333
                )
            else
                inNumberBox = false
                number = ""
                Graphics.refresh(GPU)
            end
        else
            inNumberBox = false
            number = ""
            Graphics.refresh(GPU)
        end
    end
    return Event.listen("touch", processClick)
end
local function keyboardListener()
    local function processKey(event, address, key, code, player)
        if inNumberBox then
            local value = uc.char(key)
            if key == 10 then
                inNumberBox = false
                Graphics.refresh(GPU)
            end
            if key == 8 then
                number = string.sub(number, 1, #number - 1)
            elseif (key >= 48 and key <= 57) then
                number = number .. value
            end
            Graphics.rectangle(GPU, Graphics.currentWindows["Number"].x + 2, Graphics.currentWindows["Number"].y * 2 + 1, 46, 6, 0x333333)
            Graphics.text(
                GPU,
                Graphics.currentWindows["Number"].x + 4,
                Graphics.currentWindows["Number"].y * 2 + 3,
                Colors.workingColor,
                number
            )
        end
    end
    return Event.listen("key_down", processKey)
end
local function getNewItem(GPU, x, y)
    if Graphics.currentWindows["Item"] == nil then
        local itemWindow = Graphics.createWindow(GPU, 60, 6, "Item")
        Graphics.currentWindows["Item"].x = x
        Graphics.currentWindows["Item"].y = y
        GPU.setActiveBuffer(itemWindow)
        Graphics.rectangle(GPU, 2, 2, 58, 4, Colors.hudColor)
        Graphics.rectangle(GPU, 3, 3, 56, 2, 0x000000)
        GPU.setActiveBuffer(0)
    end
    local newDrawerItem = transposer.getStackInSlot(sides.top, 2)
    if newDrawerItem ~= nil then
        if craftables[newDrawerItem] ~= nil then
            GPU.setForeground(Colors.workingColor)
        else
            GPU.setActiveBuffer(Colors.negativeEUColor)
        end
        if drawerItem == nil then
            drawerItem = newDrawerItem.label
            GPU.setActiveBuffer(Graphics.currentWindows["Item"].page)
            Graphics.rectangle(GPU, 3, 3, 56, 2, 0x000000)
            if craftables[drawerItem] ~= nil then
                Graphics.centeredText(GPU, 30, 3, Colors.positiveEUColor, drawerItem)
            else
                Graphics.centeredText(GPU, 30, 3, Colors.negativeEUColor, drawerItem)
            end
            GPU.setActiveBuffer(0)
            if itemsToStock[drawerItem] ~= nil then
                Graphics.rectangle(GPU, Graphics.currentWindows["Item"].x, Graphics.currentWindows["Item"].y * 2 - 3, 60, 2, 0x000000)
                Graphics.centeredText(
                    GPU,
                    Graphics.currentWindows["Item"].x + 30,
                    Graphics.currentWindows["Item"].y * 2 - 3,
                    0xFFFFFF,
                    "Configured: " .. itemsToStock[drawerItem]
                )
            end
            Graphics.refresh(GPU)
        else
            if drawerItem ~= newDrawerItem.label then
                drawerItem = newDrawerItem.label
                GPU.setActiveBuffer(Graphics.currentWindows["Item"].page)
                Graphics.rectangle(GPU, 3, 3, 56, 2, 0x000000)
                if craftables[drawerItem] ~= nil then
                    Graphics.centeredText(GPU, 30, 3, Colors.positiveEUColor, drawerItem)
                else
                    Graphics.centeredText(GPU, 30, 3, Colors.negativeEUColor, drawerItem)
                end
                GPU.setActiveBuffer(0)
                if itemsToStock[drawerItem] ~= nil then
                    Graphics.rectangle(GPU, Graphics.currentWindows["Item"].x, Graphics.currentWindows["Item"].y * 2 - 3, 60, 2, 0x000000)
                    Graphics.centeredText(
                        GPU,
                        Graphics.currentWindows["Item"].x + 30,
                        Graphics.currentWindows["Item"].y * 2 - 3,
                        0xFFFFFF,
                        "Configured: " .. itemsToStock[drawerItem]
                    )
                end
                Graphics.refresh(GPU)
            end
        end
    else
        if drawerItem ~= nil then
            drawerItem = nil
            GPU.setActiveBuffer(Graphics.currentWindows["Item"].page)
            Graphics.rectangle(GPU, 3, 3, 56, 2, 0x000000)
            Graphics.centeredText(GPU, 30, 3, 0xFFFFFF, "")
            GPU.setActiveBuffer(0)
            Graphics.rectangle(GPU, Graphics.currentWindows["Item"].x, Graphics.currentWindows["Item"].y * 2 - 3, 60, 2, 0x000000)
            Graphics.refresh(GPU)
        end
    end
end
local function numberBox(GPU, x, y)
    if Graphics.currentWindows["Number"] == nil then
        local itemWindow = Graphics.createWindow(GPU, 50, 10, "Number")
        Graphics.currentWindows["Number"].x = x
        Graphics.currentWindows["Number"].y = y
        GPU.setActiveBuffer(itemWindow)
        Graphics.rectangle(GPU, 2, 2, 48, 8, Colors.hudColor)
        Graphics.rectangle(GPU, 3, 3, 46, 6, 0x000000)
        GPU.setActiveBuffer(0)
    end
end
local function button(GPU, x, y)
    if Graphics.currentWindows["Button"] == nil then
        local button = Graphics.createWindow(GPU, 10, 10, "Button")
        Graphics.currentWindows["Button"].x = x
        Graphics.currentWindows["Button"].y = y
        GPU.setActiveBuffer(button)
        Graphics.rectangle(GPU, 2, 2, 8, 8, Colors.hudColor)
        Graphics.rectangle(GPU, 3, 3, 6, 6, Colors.workingColor)
        GPU.setActiveBuffer(0)
    end
end
local function craftableBox(GPU, x, y)
    if Graphics.currentWindows["Craft"] == nil then
        local crafts = Graphics.createWindow(GPU, 72, 100, "Craft")
        Graphics.currentWindows["Craft"].x = x
        Graphics.currentWindows["Craft"].y = y
        GPU.setActiveBuffer(crafts)
        Graphics.rectangle(GPU, 2, 2, 70, 94, Colors.hudColor)
        GPU.setActiveBuffer(0)
    end
    GPU.setActiveBuffer(Graphics.currentWindows["Craft"].page)
    Graphics.rectangle(GPU, 3, 4, 68, 90, 0x000000)
    Graphics.rectangle(GPU, 48, 2, 1, 94, Colors.hudColor)
    local i = 1
    S.updateCache()
    for label, amount in pairs(itemsToStock) do
        local stockedAmount = S.getAmount(label)
        local stockedString = string.sub(stockedAmount .. "", 1, #(stockedAmount .. "") - 2)
        local toStock = amount + 0.0
        if S.uniques() > 2500 then --Check against rebooted system
            if toStock > 0 then
                if drawerItem == label then
                    Graphics.text(GPU, 4, 3 + 2 * i, Colors.workingColor, label)
                elseif craftables[label] == nil then
                    Graphics.text(GPU, 4, 3 + 2 * i, Colors.negativeEUColor, label)
                else
                    Graphics.text(GPU, 4, 3 + 2 * i, 0xFFFFFF, label)
                end
                if stockedAmount >= toStock then --In stock
                    Graphics.text(GPU, 59 - (#stockedString + 1), 3 + 2 * i, 0xFFFFFF, stockedString)
                elseif stockedAmount >= toStock * 0.85 then --Edit hysteresis here, slightly below stock
                    Graphics.text(GPU, 59 - (#stockedString + 1), 3 + 2 * i, Colors.workingColor, stockedString)
                else --Needs to be ordered
                    --Add crafting request loop here
                    if craftables[label] ~= nil then
                        if currentlyCrafting[label] == nil then
                            currentlyCrafting[label] = craftables[label](toStock - stockedAmount)
                        elseif currentlyCrafting[label].isDone() or currentlyCrafting[label].isCanceled() then
                            currentlyCrafting[label] = nil
                        end
                    end
                    Graphics.text(GPU, 59 - (#stockedString + 1), 3 + 2 * i, Colors.negativeEUColor, stockedString)
                end
                Graphics.text(GPU, 59, 3 + 2 * i, 0xFFFFFF, "| " .. amount)
                i = math.min(i + 1, 43)
            end
        end
    end
    GPU.setActiveBuffer(0)
    Graphics.refresh(GPU)
end

mouseListener()
keyboardListener()
GPU.setResolution(160, 46)
Term.clear()
Graphics.clear()
numberBox(GPU, 100, 41)
button(GPU, 150, 41)
craftableBox(GPU, 0, 0)
Graphics.refresh(GPU)
S.refreshCraftables()
S.loadPatterns()
local timeSinceRefresh = Computer.uptime()
while true do
    getNewItem(GPU, 100, 38)
    if Computer.uptime() - timeSinceRefresh > 900 then
        timeSinceRefresh = Computer.uptime()
        craftableBox(GPU, 0, 0)
    end
    os.sleep(0.5)
end
