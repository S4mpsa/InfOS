local fluidMap = {
    ["fluid.molten.solderingalloy"] = {name = "gt.metaitem.99.314.name", size = 144},
    ["fluid.lubricant"] = {name = "gt.Volumetric_Flask.name", size = 250},
    ["IC2 Coolant"] = {name = "Coolant Cell", size = 1000},
    ["fluid.molten.styrenebutadienerubber"] = {name = "gt.metaitem.99.635.name", size = 144},
    ["fluid.molten.niobiumtitanium"] = {name = "gt.metaitem.99.360.name", size = 144},
    ["fluid.molten.tritanium"] = {name = "gt.metaitem.99.329.name", size = 144},
    ["fluid.Neon"] = {name = "Neon Cell", size = 1000},
    ["fluid.molten.naquadria"] = {name = "gt.metaitem.99.327.name", size = 144}
}

local dictionary = {
    ["gt.metaitem.01.32705.name"] = "gt.metaitem.03.32084.name", --IV
    ["gt.metaitem.03.32086.name"] = "gt.metaitem.03.32084.name",
    ["gt.metaitem.03.32089.name"] = "gt.metaitem.03.32084.name",
    ["gt.metaitem.03.32085.name"] = "gt.metaitem.03.32083.name", --EV
    ["gt.metaitem.01.32704.name"] = "gt.metaitem.03.32083.name"
}

-- dictlist = {
--     {"Nanoprocessor Assembly","Quantumprocessor","Workstation"}, --EV
--     {"Crystalprocessor","Elite Nanocomputer","Quantumprocessor Assembly","Mainframe"}, --IV
--     {"Master Quantumcomputer","Wetwareprocessor","Crystalprocessor Assembly","Nanoprocessor Mainframe"}, -- LuV
--     {"Bioprocessor","Wetwareprocessor Assembly","Ultimate Crystalcomputer","Quantumprocessor Mainframe"}, --ZPM
--     {"Wetware Supercomputer","Bioprocessor Assembly","Crystalprocessor Mainframe"}, -- UV
--     {"Wetware Mainframe","Bioware Supercomputer"}, -- UHV
--     {"Bio Mainframe"} -- UEV
-- }

-- dictlist = {
--     {"gt.metaitem.03.32083.name","gt.metaitem.03.32085.name","gt.metaitem.01.32704.name"}, --EV
--     {"gt.metaitem.03.32089.name","gt.metaitem.03.32086.name","gt.metaitem.03.32084.name","gt.metaitem.01.32705.name"}, --IV
--     {"gt.metaitem.03.32087.name","gt.metaitem.03.32092.name","gt.metaitem.03.32096.name","gt.metaitem.01.32706.name"}, -- LuV
--     {"gt.metaitem.03.32097.name","gt.metaitem.03.32093.name","gt.metaitem.03.32090.name","gt.metaitem.03.32088.name"}, --ZPM
--     {"gt.metaitem.03.32091.name"}, -- UV
--     {"gt.metaitem.03.32095.name","gt.metaitem.03.32099.name"}, -- UHV
--     {"gt.metaitem.03.32120.name"} -- UEV
-- }

return fluidMap, dictionary
