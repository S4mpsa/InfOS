-- Import section
Computer = require("computer")
Unicode = require("unicode")
Event = require("event")
DoubleBuffer = require("graphics.doubleBuffering")
Constants = require("api.gui.constants")
Colors = require("graphics.colors")
Widget = require("api.gui.widget")
--

-- GPU resolution should be 160 x 50.
-- Screen should be 8 x 5 blocks.
-- That way, each block should have a resolution of 20 x 10
-- Organizing the page:
---- Title on top of the page (title)
---- Side panel on the left With a width of 40 pixels (panel)
---- 2 buttons for page navigation (b, f)
------- Each with a width of 20 pixels
---- 1 Power widget on the bottom, with a width of 80 pixels (power)
---- 9 Regular widgets on the right, in a 3 x 3 grid (w)
------ Each one with a width of 40 pixels
--[[
| p |   title   |
| a | w | w | w |
| n | w | w | w |
| e | w | w | w |
| l | power |b|f|
--]]
local pages = {
    glasses = require("api.gui.page.glasses"),
    widgets = require("api.gui.page.widgets"),
    help = require("api.gui.page.help"),
    stock = require("api.gui.page.stock"),
    notifications = require("api.gui.page.notifications"),
    overview = require("api.gui.page.overview")
}
pages[1] = pages.glasses
pages[2] = pages.widgets
pages[3] = pages.help
pages[4] = pages.stock
pages[5] = pages.notifications
pages[6] = pages.overview

local page = {}

local elements = {
    machineWidgets = {},
    powerWidgets = {},
    panelSections = {},
    navigationButtons = {}
}

Event.listen(
    "touch",
    function(_, _, x, y)
        local xContribution = x / Constants.baseWidth
        local yContribution = 4 * math.floor(y / Constants.baseHeight)
        local screenIndex = 1 + (math.floor(2 * (xContribution + yContribution))) / 2

        local selected = elements[screenIndex] or elements[screenIndex - 0.5]
        selected:onClick()
    end
)

local function drawTitle(title)
    local x = Constants.baseWidth
    local y = 1
    local width = 3 * Constants.baseWidth
    local height = math.floor(0.8 * Constants.baseHeight)
    Widget.drawBaseWidget(x, y, width, height, title)
end

local function drawPanelSection(index, title)
    local width = math.floor(0.6 * Constants.baseWidth)
    local height = math.floor(0.6 * Constants.baseHeight)
    local x = math.floor((Constants.baseWidth - width) / 2)
    local y = (index - 1) * Constants.baseHeight + math.floor((Constants.baseHeight - height) / 2)
    Widget.drawBaseWidget(x, y, width, height, title)
end

local function drawNavigationButton(self, index)
    local width = math.floor(0.3 * Constants.baseWidth)
    local height = math.floor(0.6 * Constants.baseHeight)
    local x = math.floor((2.4 + 0.4 * index) * Constants.baseWidth) + math.floor((Constants.baseWidth - width) / 2)
    local y = 4 * Constants.baseHeight + math.floor((Constants.baseHeight - height) / 2)
    if self.active then
        Widget.drawBaseWidget(x, y, width, height, self.title)
    end
end

local function clickNavigationButton(self)
    if not self.active then
        return
    end
    if self.title == "◀" then
        elements.machineWidgets.active.index = elements.machineWidgets.active.index - 1
    else
        elements.machineWidgets.active.index = elements.machineWidgets.active.index + 1
    end
    for i = 1, 9 do
        elements.machineWidgets.active[i] = elements.machineWidgets[9 * (elements.machineWidgets.active.index - 1) + i]
    end

    elements[6] = elements.machineWidgets.active[1]
    elements[7] = elements.machineWidgets.active[2]
    elements[8] = elements.machineWidgets.active[3]
    elements[10] = elements.machineWidgets.active[4]
    elements[11] = elements.machineWidgets.active[5]
    elements[12] = elements.machineWidgets.active[6]
    elements[14] = elements.machineWidgets.active[7]
    elements[15] = elements.machineWidgets.active[8]
    elements[16] = elements.machineWidgets.active[9]
    Widget.clear()
end

function page.create(element)
    drawTitle(element.title)

    local panelIndex = 1
    for _, pg in ipairs(pages) do
        if pg ~= element then
            elements.panelSections[panelIndex] = {
                title = pg.title,
                onClick = function()
                    page.create(pg)
                end
            }
            drawPanelSection(panelIndex, pg.title)
            panelIndex = panelIndex + 1
        end
    end

    elements.machineWidgets.active = {}
    elements.machineWidgets.active.index = 1
    for i = 1, 9 do
        elements.machineWidgets.active[i] = elements.machineWidgets[9 * (elements.machineWidgets.active.index - 1) + i]
    end
    elements.navigationButtons[1] = {
        title = "◀",
        active = true,
        update = function(self)
            self.active = elements.machineWidgets[elements.machineWidgets.active.index * 9 - 10] ~= nil
        end,
        onClick = clickNavigationButton,
        draw = drawNavigationButton
    }
    elements.navigationButtons[2] = {
        title = "▶",
        active = true,
        update = function(self)
            self.active = elements.machineWidgets[elements.machineWidgets.active.index * 9 + 1] ~= nil
        end,
        onClick = clickNavigationButton,
        draw = drawNavigationButton
    }

    elements[4.5] = {
        onClick = function()
            Computer.shutdown(true)
        end
    }

    elements[6] = elements.machineWidgets.active[1]
    elements[7] = elements.machineWidgets.active[2]
    elements[8] = elements.machineWidgets.active[3]
    elements[10] = elements.machineWidgets.active[4]
    elements[11] = elements.machineWidgets.active[5]
    elements[12] = elements.machineWidgets.active[6]
    elements[14] = elements.machineWidgets.active[7]
    elements[15] = elements.machineWidgets.active[8]
    elements[16] = elements.machineWidgets.active[9]

    elements[18] = elements.powerWidgets[1]
    elements[19] = elements.powerWidgets[1]

    elements[1] = elements.panelSections[1]
    elements[5] = elements.panelSections[2]
    elements[9] = elements.panelSections[3]
    elements[13] = elements.panelSections[4]
    elements[17] = elements.panelSections[5]

    elements[20] = elements.navigationButtons[1]
    elements[20.5] = elements.navigationButtons[2]
end

function page.fake()
    elements.machineWidgets = Widget.fakeWidgets()
    elements.powerWidgets = Widget.fakePowerWidget()
    page.create(pages.overview)
end

function page.update()
    for _, machineWidget in ipairs(elements.machineWidgets) do
        machineWidget:update()
    end
    for index, activeMachineWidget in ipairs(elements.machineWidgets.active) do
        activeMachineWidget.draw(activeMachineWidget, index)
    end
    for index, powerWidget in ipairs(elements.powerWidgets) do
        powerWidget:update()
        powerWidget:draw(index)
    end
    for index, navigationButton in ipairs(elements.navigationButtons) do
        navigationButton:update()
        navigationButton:draw(index)
    end

    DoubleBuffer.drawChanges()
end

return page
