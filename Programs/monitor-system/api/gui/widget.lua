Component = require("component")
GPU = Component.gpu
Screen = Component.screen

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


local page = {
    title = {},
    panel = {},
    back = {},
    forwards = {}
}

local widget = {
    name = "",
    leftString = "",
    middleString = "",
    rightString = "",
    height = 10,
    width = 20,
}

function widget.create(name, leftString, middleString, rightString, screenIndex)
    widget.name = name or "Unused"
    widget.leftString = leftString or ""
    widget.middleString = middleString or ""
    widget.rightString = rightString or ""
end
