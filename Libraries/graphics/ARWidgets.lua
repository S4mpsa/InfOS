Component = require("component")
Computer = require("computer")
Event = require("event")
Get = require("easy")
ARG = require("ARGraphics")
Colors = require("colors")
local ARWidgets = {}

local firstRead, lastRead, counter, currentIO = 0, 0, 1, 1
local euUpdateInterval = 120
local readings = {}
local function updateEU(LSC)
    if counter == 1 then
        firstRead = Computer.uptime()
    end
    if counter < euUpdateInterval then
        readings[counter] = string.gsub(LSC.getSensorInformation()[2], "([^0-9]+)", "") + 0
        counter = counter + 1
    end
    if counter == euUpdateInterval then
        lastRead = Computer.uptime()
        local ticks = math.ceil((lastRead - firstRead) * 20)
        currentIO = math.floor((readings[euUpdateInterval - 1] - readings[1]) / ticks)
        counter = 1
    end
end
local currentEU, maxEU, percentage, fillTime, fillTimeString = 1, 1, 1, 1, 1
local initializePowerDisplay = true
local maxEnergyObj, currentEnergyObj, currentFillrateObj, percentageObj, timeObj
function ARWidgets.powerDisplay(glasses, data, x, y, w, h)
    local powerFill
    local powerEmpty
    updateEU(data)
    currentEU = math.floor(string.gsub(data.getSensorInformation()[2], "([^0-9]+)", "") + 0)
    maxEU = math.floor(string.gsub(data.getSensorInformation()[3], "([^0-9]+)", "") + 0)
    percentage = currentEU / maxEU
    if initializePowerDisplay then
        ARG.hudRectangle(glasses, x, y, w, h, Colors.hudColor)
        ARG.hudRectangle(glasses, x, y + h, w, 12, Colors.hudColor, 0.6)
        ARG.hudTriangle(
            glasses,
            {x + 2, y + 3},
            {x + 2, y + 3 + h - 6},
            {x + 2 + h - 6, y + 3 + h - 6},
            Colors.hudColor
        )
        ARG.hudTriangle(
            glasses,
            {x + 2 + w - 4, y + 3},
            {x + 2 + w - 4 - (h - 6), y + 3},
            {x + 2 + w - 4, y + 3 + h - 6},
            Colors.hudColor
        )
        ARG.hudRectangle(glasses, x, y + h, 25, 12, Colors.hudColor)
        ARG.hudTriangle(glasses, {x + 25, y + h}, {x + 25, y + h + 12}, {x + 37, y + h + 12}, Colors.hudColor)
        ARG.hudRectangle(glasses, x + w - 25, y + h, 25, 12, Colors.hudColor)
        ARG.hudTriangle(glasses, {x + w - 37, y + h}, {x + w - 25, y + h + 12}, {x + w - 25, y + h}, Colors.hudColor)
        powerFill =
            ARG.hudQuad(
            glasses,
            {x + 2, y + 3},
            {x + 2 + h - 6, y + 3 + h - 6},
            {math.min(x + 2 + w - 5, (w - 4) * percentage), y + 3 + (h - 6)},
            {math.min(x + 2 + w - 5 - (h - 6), (w - 4) * percentage - (h - 6)), y + 3},
            Colors.workingColor
        )
        powerEmpty =
            ARG.hudQuad(
            glasses,
            {math.min(x + 2 + w - 5 - (h - 6), (w - 4) * percentage - (h - 6)), y + 3},
            {math.min(x + 2 + w - 5, (w - 4) * percentage), y + 3 + (h - 6)},
            {x + 2 + w - 5, y + 3 + h - 6},
            {x + 2 + w - 5 - (h - 6), y + 3},
            Colors.machineBackground
        )

        maxEnergyObj = ARG.hudText(glasses, "", x + w - 88, y - 8, Colors.idleColor)
        currentEnergyObj = ARG.hudText(glasses, "", x + 2, y - 8, Colors.workingColor)
        currentFillrateObj = ARG.hudText(glasses, "", x + w / 2 - 20, y + h + 1, 0xFFFFFF)
        percentageObj = ARG.hudText(glasses, "", x + w / 2 - 5, y - 8, Colors.labelColor)
        timeObj = ARG.hudText(glasses, "", x + 35, y + h + 1, Colors.labelColor)
        initializePowerDisplay = false
    end
    if currentIO >= 0 then
        fillTime = math.floor((maxEU - currentEU) / (currentIO * 20))
        fillTimeString = "Full: " .. Get.time(math.abs(fillTime))
    else
        fillTime = math.floor((currentEU) / (currentIO * 20))
        fillTimeString = "Empty: " .. Get.time(math.abs(fillTime))
    end
    powerFill.setVertex(1, x + 2, y + 3)
    powerFill.setVertex(2, x + 2 + h - 6, y + 3 + h - 6)
    powerFill.setVertex(3, math.min(x + 2 + w - 5, (w - 4) * percentage), y + 3 + (h - 6))
    powerFill.setVertex(4, math.min(x + 2 + w - 5 - (h - 6), (w - 4) * percentage - (h - 6)), y + 3)
    powerEmpty.setVertex(1, math.min(x + 2 + w - 5 - (h - 6), (w - 4) * percentage - (h - 6)), y + 3)
    powerEmpty.setVertex(2, math.min(x + 2 + w - 5, (w - 4) * percentage), y + 3 + (h - 6))
    powerEmpty.setVertex(3, x + 2 + w - 5, y + 3 + h - 6)
    powerEmpty.setVertex(4, x + 2 + w - 5 - (h - 6), y + 3)
    maxEnergyObj.setText(Get.splitNumber(maxEU) .. " EU")
    if percentage > 0.995 then
        currentEnergyObj.setText(Get.splitNumber(maxEU) .. " EU")
        percentageObj.setText(Get.getPercent(1.0))
    else
        currentEnergyObj.setText(Get.splitNumber(currentEU) .. " EU")
        percentageObj.setText(Get.getPercent(percentage))
    end
    if currentIO >= 0 then
        currentFillrateObj.setText("+" .. Get.splitNumber(currentIO) .. " EU/t")
        currentFillrateObj.setColor(0, 1, 0)
    else
        currentFillrateObj.setColor(1, 0, 0)
        currentFillrateObj.setText(Get.splitNumber(currentIO) .. " EU/t")
    end
    if percentage < 0.985 then
        timeObj.setText(fillTimeString)
    else
        timeObj.setText("")
    end
