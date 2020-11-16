comp=require("component");screen=require("term");computer=require("computer");event=require("event"); thread = require("thread"); sides = require("sides")
get=require("utility"); ARG=require("ARGraphics"); G = require("graphics")
S = require("stockerUtil")
local uc = require("unicode"); tx = require("transforms")
config = require("config")
local GPU = comp.gpu
interface = comp.me_interface
transposer = comp.transposer
itemsToStock = {}
craftables = {}
local currentlyCrafting = {}
local drawerItem
local number = ""
function mouseListener()
    function processClick(event, address, x, y, key, player)
        local activeWindow = G.checkCollision(nil, x, y)
        if activeWindow ~= nil then
            if activeWindow == "Button" then
                GPU.setActiveBuffer(0)
                if drawerItem == nil or number == "" then
                    G.rect(GPU, currentWindows["Button"].x+2, currentWindows["Button"].y*2+1, 6, 6, negativeEUColour)
                else
                    G.rect(GPU, currentWindows["Button"].x+2, currentWindows["Button"].y*2+1, 6, 6, positiveEUColour)
                    if itemsToStock[drawerItem] ~= nil then
                        S.update(drawerItem, itemsToStock[drawerItem], number)
                        itemsToStock[drawerItem] = number
                    elseif number+0.0 > 0 then
                        S.addPattern(drawerItem, number)
                        itemsToStock[drawerItem] = number
                    else
                        itemsToStock[drawerItem] = nil
                    end
                end
                number = ""
                os.sleep(0.3)
                G.refresh(GPU)
            elseif activeWindow == "Number" then
                GPU.setActiveBuffer(0)
                if drawerItem == nil then
                    G.centeredText(GPU, currentWindows["Number"].x+25, currentWindows["Number"].y*2+3, 0xFFFFFF, "Pattern refresh requested...")
                    S.refreshCraftables()
                end
                inNumberBox = true
                G.rect(GPU, currentWindows["Number"].x+2, currentWindows["Number"].y*2+1, 46, 6, 0x333333)
            else
                inNumberBox = false
                number = ""
                G.refresh(GPU)
            end
        else
            inNumberBox = false
            number = ""
            G.refresh(GPU)
        end
    end
    return event.listen("touch", processClick)
