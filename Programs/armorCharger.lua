comp = require("component"); event = require("event")

local transposer = comp.transposer
local dark = 2
local charger = 3
function swap()
    transposer.transferItem(dark, charger, 1, 39, 5)
    transposer.transferItem(charger, dark, 1, 1, 39)
    transposer.transferItem(charger, charger, 1, 5, 1)
end