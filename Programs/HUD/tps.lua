Component = require("component")
AR = require("ARWidgets")

while true do
    AR.displayTPS(Component.glasses, 0, 0)
    AR.cpuMonitor(Component.glasses, 520, 449)
end