end
function ARWidgets.minimapOverlay(glasses)
    --Minimap Borders
    ARG.hudRectangle(glasses, 728, 10, 123, 3, Colors.hudColor)
    ARG.hudRectangle(glasses, 728, 130, 123, 3, Colors.hudColor)
    ARG.hudRectangle(glasses, 728, 10, 3, 123, Colors.hudColor)
    ARG.hudRectangle(glasses, 848, 10, 3, 123, Colors.hudColor)
    --Coordinate Borders
    ARG.hudTriangle(glasses, {743, 133}, {728, 133}, {743, 143}, Colors.hudColor)
    ARG.hudRectangle(glasses, 743, 133, 8, 10, Colors.hudColor)
    ARG.hudRectangle(glasses, 751, 140, 170, 3, Colors.hudColor)
    --Biome Borders
    ARG.hudTriangle(glasses, {768, 143}, {753, 143}, {768, 153}, Colors.hudColor)
    ARG.hudRectangle(glasses, 768, 150, 170, 3, Colors.hudColor)
    ARG.hudRectangle(glasses, 829, 133, 50, 7, 0, 0.8)
    ARG.hudRectangle(glasses, 811, 143, 50, 7, 0, 0.8)
    --FPS Borders
    ARG.hudRectangle(glasses, 728, 0, 150, 2, Colors.hudColor)
    ARG.hudRectangle(glasses, 728, 0, 22, 12, Colors.hudColor)
    ARG.hudRectangle(glasses, 750, 2, 28, 8, 0, 0.8)
    ARG.hudTriangle(glasses, {758, 2}, {750, 2}, {750, 10}, Colors.hudColor)
    ARG.hudRectangle(glasses, 801, 2, 70, 8, 0, 0.8)
    ARG.hudRectangle(glasses, 851, 10, 5, 123, 0, 0.8)
