Component = require("component")
Term = require("term")

GPU = Component.gpu
GPU.setResolution(54, 26)
local function enableReactors()
    Component.redstone.setOutput(1, 15)
end
local function disableReactors()
    Component.redstone.setOutput(1, 0)
end

local function checkHeatLevels()
    Term.setCursor(1, 1)
    local i = 1
    for address, type in pairs(Component.list()) do
        if type == "reactor_chamber" then
            Term.write("Reactor " .. i)
            if i < 10 then
                Term.write(" ")
            end
            local reactor = Component.proxy(address)
            if reactor.getHeat() > 0 then
                GPU.setForeground(0xFF0000)
                Term.write(" REACTOR HEATING! SHUTTING DOWN")
                disableReactors()
                GPU.setForeground(0xFFFFFF)
                os.sleep(1)
                os.exit()
            else
                if reactor.getReactorEUOutput() > 0 then
                    Term.write(" status: ")
                    GPU.setForeground(0x00FF00)
                    Term.write("NOMINAL")
                    GPU.setForeground(0xFFFFFF)
                    Term.write(" - Producing ")
                    GPU.setForeground(0xFF00FF)
                    Term.write(math.floor(reactor.getReactorEUOutput()))
                    GPU.setForeground(0xFFFFFF)
                    Term.write(" EU/t\n")
                else
                    Term.write(" status: ")
                    GPU.setForeground(0xFFFF00)
                    Term.write("INACTIVE\n")
                end
            end
            i = i + 1
        end
    end
end

enableReactors()
Term.clear()
while true do
    checkHeatLevels()
    os.sleep(1)
end