end
function keyboardListener()
    function processKey(event, address, key, code, player)
        if inNumberBox then
            local value = uc.char(key)
            if key == 10 then
                inNumberBox = false
                G.refresh(GPU)
             end
            if key == 8 then number = string.sub(number, 1, #number-1) elseif (key >= 48 and key <= 57) then
                number = number..value
            end
            G.rect(GPU, currentWindows["Number"].x+2, currentWindows["Number"].y*2+1, 46, 6, 0x333333)
            G.text(GPU, currentWindows["Number"].x+4, currentWindows["Number"].y*2+3, workingColour, number)
        end
    end
    return event.listen("key_down", processKey)
end
function getNewItem(GPU, x, y)
    if currentWindows["Item"] == nil then
        local itemWindow = G.createWindow(GPU, 60, 6, "Item")
        currentWindows["Item"].x = x
        currentWindows["Item"].y = y
        GPU.setActiveBuffer(itemWindow)
        G.rect(GPU, 2, 2, 58, 4, hudColour)
        G.rect(GPU, 3, 3, 56, 2, 0x000000)
        GPU.setActiveBuffer(0)
    end
    local newDrawerItem = transposer.getStackInSlot(sides.top, 2)
    if newDrawerItem ~= nil then
        if craftables[newDrawerItem] ~= nil then
            GPU.setForeground(workingColour)
        else
            GPU.setActiveBuffer(negativeEUColour)
        end
        if drawerItem == nil then
            drawerItem = newDrawerItem.label
            GPU.setActiveBuffer(currentWindows["Item"].page)
            G.rect(GPU, 3, 3, 56, 2, 0x000000)
            if craftables[drawerItem] ~= nil then
                G.centeredText(GPU, 30, 3, positiveEUColour, drawerItem)
            else
                G.centeredText(GPU, 30, 3, negativeEUColour, drawerItem)
            end
            GPU.setActiveBuffer(0)
            if itemsToStock[drawerItem] ~= nil then
                G.rect(GPU, currentWindows["Item"].x, currentWindows["Item"].y*2-3, 60, 2, 0x000000)
                G.centeredText(GPU, currentWindows["Item"].x+30, currentWindows["Item"].y*2-3, 0xFFFFFF, "Configured: "..itemsToStock[drawerItem])
            end
            G.refresh(GPU)
        else
            if drawerItem ~= newDrawerItem.label then
                drawerItem = newDrawerItem.label
                GPU.setActiveBuffer(currentWindows["Item"].page)
                G.rect(GPU, 3, 3, 56, 2, 0x000000)
                if craftables[drawerItem] ~= nil then
                    G.centeredText(GPU, 30, 3, positiveEUColour, drawerItem)
                else
                    G.centeredText(GPU, 30, 3, negativeEUColour, drawerItem)
                end
                GPU.setActiveBuffer(0)
                if itemsToStock[drawerItem] ~= nil then
                    G.rect(GPU, currentWindows["Item"].x, currentWindows["Item"].y*2-3, 60, 2, 0x000000)
                    G.centeredText(GPU, currentWindows["Item"].x+30, currentWindows["Item"].y*2-3, 0xFFFFFF, "Configured: "..itemsToStock[drawerItem])
                end
                G.refresh(GPU)
            end
        end
    else
        if drawerItem ~= nil then
            drawerItem = nil
            GPU.setActiveBuffer(currentWindows["Item"].page)
            G.rect(GPU, 3, 3, 56, 2, 0x000000)
            G.centeredText(GPU, 30, 3, 0xFFFFFF, "")
            GPU.setActiveBuffer(0)
            G.rect(GPU, currentWindows["Item"].x, currentWindows["Item"].y*2-3, 60, 2, 0x000000)
            G.refresh(GPU)
        end
    end
end
function numberBox(GPU, x, y)
    if currentWindows["Number"] == nil then
        local itemWindow = G.createWindow(GPU, 50, 10, "Number")
        currentWindows["Number"].x = x
        currentWindows["Number"].y = y
        GPU.setActiveBuffer(itemWindow)
        G.rect(GPU, 2, 2, 48, 8, hudColour)
        G.rect(GPU, 3, 3, 46, 6, 0x000000)
        GPU.setActiveBuffer(0)
    end
end
function button(GPU, x, y)
    if currentWindows["Button"] == nil then
        local button = G.createWindow(GPU, 10, 10, "Button")
        currentWindows["Button"].x = x
        currentWindows["Button"].y = y
        GPU.setActiveBuffer(button)
        G.rect(GPU, 2, 2, 8, 8, hudColour)
        G.rect(GPU, 3, 3, 6, 6, workingColour)
        GPU.setActiveBuffer(0)
    end
end
function craftableBox(GPU, x, y)
    if currentWindows["Craft"] == nil then
        local crafts = G.createWindow(GPU, 72, 100, "Craft")
        currentWindows["Craft"].x = x
        currentWindows["Craft"].y = y
        GPU.setActiveBuffer(crafts)
        G.rect(GPU, 2, 2, 70, 94, hudColour)
        GPU.setActiveBuffer(0)
    end
    GPU.setActiveBuffer(currentWindows["Craft"].page)
    G.rect(GPU, 3, 4, 68, 90, 0x000000)
    G.rect(GPU, 48, 2, 1, 94, hudColour)
    local i = 1
    S.updateCache()
    for label, amount in pairs(itemsToStock) do
        local stockedAmount = S.getAmount(label)
        local stockedString = string.sub(stockedAmount.."", 1, #(stockedAmount.."")-2)
        local toStock = amount+0.0
        if S.uniques() > 2500 then --Check against rebooted system
            if toStock > 0 then
                if drawerItem == label then
                    G.text(GPU, 4, 3+2*i, workingColour, label);
                elseif craftables[label] == nil then
                    G.text(GPU, 4, 3+2*i, negativeEUColour, label);
                else
                    G.text(GPU, 4, 3+2*i, 0xFFFFFF, label);
                end
                if stockedAmount >= toStock then --In stock
                    G.text(GPU, 59 - (#stockedString + 1), 3+2*i, 0xFFFFFF, stockedString)
                elseif stockedAmount >= toStock * 0.85 then --Edit hysteresis here, slightly below stock
                    G.text(GPU, 59 - (#stockedString + 1), 3+2*i, workingColour,  stockedString)
                else --Needs to be ordered
                    --Add crafting request loop here
                    if craftables[label] ~= nil then
                        if currentlyCrafting[label] == nil then            
                            currentlyCrafting[label] = craftables[label](toStock - stockedAmount)
                        elseif currentlyCrafting[label].isDone() or currentlyCrafting[label].isCanceled() then
                            currentlyCrafting[label] = nil
                        end
                    end
                    G.text(GPU, 59 - (#stockedString + 1), 3+2*i, negativeEUColour,  stockedString)
                end
                G.text(GPU, 59, 3+2*i, 0xFFFFFF,  "| "..amount)
                i = math.min(i + 1, 43)
            end
        end
    end
    GPU.setActiveBuffer(0)
    G.refresh(GPU)
end

mouseListener(); keyboardListener(); GPU.setResolution(160, 46); screen.clear()
G.clear()
numberBox(GPU, 100, 41); button(GPU, 150, 41); craftableBox(GPU, 0, 0)
G.refresh(GPU)
S.refreshCraftables(); S.loadPatterns()
local timeSinceRefresh = computer.uptime()
while true do
    getNewItem(GPU, 100, 38)
    if computer.uptime() - timeSinceRefresh > 900 then
        timeSinceRefresh = computer.uptime()
        craftableBox(GPU, 0, 0)
    end
    os.sleep(0.5)
end
