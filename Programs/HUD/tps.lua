component = require("component")
AR = require("ARWidgets")

while true do
    AR.displayTPS(component.glasses, 0, 0)
    AR.cpuMonitor(component.glasses, 520, 449)
end