end
function ARWidgets.hudOverlayBase(glasses, x, y)
    local hotbarSplitter = ARG.hudRectangle(glasses, x, y, 183, 2, Colors.hudColor)
    local expSplitter = ARG.hudRectangle(glasses, x, y - 6, 183, 2, Colors.hudColor)
    local expOverlay = ARG.hudRectangle(glasses, x, y - 4, 183, 4, Colors.workingColor, 0.5)
    local leftBorder = ARG.hudRectangle(glasses, x - 1, y - 13, 3, 38, Colors.hudColor)
    local rightBorder = ARG.hudRectangle(glasses, x + 182, y - 5, 3, 30, Colors.hudColor)
    local armorBox = ARG.hudRectangle(glasses, x, y - 27, 90, 15, Colors.hudColor, 0.0)
    local hpBox = ARG.hudRectangle(glasses, x + 1, y - 15, 94, 10, Colors.hudColor, 0.7)
    local hpStopper =
        ARG.hudQuad(glasses, {x + 88, y - 16}, {x + 77, y - 5}, {x + 108, y - 5}, {x + 97, y - 16}, Colors.hudColor)
    local topBorder = ARG.hudRectangle(glasses, x + 4, y - 18, 178, 3, Colors.hudColor)
    local topWedge = ARG.hudTriangle(glasses, {x + 4, y - 18}, {x - 1, y - 13}, {x + 4, y - 13}, Colors.hudColor)
    local connector = ARG.hudTriangle(glasses, {x + 182, y - 18}, {x + 182, y}, {x + 200, y}, Colors.hudColor)
    local topStrip = ARG.hudRectangle(glasses, x + 4, y - 17, 178, 1, Colors.workingColor)
    local expWedge1 = ARG.hudTriangle(glasses, {x + 179, y - 4}, {x + 183, y}, {x + 183, y - 4}, Colors.hudColor)
    local expWedge2 = ARG.hudTriangle(glasses, {x + 2, y - 5}, {x + 2, y}, {x + 6, y}, Colors.hudColor)
    --CPU Monitor
    local base = ARG.hudRectangle(glasses, x + 185, y, 28, 24, Colors.hudColor)
    local cpuStrip = ARG.hudRectangle(glasses, x + 185, y, 500, 3, Colors.hudColor)
    local itemBorder1 = ARG.hudRectangle(glasses, x + 28 + 185, y + 3, 1, 21, Colors.workingColor, 0.8)
    local itemBorder2 = ARG.hudRectangle(glasses, x + 28 + 185, y + 3, 61, 1, Colors.workingColor, 0.8)
    local itemBorder3 = ARG.hudRectangle(glasses, x + 88 + 185, y + 3, 1, 21, Colors.workingColor, 0.8)
    local itemBorder4 = ARG.hudRectangle(glasses, x + 28 + 185, y + 23, 61, 1, Colors.workingColor, 0.8)
    local cpuBase1 = ARG.hudRectangle(glasses, x + 89 + 185, y, 5, 24, Colors.hudColor)
    local connectorStrip =
        ARG.hudQuad(
        glasses,
        {x + 182, y - 17},
        {x + 182, y - 16},
        {x + 213, y + 15},
        {x + 213, y + 14},
        Colors.workingColor
    )
