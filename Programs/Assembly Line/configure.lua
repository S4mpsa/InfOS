comp=require("component"); event=require("event"); screen=require("term"); computer = require("computer"); thread = require("thread")

function findAccess(type)
    for address, component in comp.list() do
        if component == type then
            if type ~= "me_interface" then
                return address
            else
                if comp.proxy(address).getItemsInNetwork ~= nil then
                    return address
                end
            end
        end
    end
    return nil
end
local configure = {}

function configure.getAddresses()
    local file = io.open("addresses", "w")
    local a, b, c
    for item = 1, 15, 1 do
        screen.write("Add item interface "..item.." ")
        a, b, c = event.pull()
        while a ~= "component_added" do
            a, b, c = event.pull()
            os.sleep()
        end
        screen.write(b.."\n")
        file:write("input"..item..","..b.."\n")
    end
    for fluid = 1, 4, 1 do
        screen.write("Add fluid interface "..fluid.." ")
        a, b, c = event.pull()
        while a ~= "component_added" do
            a, b, c = event.pull()
        end
        screen.write(b.."\n")
        file:write("fluid"..fluid..","..b.."\n")
    end
    for itemTransposer = 1, 15, 1 do
        screen.write("Add item transposer "..itemTransposer.." ")
        a, b, c = event.pull()
        while a ~= "component_added" do
            a, b, c = event.pull()
            os.sleep()
        end
        screen.write(b.."\n")
        file:write("inputTransposer"..itemTransposer..","..b.."\n")
    end
    for fluidTransposer = 1, 4, 1 do
        screen.write("Add fluid transposer "..fluidTransposer.." ")
        a, b, c = event.pull()
        while a ~= "component_added" do
            a, b, c = event.pull()
        end
        screen.write(b.."\n")
        file:write("fluidTransposer"..fluidTransposer..","..b.."\n")
    end
    screen.write("Add data access hatch ")
    a, b, c = event.pull()
    while a ~= "component_added" do
        a, b, c = event.pull()
    end
    screen.write(b.."\n")
    file:write("data,"..b.."\n")

    local networkAccess = findAccess("me_interface")
    if networkAccess == nil then
        screen.write("Can't find a valid interface! Exiting...\n")
        os.exit()
    else file:write("items,"..networkAccess.."\n") end
    os.sleep(0.5)
    local databaseAccess = comp.database
    if databaseAccess == nil then
        screen.write("Can't find a valid database! Exiting...\n")
        os.exit()
    else file:write("database,"..databaseAccess.address.."\n") end

    local chestAccess = comp.inventory_controller
    if chestAccess == nil then
        screen.write("Can't find a valid inventory controller! Exiting...\n")
        os.exit()
    else file:write("inventory,"..chestAccess.address.."\n") end

    local controller = comp.gt_machine
    if controller == nil then
        screen.write("Can't find a valid Assembly Line! Exiting...\n")
        os.exit()
    else file:write("controller,"..controller.address.."\n") end
    screen.write("All done!\n")
    end
return configure