component = require("component")
term = require("term")

local GPU = component.gpu
GPU.setResolution(54, 26)
local function enableReactors()
    component.redstone.setOutput(1, 15)
end
local function disableReactors()
    component.redstone.setOutput(1, 0)
end

local function checkHeatLevels()
    term.setCursor(1, 1)
    local i = 1
    for address, type in pairs(component.list()) do
        if type == "reactor_chamber" then
            term.write("Reactor " .. i)
            if i < 10 then
                term.write(" ")
            end
            local reactor = component.proxy(address)
            if reactor.getHeat() > 0 then
                GPU.setForeground(0xFF0000)
                term.write(" REACTOR HEATING! SHUTTING DOWN")
                disableReactors()
                GPU.setForeground(0xFFFFFF)
                os.sleep(1)
                os.exit()
            else
                if reactor.getReactorEUOutput() > 0 then
                    term.write(" status: ")
                    GPU.setForeground(0x00FF00)
                    term.write("NOMINAL")
                    GPU.setForeground(0xFFFFFF)
                    term.write(" - Producing ")
                    GPU.setForeground(0xFF00FF)
                    term.write(math.floor(reactor.getReactorEUOutput()))
                    GPU.setForeground(0xFFFFFF)
                    term.write(" EU/t\n")
                else
                    term.write(" status: ")
                    GPU.setForeground(0xFFFF00)
                    term.write("INACTIVE\n")
                end
            end
            i = i + 1
        end
    end
end

enableReactors()
term.clear()
while true do
    checkHeatLevels()
    os.sleep(1)
end
