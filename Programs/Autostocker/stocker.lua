component = require("component")
term = require("term")
computer = require("computer")
event = require("event")
local sides = require("sides")
graphics = require("graphics")
S = require("stockerUtil")
local uc = require("unicode")
local GPU = component.gpu
local transposer = component.transposer
local itemsToStock = {}
local craftables = {}
local currentlyCrafting = {}
local drawerItem
local number = ""
local inNumberBox = false
local function mouseListener()
    local function processClick(event, address, x, y, key, player)
        local activeWindow = graphics.checkCollision(nil, x, y)
        if activeWindow ~= nil then
            if activeWindow == "Button" then
                GPU.setActiveBuffer(0)
                if drawerItem == nil or number == "" then
                    graphics.rectangle(
                        GPU,
                        graphics.currentWindows["Button"].x + 2,
                        graphics.currentWindows["Button"].y * 2 + 1,
                        6,
                        6,
                        colors.negativeEUColor
                    )
                else
                    graphics.rectangle(
                        GPU,
                        graphics.currentWindows["Button"].x + 2,
                        graphics.currentWindows["Button"].y * 2 + 1,
                        6,
                        6,
                        colors.positiveEUColor
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
                graphics.refresh(GPU)
            elseif activeWindow == "Number" then
                GPU.setActiveBuffer(0)
                if drawerItem == nil then
                    graphics.centeredText(
                        GPU,
                        graphics.currentWindows["Number"].x + 25,
                        graphics.currentWindows["Number"].y * 2 + 3,
                        0xFFFFFF,
                        "Pattern refresh requested..."
                    )
                    S.refreshCraftables()
                end
                inNumberBox = true
                graphics.rectangle(
                    GPU,
                    graphics.currentWindows["Number"].x + 2,
                    graphics.currentWindows["Number"].y * 2 + 1,
                    46,
                    6,
                    0x333333
                )
            else
                inNumberBox = false
                number = ""
                graphics.refresh(GPU)
            end
        else
            inNumberBox = false
            number = ""
            graphics.refresh(GPU)
        end
    end
    return event.listen("touch", processClick)
end
local function keyboardListener()
    local function processKey(event, address, key, code, player)
        if inNumberBox then
            local value = uc.char(key)
            if key == 10 then
                inNumberBox = false
                graphics.refresh(GPU)
            end
            if key == 8 then
                number = string.sub(number, 1, #number - 1)
            elseif (key >= 48 and key <= 57) then
                number = number .. value
            end
            graphics.rectangle(GPU, graphics.currentWindows["Number"].x + 2, graphics.currentWindows["Number"].y * 2 + 1, 46, 6, 0x333333)
            graphics.text(
                GPU,
                graphics.currentWindows["Number"].x + 4,
                graphics.currentWindows["Number"].y * 2 + 3,
                colors.workingColor,
                number
            )
        end
    end
    return event.listen("key_down", processKey)
end
local function getNewItem(GPU, x, y)
    if graphics.currentWindows["Item"] == nil then
        local itemWindow = graphics.createWindow(GPU, 60, 6, "Item")
        graphics.currentWindows["Item"].x = x
        graphics.currentWindows["Item"].y = y
        GPU.setActiveBuffer(itemWindow)
        graphics.rectangle(GPU, 2, 2, 58, 4, colors.hudColor)
        graphics.rectangle(GPU, 3, 3, 56, 2, 0x000000)
        GPU.setActiveBuffer(0)
    end
    local newDrawerItem = transposer.getStackInSlot(sides.top, 2)
    if newDrawerItem ~= nil then
        if craftables[newDrawerItem] ~= nil then
            GPU.setForeground(colors.workingColor)
        else
            GPU.setActiveBuffer(colors.negativeEUColor)
        end
        if drawerItem == nil then
            drawerItem = newDrawerItem.label
            GPU.setActiveBuffer(graphics.currentWindows["Item"].page)
            graphics.rectangle(GPU, 3, 3, 56, 2, 0x000000)
            if craftables[drawerItem] ~= nil then
                graphics.centeredText(GPU, 30, 3, colors.positiveEUColor, drawerItem)
            else
                graphics.centeredText(GPU, 30, 3, colors.negativeEUColor, drawerItem)
            end
            GPU.setActiveBuffer(0)
            if itemsToStock[drawerItem] ~= nil then
                graphics.rectangle(GPU, graphics.currentWindows["Item"].x, graphics.currentWindows["Item"].y * 2 - 3, 60, 2, 0x000000)
                graphics.centeredText(
                    GPU,
                    graphics.currentWindows["Item"].x + 30,
                    graphics.currentWindows["Item"].y * 2 - 3,
                    0xFFFFFF,
                    "Configured: " .. itemsToStock[drawerItem]
                )
            end
            graphics.refresh(GPU)
        else
            if drawerItem ~= newDrawerItem.label then
                drawerItem = newDrawerItem.label
                GPU.setActiveBuffer(graphics.currentWindows["Item"].page)
                graphics.rectangle(GPU, 3, 3, 56, 2, 0x000000)
                if craftables[drawerItem] ~= nil then
                    graphics.centeredText(GPU, 30, 3, colors.positiveEUColor, drawerItem)
                else
                    graphics.centeredText(GPU, 30, 3, colors.negativeEUColor, drawerItem)
                end
                GPU.setActiveBuffer(0)
                if itemsToStock[drawerItem] ~= nil then
                    graphics.rectangle(GPU, graphics.currentWindows["Item"].x, graphics.currentWindows["Item"].y * 2 - 3, 60, 2, 0x000000)
                    graphics.centeredText(
                        GPU,
                        graphics.currentWindows["Item"].x + 30,
                        graphics.currentWindows["Item"].y * 2 - 3,
                        0xFFFFFF,
                        "Configured: " .. itemsToStock[drawerItem]
                    )
                end
                graphics.refresh(GPU)
            end
        end
    else
        if drawerItem ~= nil then
            drawerItem = nil
            GPU.setActiveBuffer(graphics.currentWindows["Item"].page)
            graphics.rectangle(GPU, 3, 3, 56, 2, 0x000000)
            graphics.centeredText(GPU, 30, 3, 0xFFFFFF, "")
            GPU.setActiveBuffer(0)
            graphics.rectangle(GPU, graphics.currentWindows["Item"].x, graphics.currentWindows["Item"].y * 2 - 3, 60, 2, 0x000000)
            graphics.refresh(GPU)
        end
    end
end
local function numberBox(GPU, x, y)
    if graphics.currentWindows["Number"] == nil then
        local itemWindow = graphics.createWindow(GPU, 50, 10, "Number")
        graphics.currentWindows["Number"].x = x
        graphics.currentWindows["Number"].y = y
        GPU.setActiveBuffer(itemWindow)
        graphics.rectangle(GPU, 2, 2, 48, 8, colors.hudColor)
        graphics.rectangle(GPU, 3, 3, 46, 6, 0x000000)
        GPU.setActiveBuffer(0)
    end
end
local function button(GPU, x, y)
    if graphics.currentWindows["Button"] == nil then
        local button = graphics.createWindow(GPU, 10, 10, "Button")
        graphics.currentWindows["Button"].x = x
        graphics.currentWindows["Button"].y = y
        GPU.setActiveBuffer(button)
        graphics.rectangle(GPU, 2, 2, 8, 8, colors.hudColor)
        graphics.rectangle(GPU, 3, 3, 6, 6, colors.workingColor)
        GPU.setActiveBuffer(0)
    end
end
local function craftableBox(GPU, x, y)
    if graphics.currentWindows["Craft"] == nil then
        local crafts = graphics.createWindow(GPU, 72, 100, "Craft")
        graphics.currentWindows["Craft"].x = x
        graphics.currentWindows["Craft"].y = y
        GPU.setActiveBuffer(crafts)
        graphics.rectangle(GPU, 2, 2, 70, 94, colors.hudColor)
        GPU.setActiveBuffer(0)
    end
    GPU.setActiveBuffer(graphics.currentWindows["Craft"].page)
    graphics.rectangle(GPU, 3, 4, 68, 90, 0x000000)
    graphics.rectangle(GPU, 48, 2, 1, 94, colors.hudColor)
    local i = 1
    S.updateCache()
    for label, amount in pairs(itemsToStock) do
        local stockedAmount = S.getAmount(label)
        local stockedString = string.sub(stockedAmount .. "", 1, #(stockedAmount .. "") - 2)
        local toStock = amount + 0.0
        if S.uniques() > 2500 then --Check against rebooted system
            if toStock > 0 then
                if drawerItem == label then
                    graphics.text(GPU, 4, 3 + 2 * i, colors.workingColor, label)
                elseif craftables[label] == nil then
                    graphics.text(GPU, 4, 3 + 2 * i, colors.negativeEUColor, label)
                else
                    graphics.text(GPU, 4, 3 + 2 * i, 0xFFFFFF, label)
                end
                if stockedAmount >= toStock then --In stock
                    graphics.text(GPU, 59 - (#stockedString + 1), 3 + 2 * i, 0xFFFFFF, stockedString)
                elseif stockedAmount >= toStock * 0.85 then --Edit hysteresis here, slightly below stock
                    graphics.text(GPU, 59 - (#stockedString + 1), 3 + 2 * i, colors.workingColor, stockedString)
                else --Needs to be ordered
                    --Add crafting request loop here
                    if craftables[label] ~= nil then
                        if currentlyCrafting[label] == nil then
                            currentlyCrafting[label] = craftables[label](toStock - stockedAmount)
                        elseif currentlyCrafting[label].isDone() or currentlyCrafting[label].isCanceled() then
                            currentlyCrafting[label] = nil
                        end
                    end
                    graphics.text(GPU, 59 - (#stockedString + 1), 3 + 2 * i, colors.negativeEUColor, stockedString)
                end
                graphics.text(GPU, 59, 3 + 2 * i, 0xFFFFFF, "| " .. amount)
                i = math.min(i + 1, 43)
            end
        end
    end
    GPU.setActiveBuffer(0)
    graphics.refresh(GPU)
end

mouseListener()
keyboardListener()
GPU.setResolution(160, 46)
term.clear()
graphics.clear()
numberBox(GPU, 100, 41)
button(GPU, 150, 41)
craftableBox(GPU, 0, 0)
graphics.refresh(GPU)
S.refreshCraftables()
S.loadPatterns()
local timeSinceRefresh = computer.uptime()
while true do
    getNewItem(GPU, 100, 38)
    if computer.uptime() - timeSinceRefresh > 900 then
        timeSinceRefresh = computer.uptime()
        craftableBox(GPU, 0, 0)
    end
    os.sleep(0.5)
end
