Component = require("component")
Unicode = require("unicode")
Colors = require("graphics.colors")
DoubleBuffer = require("graphics.doubleBuffering")

local widget = {
    baseHeight = 10,
    baseWidth = 40
}

-- function widget.create(name, leftString, middleString, rightString, screenIndex)
--     widget.name = name or "Unused"
--     widget.leftString = leftString or ""
--     widget.middleString = middleString or ""
--     widget.rightString = rightString or ""
-- end

local states = {
    {name = "ON", color = Colors.workingColor},
    {name = "IDLE", color = Colors.idleColor},
    {name = "OFF", color = Colors.offColor},
    {name = "BROKEN", color = Colors.errorColor}
}

local function drawProgress(x, y, width, height, progress, maxProgress, color)
    progress = math.floor(progress * (width + height - 2) / (maxProgress ~= 0 and maxProgress or 1))

    local lengths = {
        first = progress > 5 and 5 or progress,
        second = progress > height - 2 + 5 and height - 2 or progress - (5),
        third = progress > width - 7 + height - 2 + 5 and width - 7 or progress - (height - 2 + 5)
    }
    DoubleBuffer.drawSemiPixelRectangle(x + 6 - lengths.first, y + 1, lengths.first, 1, color)
    DoubleBuffer.drawSemiPixelRectangle(x + 1, y + 2, 1, lengths.second, color)
    DoubleBuffer.drawSemiPixelRectangle(x + 1, y + height, lengths.third, 1, color)
    DoubleBuffer.drawSemiPixelRectangle(x + width - 4, y + height, lengths.first, 1, color)
    DoubleBuffer.drawSemiPixelRectangle(x + width, y + height - lengths.second, 1, lengths.second, color)
    DoubleBuffer.drawSemiPixelRectangle(x + 1 + width - lengths.third, y + 1, lengths.third, 1, color)
end

local function draw(self, index)
    if index > 10 then
        return
    end
    local scale = self.scale or 1
    local x = widget.baseWidth + widget.baseWidth * ((index - 1) % 3)
    local width = widget.baseWidth * scale
    local height = widget.baseHeight
    local y = height * math.ceil((index) / 3)

    DoubleBuffer.drawRectangle(
        x + 1,
        y + 1,
        width - 1,
        height - 1,
        Colors.machineBackground,
        Colors.machineBackground,
        "█"
    )
    drawProgress(x, 2 * y, width - 1, 2 * (height - 1), 1, 1, Colors.progressBackground)
    DoubleBuffer.drawLine(x + 3, y + 5, x + width - 3, y + 5, Colors.machineBackground, Colors.textColor, "─")
    DoubleBuffer.drawText(x + 3, y + 3, Colors.labelColor, self.name)

    drawProgress(x, 2 * y, width - 1, 2 * (height - 1), self.progress, self.maxProgress, Colors.barColor)
    DoubleBuffer.drawText(x + 3, y + 7, self.state.color, self.state.name)
    if self.state == states[4] then
        drawProgress(x, 2 * y, width - 1, 2 * (height - 1), 1, 1, Colors.errorColor)
    else
        local middleInfo = self:getMiddleString()
        if middleInfo then
            DoubleBuffer.drawText(x + 3 + 3 + Unicode.len("IDLE"), y + height - 3, Colors.textColor, middleInfo)
        end
        DoubleBuffer.drawText(
            x + width - Unicode.len(self.progress .. "/" .. self.maxProgress .. " s") - 3,
            y + height - 3,
            Colors.accentA,
            self.progress .. "/" .. self.maxProgress .. " s"
        )
    end
end

local fakeNames = {
    "Cleanroom",
    "Electric Blast Furnace",
    "Miner",
    "Vacuum Freezer",
    "Multi Smelter",
    "Sifter",
    "Large Chemical Reactor",
    "Distillery",
    "Oil Cracking Unit",
    "Implosion Compressor"
}

widget.machineWidget = {}

function widget.machineWidget:update()
    local breakWidget = math.random(10000) > 9999
    if breakWidget and self.state ~= states[3] then
        self.state = states[4]
    end
    if self.state == states[1] then
        self.progress = self.progress + 1
        if self.progress >= self.maxProgress then
            self.progress = 0
            self.maxProgress = 0
            self.state = states[2]
        end
    elseif self.state == states[2] then
        if math.random(1000) > 999 then
            self.state = states[1]
            self.maxProgress = math.random(500)
        end
    elseif self.state == states[3] then
        self.progress = self.progress + 1
        if self.progress >= self.maxProgress then
            self.progress = 0
            self.maxProgress = 0
        end
    end
end

function widget.machineWidget:onClick()
    if self.state == states[1] or self.state == states[2] then
        self.state = states[3]
    elseif self.state == states[3] then
        if self.progress < self.maxProgress then
            self.state = states[1]
        else
            self.progress = 0
            self.maxProgress = 0
            self.state = states[2]
        end
    elseif self.state == states[4] then
        self.progress = 0
        self.maxProgress = 0
        self.state = states[2]
    end
end

function widget.machineWidget:getMiddleString()
end

function widget.machineWidget.fake()
    local state = states[math.random(4)]
    return {
        name = fakeNames[math.random(10)] .. " " .. math.floor(math.random(3)),
        state = state,
        progress = 0,
        maxProgress = state ~= states[3] and state ~= states[4] and math.random(500) or 0,
        type = "machine",
        update = widget.machineWidget.update,
        onClick = widget.machineWidget.onClick,
        getMiddleString = widget.machineWidget.getMiddleString,
        draw = draw
    }
end

widget.powerWidget = {}

function widget.powerWidget:update()
    self.progress = self.progress + self.dProgress
end

function widget.powerWidget:onClick()
    self.dProgress = -self.dProgress
end

function widget.powerWidget:getMiddleString()
    local remaining = self.dProgress > 0 and self.maxProgress - self.progress or -self.progress
    return (self.dProgress > 0 and "+" or "") ..
        self.dProgress .. "EU/s. " .. (self.dProgress > 0 and "Full in: " or "Empty in: ") .. remaining / self.dProgress
end

function widget.powerWidget.fake()
    return {
        name = "Power",
        state = states[1],
        progress = math.random(16000000),
        maxProgress = 16000000,
        scale = 2,
        type = "power",
        dProgress = 1,
        update = widget.powerWidget.update,
        onClick = widget.powerWidget.onClick,
        getMiddleString = widget.powerWidget.getMiddleString,
        draw = draw
    }
end

return widget
