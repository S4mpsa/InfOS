local path = "/home"
local shell = require("shell")
local download_list = {
    "https://raw.githubusercontent.com/S4mpsa/InfOS/master/Programs/Assembly%20Line/assemblyClient.lua",
    "https://raw.githubusercontent.com/S4mpsa/InfOS/master/Programs/Assembly%20Line/dictionary.lua",
    "https://raw.githubusercontent.com/S4mpsa/InfOS/master/Programs/Assembly%20Line/transport.lua",
    "https://raw.githubusercontent.com/S4mpsa/InfOS/master/Programs/Assembly%20Line/util.lua"
}
shell.setWorkingDirectory(path)
print("Updating Files")
for k, v in pairs(download_list) do
    print("Fetching ", v)
    local command = "wget " .. v .. " -f"
    shell.execute(command)
end
shell.setWorkingDirectory("/home")
