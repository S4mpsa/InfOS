-- Import section
DoubleBuffer = require("graphics.doubleBuffering")
Colors = require("graphics.colors")
Unicode = require("unicode")
Widget = require("api.gui.widget")
--

-- GPU resolution should be 160 x 50.
-- Screen should be 16 blocks by 10 blocks. (Could also be 8 x 5).
-- That way, each block should have a resolution of 10 x 10
-- Organizing the page:
---- Title on top of the page (title)
---- Side panel on the left With a width of 20 pixels (panel)
---- Two buttons for page navigation (b, f)
------- Each with a width of 10 pixels
---- 1 Power widget on the bottom, with a width of 40 pixels (power)
---- 9 Regular widgets on the right, in a 3 x 3 grid (w)
------ Each one with a width of 20 pixels
--[[
| p |   title   |
| a | w | w | w |
| n | w | w | w |
| e | w | w | w |
| l | power |b|f|
--]]
local page = {}

local pages = {
    overview = require("api.gui.page.overview"),
    notifications = require("api.gui.page.notifications"),
    stock = require("api.gui.page.stock"),
    help = require("api.gui.page.help"),
    widgets = require("api.gui.page.widgets"),
    glasses = require("api.gui.page.glasses")
}

local widgets = {}

Event.listen(
    "touch",
    function(_, _, x, y)
        local index =
            1 +
            (math.floor(
                2 *
                    ((x - Widget.baseWidth) / Widget.baseWidth +
                        3 * math.floor((y - Widget.baseHeight) / Widget.baseHeight))
            )) /
                2
        local widget = widgets[index] or widgets[index - 0.5]

        widget:onClick()
    end
)

local function drawTitle(title)
    local x = Widget.baseWidth
    local y = 0
    local scale = 3
    local width = Widget.baseWidth * scale
    local height = Widget.baseHeight
    DoubleBuffer.drawRectangle(
        x + 1,
        y + 1,
        width - 1,
        height - 1,
        Colors.machineBackground,
        Colors.machineBackground,
        "█"
    )
    DoubleBuffer.drawFrame(x + 1, y + 1, width - 1, height - 1, Colors.labelColor)
    DoubleBuffer.drawLine(x + 3, y + 6, x + width - 3, y + 6, Colors.machineBackground, Colors.textColor, "─")
    DoubleBuffer.drawText(x + (width - Unicode.len(title)) / 2, y + 5, Colors.mainColor, title)
end

function page.create(page)
    drawTitle(page.title)
end

function page.fake()
    for i = 1, 9 do
        table.insert(widgets, Widget.machineWidget.fake())
    end
    table.insert(widgets, Widget.powerWidget.fake())
    widgets[11] = widgets[10]

    page.create(pages.overview)
end

function page.update()
    for index, widget in ipairs(widgets) do
        widget:update()
        widget:draw(index)
    end
    DoubleBuffer.drawChanges()
end

return page
