Component = require("component")
Unicode = require("unicode")
DoubleBuffer = require("graphics.doubleBuffering")
Constants = require("api.gui.constants")
Colors = require("graphics.colors")
Utility = require("utils.utility")

local widget = {}

local states = {
    {name = "ON", color = Colors.workingColor},
    {name = "IDLE", color = Colors.idleColor},
    {name = "OFF", color = Colors.offColor},
    {name = "BROKEN", color = Colors.errorColor}
}

local types = {
    POWER = "POWER",
    MULTIBLOCK = "MULTIBLOCK",
    MACHINE = "MACHINE"
}

local function drawProgress(x, y, width, height, progress, maxProgress, color)
    progress = math.floor(progress * (width + height - 2) / (maxProgress ~= 0 and maxProgress or 1))

    local lengths = {
        first = progress > 5 and 5 or progress,
        second = progress > height - 2 + 5 and height - 2 or progress - (5),
        third = progress > width - 7 + height - 2 + 5 and width - 7 or progress - (height - 2 + 5)
    }
    DoubleBuffer.drawRectangle(x + 6, y / 2 + 1, 2, 1, Colors.machineBackground, Colors.machineBackground, "█")
    DoubleBuffer.drawSemiPixelRectangle(x + 6 - lengths.first, y + 1, lengths.first, 1, color)
    DoubleBuffer.drawSemiPixelRectangle(x + 1, y + 2, 1, lengths.second, color)
    DoubleBuffer.drawSemiPixelRectangle(x + 1, y + height, lengths.third, 1, color)
    DoubleBuffer.drawRectangle(
        x + width - 6,
        (y + height) / 2,
        2,
        1,
        Colors.machineBackground,
        Colors.machineBackground,
        "█"
    )
    DoubleBuffer.drawSemiPixelRectangle(x + width - 4, y + height, lengths.first, 1, color)
    DoubleBuffer.drawSemiPixelRectangle(x + width, y + height - lengths.second, 1, lengths.second, color)
    DoubleBuffer.drawSemiPixelRectangle(x + 1 + width - lengths.third, y + 1, lengths.third, 1, color)
end

function widget.drawBaseWidget(x, y, width, height, title)
    DoubleBuffer.drawRectangle(
        x + 1,
        y + 1,
        width - 1,
        height - 1,
        Colors.machineBackground,
        Colors.machineBackground,
        "█"
    )
    DoubleBuffer.drawLine(
        x + 3,
        y + math.ceil(0.5 * height),
        x + width - 3,
        y + math.ceil(0.5 * height),
        Colors.machineBackground,
        Colors.textColor,
        "─"
    )
    DoubleBuffer.drawFrame(x + 1, y + 1, width - 1, height - 1, Colors.labelColor)
    title = Unicode.len(title) < width - 8 and " " .. title .. " " or " " .. string.gsub(title, "%l*%s", "") .. " "
    DoubleBuffer.drawText(x + math.floor((width - Unicode.len(title) + 1) / 2), y + 3, Colors.labelColor, title)
end

local function draw(self, index)
    if self.type == types.POWER then
        index = 10
    end
    local scale = self.scale or 1
    local width = Constants.baseWidth * scale
    local height = Constants.baseHeight
    local x = Constants.baseWidth + Constants.baseWidth * ((index - 1) % 3)
    local y = height * math.ceil((index) / 3)

    widget.drawBaseWidget(x, y, width, height, self.name)

    drawProgress(x, 2 * y, width - 1, 2 * (height - 1), 1, 1, Colors.progressBackground)
    drawProgress(x, 2 * y, width - 1, 2 * (height - 1), self.progress, self.maxProgress, Colors.barColor)
    DoubleBuffer.drawText(x + 4, y + 7, self.state.color, self.state.name)
    if self.state == states[4] then
        drawProgress(x, 2 * y, width - 1, 2 * (height - 1), 1, 1, Colors.errorColor)
    else
        local middleInfo = self:getMiddleString()
        if middleInfo then
            DoubleBuffer.drawText(
                x - 3 - 3 + width - Unicode.len(middleInfo) -
                    Unicode.len(
                        Utility.splitNumber(math.floor(self.progress)) ..
                            " / " .. Utility.splitNumber(math.floor(self.maxProgress)) .. " s"
                    ),
                y + height - 3,
                Colors.textColor,
                middleInfo
            )
        end
        DoubleBuffer.drawText(
            x + width -
                Unicode.len(
                    Utility.splitNumber(math.floor(self.progress)) ..
                        " / " .. Utility.splitNumber(math.floor(self.maxProgress)) .. " s"
                ) -
                3,
            y + height - 3,
            Colors.accentA,
            Utility.splitNumber(math.floor(self.progress)) ..
                " / " .. Utility.splitNumber(math.floor(self.maxProgress)) .. " s"
        )
    end
