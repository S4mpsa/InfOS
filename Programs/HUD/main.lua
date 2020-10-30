comp = require("component"); event = require("event")
AR = require("ARWidgets")
ARG = require("ARGraphics")
local wSampsa, hSampsa = 853, 473
local powerHudX, powerHudY, powerHudW, powerHudH = 0, hSampsa-24, wSampsa*0.39+3, 14
local glasses = comp.glasses
glasses.removeAll()
AR.minimapOverlay(glasses); AR.hudOverlayBase(glasses, 335, 449); AR.clear();
AR.crossHair(glasses, 422, 231)
screen.clear()
while true do
    AR.powerDisplay(glasses, comp.gt_machine, powerHudX, powerHudY, powerHudW, powerHudH)
    AR.fluidMonitor(glasses, 795, 153, {
        [0] = {label = "Oxygen Gas", displayName = "Oxygen", color = 0x688690, max = 128},
        [1] = {label = "Nitrogen Gas", displayName = "Nitrogen", color = 0x976868, max = 128},
        [2] = {label = "Hydrogen Gas", displayName = "Hydrogen", color = 0xa78282, max = 128},
        [3] = {label = "fluid.chlorine", displayName = "Chlorine", color = 0x428282, max = 128},
        [4] = {label = "fluid.radon", displayName = "Radon", color = 0xff5bff, max = 2},
        [5] = {label = "UU-Matter", displayName = "UU Matter", color = 0x4a0946, max = 2},
        [6] = {label = "fluid.molten.plastic", displayName = "Rubber", color = 0x050505, max = 2},
        [7] = {label = "fluid.molten.polytetrafluoroethylene", displayName = "PTFE", color = 0x4d4d4d, max = 2},
        [8] = {label = "fluid.molten.styrenebutadienerubber", displayName = "SBR", color = 0x1d1817, max = 2},
        [9] = {label = "fluid.molten.epoxid", displayName = "Epoxid", color = 0x9d6f13, max = 2},
        [10] = {label = "fluid.molten.silicone", displayName = "Silicone Rubber", color = 0xa5a5a5, max = 2},
        [11] = {label = "fluid.molten.polybenzimidazole", displayName = "PBI", color = 0x262626, max = 2}
        }
    )
    os.sleep()
end

--Widget ideas:
--  Charge level indicator for everything
--  Inventory fill level monitoring
--  Maintenance Monitoring
