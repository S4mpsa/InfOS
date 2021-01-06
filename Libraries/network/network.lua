component = require("component")
event = require("event")
local modem = component.modem
local util = require("utility")
AR = require("AR")
glasses = util.machine("3770e3f9")

local componentText = AR.hudText(glasses, " ", 0, 20)

local function receive(localAddress, remoteAddress, port, distance, type, value1, value2, value3)
    componentText.setText(value2)
end

event.listen("modem_message", receive)
modem.open(1)
