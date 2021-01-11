-- wget https://raw.githubusercontent.com/gordominossi/InfOS/master/Programs/setup.lua -f
local shell = require("shell")

local tarMan = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
local tarBin = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"

shell.setWorkingDirectory("/usr/man")
shell.execute("wget " .. tarMan .. " -f")
shell.setWorkingDirectory("/bin")
shell.execute("wget " .. tarBin .. " -f")

local InfOS = "https://github.com/gordominossi/InfOS/releases/download/v0.1/InfOS.tar"

shell.setWorkingDirectory("/home")
print("Updating InfOS")
shell.execute("wget " .. InfOS .. " -f")
shell.execute("tar -xf InfOS.tar")

shell.setWorkingDirectory("/home/InfOS")
shell.execute("ln -s Libraries/ ../lib")
shell.execute("ln -s Programs/config Programs/monitor-system/config")
