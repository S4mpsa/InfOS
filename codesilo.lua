comp = require("component"); event = require("event")
ARG = require("ARGraphics"); get = require("easy"); config = require("config")
comp.glasses.removeAll()
local initializeCpuMonitor = true
local cpuLights = {}
local function cpuMonitor(glasses, x, y)
    if initializeCpuMonitor then
        local base = ARG.hudRectangle(glasses, x, y, 28, 24, hudColour)
        local topStrip = ARG.hudRectangle(glasses, x, y, 500, 3, hudColour)
        local itemBorder1 = ARG.hudRectangle(glasses, x+28, y+3, 1, 21, workingColour, 0.8)
        local itemBorder2 = ARG.hudRectangle(glasses, x+28, y+3, 61, 1, workingColour, 0.8)
        local itemBorder3 = ARG.hudRectangle(glasses, x+88, y+3, 1, 21, workingColour, 0.8)
        local itemBorder4 = ARG.hudRectangle(glasses, x+28, y+23, 61, 1, workingColour, 0.8)
        local cpuBase1 = ARG.hudRectangle(glasses, x+89, y, 5, 24, hudColour)
        local cpuBase2 = ARG.hudRectangle(glasses, x+94, y+12, 8, 12, hudColour)
        local cpuSplitter = ARG.hudRectangle(glasses, x+89, y+9, 400, 3, hudColour)
        local cpuSplitter2 = ARG.hudRectangle(glasses, x+102, y+18, 380, 6, hudColour)
        local function createCpuIndicator(cpuX, cpuY)
            local status = ARG.hudQuad(glasses, {cpuX, cpuY}, {cpuX+6, cpuY+6}, {cpuX+16, cpuY+6}, {cpuX+10, cpuY}, hudColour, 1.0)
            local leftTriangle = ARG.hudTriangle(glasses, {cpuX, cpuY}, {cpuX, cpuY+6}, {cpuX+6, cpuY+6}, hudColour)
            local rightTriangle = ARG.hudQuad(glasses, {cpuX+10, cpuY}, {cpuX+16, cpuY+6}, {cpuX+18, cpuY+6}, {cpuX+18, cpuY}, hudColour)
            return status
        end
        local i = 0
        local j = 0
        local cpuNumber = 1
        while i+j < 24 do
            if (i+j) % 2 == 1 then
                cpuLights[cpuNumber] = createCpuIndicator(x+102+j*17, y+12)
                j = j + 1
            else
                cpuLights[cpuNumber] = createCpuIndicator(x+94+i*17, y+3)
                i = i + 1
            end
            cpuNumber = cpuNumber + 1
        end
        local rowStop1 = ARG.hudRectangle(glasses, x+94+i*17, y+3, 300, 6, hudColour)
        local rowStop2 = ARG.hudRectangle(glasses, x+102+j*17, y+12, 300, 6, hudColour)
        local horizontalStrip = ARG.hudRectangle(glasses, x+100, y+22, 210, 1, workingColour)
        local diagonalStrip = ARG.hudQuad(glasses, {x+89, y+11}, {x+89, y+12}, {x+100, y+23}, {x+100, y+22}, workingColour)
        initializeCpuMonitor = false
    end
    local cpus = comp.me_interface.getCpus()
    for i = 1, #cpus, 1 do
        if cpus[i].busy then
            cpuLights[i].setColor(ARG.hexToRGB(positiveEUColour))
        else
            cpuLights[i].setAlpha(0.7)
            cpuLights[i].setColor(ARG.hexToRGB(workingColour))
        end
    end
end
while true do
    cpuMonitor(comp.glasses, 520, 449)
end