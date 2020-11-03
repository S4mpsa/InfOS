local path = "/lib"
local shell = require("shell")
local download_list = 
{
    "https://raw.githubusercontent.com/S4mpsa/InfOS/master/Libraries/ARWidgets.lua",
    "https://raw.githubusercontent.com/S4mpsa/InfOS/master/Libraries/config.lua",
    "https://raw.githubusercontent.com/S4mpsa/InfOS/master/Libraries/graphics.lua",
    "https://raw.githubusercontent.com/S4mpsa/InfOS/master/Libraries/utility.lua",
    "https://raw.githubusercontent.com/S4mpsa/InfOS/master/Libraries/widgets.lua",
    "https://raw.githubusercontent.com/S4mpsa/InfOS/master/Libraries/ARGraphics.lua"
}
shell.setWorkingDirectory(path)
print("Updating Files")
for k,v in pairs(download_list) do
    print("Fetching ",v)
    local command = "wget "..v.." -f"
    shell.execute(command)
end
shell.setWorkingDirectory("/home")