end
function ARWidgets.popupText(glasses, text, x, y, color)
    local substringLength = 1
    local width = #text * 5
    local steps = math.ceil(#text / substringLength)
    local stepLength = substringLength * 5
    local i = 1
    local background =
        ARG.hudQuad(
        glasses,
        {x - 5, y},
        {x - 5, y + 9},
        {x - 5 + 1, y + 9},
        {x - 5 + 1, y},
        Colors.machineBackground,
        0.5
    )
    local top =
        ARG.hudQuad(glasses, {x - 5, y - 1}, {x - 5, y}, {x - 5 + 1, y}, {x - 5 + 1, y - 1}, Colors.machineBackground)
    local bottom =
        ARG.hudQuad(
        glasses,
        {x - 5, y + 9},
        {x - 5, y + 10},
        {x - 5 + 1, y + 10},
        {x - 5 + 1, y + 9},
        Colors.machineBackground
    )
    local hudText = ARG.hudText(glasses, "", x + 1, y + 1, color)
    local wedge =
        ARG.hudQuad(
        glasses,
        {x - 5 - 10, y - 1},
        {x - 5, y - 1},
        {x - 5, y + 10},
        {x - 5 + 11, y + 10},
        Colors.machineBackground
    )
    local direction = 1
    local function advance()
        background.setVertex(3, math.min(width + 10, x + stepLength * i + 10), y + 9)
        background.setVertex(4, math.min(width, x + stepLength * i), y)
        top.setVertex(3, math.min(width, x + stepLength * i), y)
        top.setVertex(4, math.min(width, x + stepLength * i), y - 1)
        bottom.setVertex(3, math.min(width + 10, x + stepLength * i + 10), y + 10)
        bottom.setVertex(4, math.min(width + 10, x + stepLength * i + 10), y + 9)
        wedge.setVertex(1, math.min(width - 1, x + stepLength * i - 1), y - 1)
        wedge.setVertex(2, math.min(width + 10, x + stepLength * i + 10), y + 10)
        wedge.setVertex(3, math.min(width + 11, x + stepLength * i + 11), y + 10)
        wedge.setVertex(4, math.min(width + 1, x + stepLength * i + 1), y - 1)
        hudText.setText(string.sub(text, 1, substringLength * i))
        i = i + direction
        if i < 0 then
            glasses.removeObject(background.getID())
            glasses.removeObject(top.getID())
            glasses.removeObject(bottom.getID())
            glasses.removeObject(hudText.getID())
            glasses.removeObject(wedge.getID())
        end
    end
    local function retract()
        direction = -1
        Event.timer(0.03, advance, steps + 2)
    end
    Event.timer(0.03, advance, steps)
    return retract
end
local initFluidMap = true
local fillLevels = {}
local lastRefresh = Computer.uptime() - 30
function ARWidgets.fluidMonitor(glasses, x, y, fluidMap)
    local w = 60
    local h = 9
    local entries = 0
    local fluids = Component.me_interface.getFluidsInNetwork()
    if initFluidMap then
        for i = 0, #fluidMap, 1 do
            local background =
                ARG.hudQuad(
                glasses,
                {x - 8, y + i * h},
                {x - 8, y + 8 + i * h},
                {x + w, y + 8 + i * h},
                {x + w, y + i * h},
                Colors.hudColor,
                0.5
            )
            local top =
                ARG.hudQuad(
                glasses,
                {x - 10, y - 1 + i * h},
                {x - 10, y + i * h},
                {x + w, y + i * h},
                {x + w, y - 1 + i * h},
                Colors.hudColor
            )
            local bottom =
                ARG.hudQuad(
                glasses,
                {x - 7, y + 8 + i * h},
                {x - 8, y + 9 + i * h},
                {x + w, y + 9 + i * h},
                {x + w, y + 8 + i * h},
                Colors.hudColor
            )
            local fill =
                ARG.hudQuad(
                glasses,
                {x + w, y + i * h},
                {x + w, y + 8 + i * h},
                {x + w, y + 8 + i * h},
                {x + w, y + i * h},
                fluidMap[i].color,
                0.7
            )
            local text = ARG.hudText(glasses, fluidMap[i].displayName, x, y + i * h, 0x777777, 0.75)
            text.setPosition(x * 1.33333 + 4, (y + i * h) * 1.33333 + 2)
            fillLevels[fluidMap[i].label] = fill
            if i % 2 == 0 then
                local wedge =
                    ARG.hudQuad(
                    glasses,
                    {x - 10, y + i * h},
                    {x - 10, y + 9 + i * h},
                    {x - 6, y + 9 + i * h},
                    {x + 3, y + i * h},
                    Colors.hudColor
                )
            else
                local wedge =
                    ARG.hudQuad(
                    glasses,
                    {x - 10, y + i * h},
                    {x - 10, y + 9 + i * h},
                    {x + 3, y + 9 + i * h},
                    {x - 6, y + i * h},
                    Colors.hudColor
                )
            end
            entries = i
        end
        entries = entries + 1
        local finish =
            ARG.hudQuad(
            glasses,
            {x - 10, y + entries * h},
            {x - 2, y + 8 + entries * h},
            {x + w, y + 8 + entries * h},
            {x + w, y + entries * h},
            Colors.hudColor
        )
        local verticalStrip =
            ARG.hudQuad(
            glasses,
            {x - 8, y},
            {x - 8, y - 2 + entries * h},
            {x - 7, y - 2 + entries * h},
            {x - 7, y},
            Colors.workingColor
        )
        local diagonalStrip =
            ARG.hudQuad(
            glasses,
            {x - 8, y - 2 + entries * h},
            {x, y + 6 + entries * h},
            {x, y + 5 + entries * h},
            {x - 7, y - 2 + entries * h},
            Colors.workingColor
        )
        local horizontalStrip =
            ARG.hudQuad(
            glasses,
            {x, y + 5 + entries * h},
            {x, y + 6 + entries * h},
            {x + w, y + 6 + entries * h},
            {x + w, y + 5 + entries * h},
            Colors.workingColor
        )
        initFluidMap = false
    elseif Computer.uptime() - lastRefresh > 30 then
        for i = 0, #fluidMap, 1 do
            local fillQuad = fillLevels[fluidMap[i].label]
            local currentLevel = 0
            for f = 1, #fluids, 1 do
                if fluids[f].label == fluidMap[i].label then
                    currentLevel = fluids[f].amount
                end
            end
            local fillPercentage = math.min(currentLevel / (fluidMap[i].max * 1000000.0), 1)
            fillQuad.setVertex(1, x + w - fillPercentage * (w + 8), y + i * h)
            fillQuad.setVertex(2, x + w - fillPercentage * (w + 8), y + 8 + i * h)
        end
        lastRefresh = Computer.uptime()
    end
end
local function refreshDatabase(itemList)
    local filteredList = {}
    for i = 1, #itemList, 1 do
        if i % 200 == 0 then
            os.sleep()
        end
        if itemList[i].size >= 100 then
            filteredList[itemList[i].label] = itemList[i].size
        end
        itemList[i] = nil
    end
    return filteredList
end
local rollingTextObjects = {}
local function rollingText(glasses, text, start, stop, y, color)
    local textObject = ARG.hudText(glasses, "", start, y, color)
    textObject.setAlpha(0.8)
    local backgroundEndWedge =
        ARG.hudTriangle(glasses, {stop, y - 2}, {stop, y + 10}, {stop + 12, y + 10}, Colors.hudColor)
    local backgroundStartWedge =
        ARG.hudTriangle(glasses, {start - 12, y - 2}, {start, y + 10}, {start + 12, y - 2}, Colors.hudColor)
    local startWedge =
        ARG.hudQuad(glasses, {start, y - 2}, {start, y + 8}, {start + 30, y + 8}, {start + 30, y - 2}, Colors.hudColor)
    rollingTextObjects[#rollingTextObjects + 1] = {
        t = textObject,
        bew = backgroundEndWedge,
        bsw = backgroundStartWedge,
        sw = startWedge
    }
    local stepSize = 1
    local steps = start - stop / stepSize
    local step = 0
    local textLength = #text * 5
    local textRemaining = #text
    local textToRemove = #text
    local function truncate()
        textObject.setText(string.sub(text, #text - textToRemove, #text))
        textToRemove = textToRemove - 1
        if textToRemove == 0 then
            glasses.removeObject(backgroundEndWedge.getID())
            glasses.removeObject(backgroundStartWedge.getID())
            glasses.removeObject(startWedge.getID())
            glasses.removeObject(textObject.getID())
        end
    end
    local function roll()
        textObject.setPosition(start - (step * stepSize), y)
        step = step + 1
        if step > steps then
            Event.timer(0.07, truncate, #text + 3)
        end
    end
    local function generate()
        textObject.setText(string.sub(text, 0, #text - textRemaining))
        textRemaining = textRemaining - 1
    end
    Event.timer(0.10, generate, #text + 1)
    Event.timer(0.02, roll, steps + 1)
end
local function clearTicker(glasses)
    for i = 1, #rollingTextObjects do
        if rollingTextObjects[i].t ~= nil then
            glasses.removeObject(rollingTextObjects[i].t.getID())
        end
        if rollingTextObjects[i].bew ~= nil then
            glasses.removeObject(rollingTextObjects[i].bew.getID())
        end
        if rollingTextObjects[i].bsw ~= nil then
            glasses.removeObject(rollingTextObjects[i].bsw.getID())
        end
        if rollingTextObjects[i].sw ~= nil then
            glasses.removeObject(rollingTextObjects[i].sw.getID())
        end
    end
    rollingTextObjects = {}
end
local cachedAmounts = refreshDatabase(Component.me_interface.getItemsInNetwork())
local function difference(new)
    local differenceArray = {}
    for label, amount in pairs(cachedAmounts) do
        if new[label] ~= nil then
            if new[label] - amount > 64 or new[label] - amount < -64 then
                differenceArray[#differenceArray + 1] = {label, new[label] - amount}
            end
        end
    end
    cachedAmounts = new
    return differenceArray
end
local initializeTicker = true
local allItems, itemsInNetwork, craftables
local lastUpdate = Computer.uptime() - 60
function ARWidgets.itemTicker(glasses, x, y, w)
    local uniqueItems, totalItems, patterns
    local function formatMillions(number)
        local millions = number / 1000000
        if millions >= 10 then
            return string.sub(millions, 1, 5) .. "M"
        else
            return string.sub(millions, 1, 4) .. "M"
        end
    end
    local function getTotalItemCount(items)
        local sum = 0
        for i = 1, #items, 1 do
            if i % 200 == 0 then
                os.sleep()
            end
            sum = sum + items[i].size
        end
        return sum
    end
    if initializeTicker then
        local background =
            ARG.hudQuad(
            glasses,
            {x, y + 2},
            {x, y + 14},
            {x + w, y + 14},
            {x + w, y + 2},
            Colors.machineBackground,
            0.5
        )
        local top = ARG.hudQuad(glasses, {x, y}, {x, y + 2}, {x + w, y + 2}, {x + w, y}, Colors.hudColor)
        local bottom = ARG.hudQuad(glasses, {x, y + 14}, {x, y + 20}, {x + w, y + 20}, {x + w, y + 14}, Colors.hudColor)
        local bottomStripe =
            ARG.hudQuad(glasses, {x, y + 17}, {x, y + 18}, {x + w, y + 18}, {x + w, y + 17}, Colors.workingColor)
        local wedge = ARG.hudTriangle(glasses, {x - 20, y}, {x, y + 20}, {x, y}, Colors.hudColor)
        local backgroundEndWedge = ARG.hudTriangle(glasses, {x, y + 2}, {x, y + 14}, {x + 12, y + 14}, Colors.hudColor)
        local backgroundStartWedge =
            ARG.hudTriangle(glasses, {x + w - 12, y + 2}, {x + w, y + 14}, {x + w + 12, y + 2}, Colors.hudColor)
        local diagonalStripe =
            ARG.hudQuad(glasses, {x - 16, y + 2}, {x, y + 18}, {x, y + 17}, {x - 15, y + 2}, Colors.workingColor)
        local bottomBorder = ARG.hudRectangle(glasses, x + w - 170, y + 28, 170, 4, Colors.hudColor)
        local dataBorder = ARG.hudRectangle(glasses, x + w - 170, 20, 170, 12, Colors.hudColor, 0.5)
        local endWedge =
            ARG.hudTriangle(
            glasses,
            {x + w - 182, y + 20},
            {x + w - 170, y + 32},
            {x + w - 170, y + 20},
            Colors.hudColor
        )
        local divisor1 = ARG.hudRectangle(glasses, x + w - 118, y + 20, 2, 12, Colors.hudColor)
        local divisor2 = ARG.hudRectangle(glasses, x + w - 64, y + 20, 2, 12, Colors.hudColor)
        local bottomDataStripe = ARG.hudRectangle(glasses, x + w - 168, y + 30, 168, 1, Colors.workingColor)
        uniqueItems = ARG.hudText(glasses, "", x, y, Colors.workingColor, 0.75)
        totalItems = ARG.hudText(glasses, "", x, y, Colors.workingColor, 0.75)
        patterns = ARG.hudText(glasses, "", x, y, Colors.workingColor, 0.75)
        uniqueItems.setPosition((x + w - 114) * 1.33333, (y + 22) * 1.33333)
        totalItems.setPosition((x + w - 168) * 1.33333, (y + 22) * 1.33333)
        patterns.setPosition((x + w - 60) * 1.33333, (y + 22) * 1.33333)
        initializeTicker = false
    end
    local function showTicker(name, amount)
        rollingText(glasses, name, x + w, x, y + 4, 0xAAAAAA)
        local function showChange()
            if amount > 0 then
                rollingText(glasses, "+" .. amount, x + w, x, y + 4, Colors.positiveEUColor)
            else
                rollingText(glasses, "" .. amount, x + w, x, y + 4, Colors.negativeEUColor)
            end
        end
        Event.timer(#name * 0.12, showChange, 1)
    end
    local changedItems = {}
    local i = 1
    local function processQueue()
        showTicker(changedItems[i][1], changedItems[i][2])
        i = i + 1
    end
    if Computer.uptime() - lastUpdate > 60 then
        lastUpdate = Computer.uptime()
        allItems = Component.me_interface.getItemsInNetwork()
        itemsInNetwork = #allItems
        craftables = #Component.me_interface.getCraftables()
        totalItems.setText("Total: " .. formatMillions(getTotalItemCount(allItems)))
        patterns.setText("Patterns: " .. craftables)
        uniqueItems.setText("Unique: " .. itemsInNetwork)
        changedItems = difference(refreshDatabase(allItems))
        i = 1
        clearTicker(glasses)
        Event.timer(5, processQueue, #changedItems)
    end
end
function ARWidgets.crossHair(glasses, x, y)
    local horizontal = ARG.hudRectangle(glasses, x, y + 5, 4, 1, Colors.workingColor, 0.5)
    local vertical = ARG.hudRectangle(glasses, x + 5, y, 1, 4, Colors.workingColor, 0.5)
    local horizontal2 = ARG.hudRectangle(glasses, x + 7, y + 5, 4, 1, Colors.workingColor, 0.5)
    local vertical2 = ARG.hudRectangle(glasses, x + 5, y + 7, 1, 4, Colors.workingColor, 0.5)
    local middle = ARG.hudRectangle(glasses, x + 4, y + 4, 3, 3, Colors.hudColor, 0.0)
    local center = ARG.hudRectangle(glasses, x + 5, y + 5, 1, 1, Colors.hudColor, 0.7)
end
local initializeCpuMonitor = true
local cpuLights = {}
function ARWidgets.cpuMonitor(glasses, x, y)
    if initializeCpuMonitor then
        local cpuBase2 = ARG.hudRectangle(glasses, x + 94, y + 12, 8, 12, Colors.hudColor)
        local cpuSplitter = ARG.hudRectangle(glasses, x + 89, y + 9, 400, 3, Colors.hudColor)
        local cpuSplitter2 = ARG.hudRectangle(glasses, x + 102, y + 18, 380, 6, Colors.hudColor)
        local function createCpuIndicator(cpuX, cpuY)
            local status =
                ARG.hudQuad(
                glasses,
                {cpuX, cpuY},
                {cpuX + 6, cpuY + 6},
                {cpuX + 16, cpuY + 6},
                {cpuX + 10, cpuY},
                Colors.hudColor,
                1.0
            )
            local leftTriangle =
                ARG.hudTriangle(glasses, {cpuX, cpuY}, {cpuX, cpuY + 6}, {cpuX + 6, cpuY + 6}, Colors.hudColor)
            local rightTriangle =
                ARG.hudQuad(
                glasses,
                {cpuX + 10, cpuY},
                {cpuX + 16, cpuY + 6},
                {cpuX + 18, cpuY + 6},
                {cpuX + 18, cpuY},
                Colors.hudColor
            )
            return status
        end
        local i = 0
        local j = 0
        local cpuNumber = 1
        while i + j < 24 do
            if (i + j) % 2 == 1 then
                cpuLights[cpuNumber] = createCpuIndicator(x + 102 + j * 17, y + 12)
                j = j + 1
            else
                cpuLights[cpuNumber] = createCpuIndicator(x + 94 + i * 17, y + 3)
                i = i + 1
            end
            cpuNumber = cpuNumber + 1
        end
        local rowStop1 = ARG.hudRectangle(glasses, x + 94 + i * 17, y + 3, 300, 6, Colors.hudColor)
        local rowStop2 = ARG.hudRectangle(glasses, x + 102 + j * 17, y + 12, 300, 6, Colors.hudColor)
        local horizontalStrip = ARG.hudRectangle(glasses, x + 100, y + 22, 210, 1, Colors.workingColor)
        local diagonalStrip =
            ARG.hudQuad(
            glasses,
            {x + 89, y + 11},
            {x + 89, y + 12},
            {x + 100, y + 23},
            {x + 100, y + 22},
            Colors.workingColor
        )
        initializeCpuMonitor = false
    end
    local cpus = Component.me_interface.getCpus()
    for i = 1, #cpus, 1 do
        if cpus[i].busy then
            cpuLights[i].setColor(Colors.positiveEUColor)
        else
            cpuLights[i].setAlpha(0.7)
            cpuLights[i].setColor(Colors.workingColor)
        end
    end
end
local TPSText
local initializeTPS = true
function ARWidgets.displayTPS(glasses, x, y)
    if initializeTPS then
        initializeTPS = false
        local background =
            ARG.hudQuad(
            glasses,
            {x + 40, y + 4},
            {x + 40, y + 15},
            {x + 93, y + 15},
            {x + 105, y + 4},
            Colors.hudColor,
            0.6
        )
        local startBlock = ARG.hudRectangle(glasses, x, y, 40, 23, Colors.hudColor)
        local top = ARG.hudRectangle(glasses, x + 40, y, 65, 4, Colors.hudColor)
        local bottom = ARG.hudRectangle(glasses, x + 40, y + 14, 50, 5, Colors.hudColor)
        local wedge1 =
            ARG.hudQuad(
            glasses,
            {x + 40, y + 19},
            {x + 40, y + 23},
            {x + 42, y + 23},
            {x + 46, y + 19},
            Colors.hudColor
        )
        local wedge2 =
            ARG.hudQuad(glasses, {x + 105, y}, {x + 86, y + 19}, {x + 93, y + 19}, {x + 112, y}, Colors.hudColor)
        local stripe1 = ARG.hudRectangle(glasses, x + 2, y + 20, 39, 1, Colors.workingColor)
        local stripe2 = ARG.hudRectangle(glasses, x + 45, y + 16, 48, 1, Colors.workingColor)
        local stripe3 =
            ARG.hudQuad(
            glasses,
            {x + 41, y + 20},
            {x + 41, y + 21},
            {x + 45, y + 17},
            {x + 45, y + 16},
            Colors.workingColor
        )
        local stripe4 = ARG.hudRectangle(glasses, x + 1, y + 2, 1, 19, Colors.workingColor)
        TPSText = ARG.hudText(glasses, "", x + 42, y + 6, Colors.workingColor, 1)
    end
    local tps = math.min(20.00, Get.tps())
    if tps > 15 then
        TPSText.setText("TPS: " .. string.sub(tps, 1, 5))
        TPSText.setColor(Colors.positiveEUColor)
    elseif tps >= 10 then
        TPSText.setText("TPS: " .. string.sub(tps, 1, 5))
        TPSText.setColor(Colors.workingColor)
    else
        TPSText.setText("TPS: " .. string.sub(tps, 1, 4))
        TPSText.setColor(Colors.negativeEUColor)
    end
end
function ARWidgets.clear()
    initializePowerDisplay = true
    initializeTicker = true
    initFluidMap = true
    initializeCpuMonitor = true
    initializeTPS = true
    fillLevels = {}
    lastRefresh = Computer.uptime() - 30
    lastUpdate = Computer.uptime() - 60
end

return ARWidgets
