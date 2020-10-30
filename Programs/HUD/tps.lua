comp = require("component"); event = require("event")
AR = require("ARWidgets")

while true do
    AR.displayTPS(comp.glasses, 0, 0)
    AR.cpuMonitor(comp.glasses, 520, 449)
end