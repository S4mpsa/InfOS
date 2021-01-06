Component = require("component")
Event = require("event")
local modem = Component.modem
local util = require("utility")
AR = require("AR")
Glasses = util.machine("3770e3f9")

local componentText = AR.hudText(Glasses, " ", 0, 20)

local function receive(localAddress, remoteAddress, port, distance, type, value1, value2, value3)
    componentText.setText(value2)
end

Event.listen("modem_message", receive)
modem.open(1)
