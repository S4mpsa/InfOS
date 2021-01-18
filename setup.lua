-- wget https://raw.githubusercontent.com/gordominossi/InfOS/master/setup.lua -f
local shell = require("shell")

local tarMan = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
local tarBin = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"

shell.setWorkingDirectory("/usr/man")
shell.execute("wget -fq " .. tarMan)
shell.setWorkingDirectory("/bin")
shell.execute("wget -fq " .. tarBin)

local InfOS = "https://github.com/gordominossi/InfOS/releases/download/v0.2.1/InfOS.tar"

shell.setWorkingDirectory("/home")
if not shell.resolve("/home/InfOS") then
    shell.execute("mkdir InfOS")
end

shell.setWorkingDirectory("/home/InfOS")
print("\nUpdating InfOS")
shell.execute("wget -fq " .. InfOS .. " -f")
print("...")
shell.execute("tar -xf InfOS.tar")
shell.execute("rm -f InfOS.tar")

shell.setWorkingDirectory("/home/")
shell.execute("rm -rf lib")
shell.execute("mkdir lib")
shell.execute("cp -r InfOS/Libraries/* lib")
shell.execute("rm -f .shrc")
shell.execute("cp InfOS/.shrc .shrc")
shell.execute("rm -f setup.lua")
shell.execute("cp InfOS/setup.lua setup.lua")

print("Success!\n")
