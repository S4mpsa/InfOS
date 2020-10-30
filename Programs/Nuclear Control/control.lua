comp=require("component"); event=require("event"); screen=require("term"); computer = require("computer"); thread = require("thread")

local GPU = comp.gpu
GPU.setResolution(54, 26)
function enableReactors()
    comp.redstone.setOutput(1, 15)
end
function disableReactors()
    comp.redstone.setOutput(1, 0)
end

function checkHeatLevels()
    screen.setCursor(1, 1)
    local i = 1
    for address, type in pairs(comp.list()) do
        if type == "reactor_chamber" then
            screen.write("Reactor "..i)
            if i < 10 then screen.write(" ") end
            local reactor = comp.proxy(address)
            if reactor.getHeat() > 0 then
                GPU.setForeground(0xFF0000)
                screen.write(" REACTOR HEATING! SHUTTING DOWN")
                disableReactors()
                GPU.setForeground(0xFFFFFF)
                os.sleep(1)
                os.exit()
            else
                if reactor.getReactorEUOutput() > 0 then
                    screen.write(" status: ")
                    GPU.setForeground(0x00FF00)
                    screen.write("NOMINAL")
                    GPU.setForeground(0xFFFFFF)
                    screen.write(" - Producing ")
                    GPU.setForeground(0xFF00FF)
                    screen.write(math.floor(reactor.getReactorEUOutput()))
                    GPU.setForeground(0xFFFFFF)
                    screen.write(" EU/t\n")
                else
                    screen.write(" status: ")
                    GPU.setForeground(0xFFFF00)
                    screen.write("INACTIVE\n")
                end
            end
            i = i + 1
        end
    end
end

enableReactors()
screen.clear()
while true do
    checkHeatLevels()
    os.sleep(1)
end