end

function widget.clear()
    DoubleBuffer.drawRectangle(
        Constants.baseWidth,
        Constants.baseHeight,
        3 * Constants.baseWidth,
        4 * Constants.baseHeight,
        Colors.background,
        Colors.background,
        "█"
    )
end

local fake = {}

fake.names = {
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

fake.machineWidget = {}

function fake.machineWidget:update()
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

function fake.machineWidget:onClick()
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

function fake.machineWidget:getMiddleString()
end

function fake.machineWidget.create()
    local state = states[math.random(4)]
    return {
        name = fake.names[math.random(10)] .. " " .. math.floor(math.random(3)),
        state = state,
        progress = 0,
        maxProgress = state ~= states[3] and state ~= states[4] and math.random(500) or 0,
        type = types.MACHINE,
        update = fake.machineWidget.update,
        onClick = fake.machineWidget.onClick,
        getMiddleString = fake.machineWidget.getMiddleString,
        draw = draw
    }
end

function widget.createMachineWidget(address, name)
    local getMultiblockStatus = require("domain.multiblock.get-multiblock-status-usecase")
    local function update(self)
        for key, value in pairs(getMultiblockStatus(address, self.name)) do
            self[key] = value
        end
    end

    local toggleMultiblockWork = require("domain.multiblock.toggle-multiblock-work")
    local function onClick(self)
        toggleMultiblockWork(address, self.name)
    end

    local machineWidget = {
        name = name,
        type = types.MULTIBLOCK,
        update = update,
        onClick = onClick,
        getMiddleString = function()
        end,
        draw = draw
    }

    machineWidget:update()

    return machineWidget
end

fake.powerWidget = {}

function fake.powerWidget:update()
    self.progress = self.progress + self.dProgress
end

function fake.powerWidget:onClick()
    self.dProgress = -self.dProgress
end

function fake.powerWidget:getMiddleString()
    local remaining = self.dProgress > 0 and self.maxProgress - self.progress or -self.progress
    return (self.dProgress > 0 and "+" or "") ..
        self.dProgress ..
            "EU/s. " .. (self.dProgress > 0 and " Full in: " or "Empty in: ") .. remaining / self.dProgress
end

function fake.powerWidget.create()
    return {
        name = "Power",
        state = states[1],
        progress = math.random(16000000),
        maxProgress = 16000000,
        dProgress = 1,
        scale = 2,
        type = types.POWER,
        update = fake.powerWidget.update,
        onClick = fake.powerWidget.onClick,
        getMiddleString = fake.powerWidget.getMiddleString,
        draw = draw
    }
end

function widget.fakeWidgets()
    local fakeWidgets = {}

    for _ = 1, math.random(30) do
        table.insert(fakeWidgets, fake.machineWidget.create())
    end

    return fakeWidgets
end

function widget.fakePowerWidget()
    return fake.powerWidget.create()
end

function widget.createPowerWidget(address)
    local getPowerStatus = require("domain.energy.get-energy-status-usecase")
    local function update(self)
        for key, value in pairs(getPowerStatus(address, self.name)) do
            self[key] = value
        end
    end

    local function getMiddleString(self)
        local time = self.timeToFull or self.timeToEmpty or 0
        return (self.dProgress >= 0 and " Full in: " or "Empty in: ") .. Utility.splitNumber(time) .. " s"
    end

    local powerWidget = {
        name = "Power",
        scale = 2,
        type = types.POWER,
        update = update,
        onClick = function()
        end,
        getMiddleString = getMiddleString,
        draw = draw
    }
    powerWidget:update()

    return powerWidget
end

return widget
