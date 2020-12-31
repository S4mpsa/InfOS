-- wget https://raw.githubusercontent.com/gordominossi/InfOS/master/Programs/update.lua -f

local shell = require("shell")

local tarMan = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
local tarBin = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"
local InfOS = "https://github.com/gordominossi/InfOS/releases/download/v0/InfOS.tar"

shell.setWorkingDirectory("/usr/man")
shell.execute("wget " .. tarMan .. " -f")

shell.setWorkingDirectory("/bin")
shell.execute("wget " .. tarBin .. " -f")

shell.setWorkingDirectory("/home")
print("Updating InfOS")
shell.execute("wget " .. InfOS .. " -f")
shell.execute("tar -xf InfOS.tar")
