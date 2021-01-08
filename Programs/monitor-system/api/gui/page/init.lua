-- Import section
local doubleBuffer = require("graphics.doubleBuffering")
Colors = require("graphics.colors")
Unicode = require("unicode")
--

local pages = {
    overview = require("Overview"),
    notifications = require("notifications"),
    stock = require("stock"),
    help = require("help"),
    widgets = require("widgets"),
    glasses = require("glasses")
}

function pages:draw(component, index)
    if index < 10 then
        local x = 40 + 40 * ((index - 1) % 3)
        local y = 10 * math.ceil((index) / 3)
        doubleBuffer.drawRectangle(x + 1, y + 1, 38, 8, Colors.machineBackground, Colors.machineBackground, "█")
        doubleBuffer.drawFrame(x + 1, y + 1, 38, 8, Colors.labelColor)
        doubleBuffer.drawLine(x + 4, y + 4, x + 16, y + 4, Colors.machineBackground, Colors.mainColor, "_")
        doubleBuffer.drawText(x + 1, y + 1, Colors.labelColor, component.name)
        doubleBuffer.drawText(
            x + 4,
            y + 4,
            component.working and Colors.workingColor or Colors.errorColor,
            component.leftInfo
        )
        if component.middleInfo then
            doubleBuffer.drawText(
                x + 20 - Unicode.len(component.middleInfo),
                y + 5,
                Colors.accentB,
                component.middleInfo
            )
        end
        if component.rightInfo then
            doubleBuffer.drawText(
                x + 20 - Unicode.len(component.rightInfo) - 4,
                y + 5,
                Colors.accentA,
                component.rightInfo
            )
        end
    elseif index == 10 then
    end
    return
end

function pages:render()
end

return pages
