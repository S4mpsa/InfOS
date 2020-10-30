local comp=require("component"); local event=require("event"); local screen=require("term"); local computer = require("computer")

local transport = {}

function transport.waitForAssemblyline(time, assemblyController)
    local startTime = computer.uptime()
    --Wait for assembling to start
    while not assemblyController.hasWork() and computer.uptime() < startTime + 10 do
        os.sleep(0.3)
    end
    if not assemblyController.hasWork() then
        screen.write(" Error with starting assembly!")
    else
        screen.write(" Process started ...")
        local progress = assemblyController.getWorkMaxProgress() - assemblyController.getWorkProgress()
        while computer.uptime() < (startTime + (time / 20)) and progress > 100 and assemblyController.hasWork() do
            os.sleep(0.1)
            progress = assemblyController.getWorkMaxProgress() - assemblyController.getWorkProgress()
        end
    end
end

function transport.clearInterfaces(assemblyData, itemFrom, itemTo, fluidFrom, fluidTo)
    itemFrom = itemFrom or 1
    itemTo = itemTo or 15
    fluidFrom = fluidFrom or 1
    fluidTo = fluidTo or 4
    local database = assemblyData["database"]
    if itemFrom > 0 then
        for i = itemFrom, itemTo, 1 do
            if assemblyData["input"..i].getInterfaceConfiguration(1) ~= nil then assemblyData["input"..i].setInterfaceConfiguration(1, database.address, 1, 0) end
        end
    end
    if fluidFrom > 0 then
        for i = fluidFrom, fluidTo, 1 do
            if assemblyData["fluid"..i].getInterfaceConfiguration(1) ~= nil then assemblyData["fluid"..i].setInterfaceConfiguration(1, database.address, 1, 0) end
        end
    end
end

return transport