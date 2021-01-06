component = require("component")

local transport = {}

function transport.set(interface, database, databaseSlot, amount)
    interface.setInterfaceConfiguration(1, database.address, databaseSlot, amount)
end
function transport.move(transposer, amount, slot)
    transposer.transferItem(0, 1, amount, 1, slot)
end
function transport.empty(transposer)
    transposer.transferItem(1, 0, 64, 2, 9)
end
function transport.clear(interface)
    interface.setInterfaceConfiguration(1, component.database.address, 1, 0)
end
function transport.check(transposer, item, amount)
    local itemstack = transposer.getStackInSlot(0, 1)
    if itemstack == nil then
        return false
    else
        if itemstack.label == item and itemstack.size >= amount then
            return true
        else
            return false
        end
    end
end
function transport.isEmpty(transposer, slot)
    local itemstack = transposer.getStackInSlot(1, slot)
    if itemstack == nil then
        return true
    else
        return false
    end
end
function transport.clearAll(assemblydata)
    for i = 1, 15, 1 do
        if assemblydata["input" .. i].getInterfaceConfiguration(1) ~= nil then
            transport.clear(assemblydata["input" .. i])
        end
    end
    for i = 1, 4, 1 do
        if assemblydata["fluid" .. i].getInterfaceConfiguration(1) ~= nil then
            transport.clear(assemblydata["fluid" .. i])
        end
    end
end
return transport
