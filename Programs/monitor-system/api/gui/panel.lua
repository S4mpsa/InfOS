-- Import section
Page = require("api.gui.page")
Graphics = require("graphics.graphics")
Colors = require("colors")
Component = require("component")
GPU = Component.gpu
--

local panel = {
    currentPage = Page.overview
}

function panel.render()
    Graphics.rectangle(GPU, 0, 0, 20, 160, Colors.background)
    for index, page in ipairs(Page) do
        if page ~= panel.currentPage then
            Graphics.text(GPU, 0, 10 * (index - 1), Colors.labelColor, panel.title)
        end
    end
end

function panel.navigate(page)
    panel.findText(page.title)
    page.render()
end

return panel
