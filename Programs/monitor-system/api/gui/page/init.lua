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
    local y = 0
    local scale = 3
    Widget.drawBaseWidget(x, y, scale, title)
end

local function drawPanelSection(index, title)
    local x = 0
    local y = (index - 1) * Constants.baseHeight
    local scale = 1
    Widget.drawBaseWidget(x, y, scale, title)
end

function page.create(element)
    drawTitle(element.title)

    local panelIndex = 1
    for _, pg in ipairs(pages) do
        if pg ~= element then
            elements.panelSections[panelIndex] = pg.title
            drawPanelSection(panelIndex, pg.title)
            panelIndex = panelIndex + 1
        end
    end

    elements[4.5] = {onClick = function()
            Computer.shutdown(true)
        end}

    elements[6] = elements.machineWidgets[1]
    elements[7] = elements.machineWidgets[2]
    elements[8] = elements.machineWidgets[3]
    elements[10] = elements.machineWidgets[4]
    elements[11] = elements.machineWidgets[5]
    elements[12] = elements.machineWidgets[6]
    elements[14] = elements.machineWidgets[7]
    elements[15] = elements.machineWidgets[8]
    elements[16] = elements.machineWidgets[9]

    elements[18] = elements.powerWidgets[1]
    elements[19] = elements.powerWidgets[1]

    elements[1] = elements.panelSections[1]
    elements[5] = elements.panelSections[2]
    elements[9] = elements.panelSections[3]
    elements[13] = elements.panelSections[3]
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
    for index, machineWidget in ipairs(elements.machineWidgets) do
        machineWidget:update()
        machineWidget:draw(index)
    end
    for index, powerWidget in ipairs(elements.powerWidgets) do
        powerWidget:update()
        powerWidget:draw(index)
    end
    DoubleBuffer.drawChanges()
end

return page
