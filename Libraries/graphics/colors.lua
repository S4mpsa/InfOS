local colors = {
    red = 0xFF0000,
    lime = 0x00FF00,
    blue = 0x0000FF,
    magenta = 0xFF00FF,
    yellow = 0xFFFF00,
    cyan = 0x00FFFF,
    green = 0x008000,
    purple = 0x800080,
    steelBlue = 0x4682B4,
    brown = 0xA52A2A,
    chocolate = 0xD2691E,
    rosyBrown = 0xBC8F8F,
    white = 0xFFFFFF,
    lightGray = 0xD3D3D3,
    darkGray = 0xA9A9A9,
    darkSlateGrey = 0x2F4F4F,
    black = 0x000000,
    machineBackground = colors.darkGray,
    progressBackground = colors.lightGray,
    labelColor = colors.chocolate,
    errorColor = colors.red,
    idleColor = colors.purple,
    workingColor = colors.steelBlue,
    positiveEUColor = colors.lime,
    negativeEUColor = colors.brown,
    timeColor = colors.purple,
    textColor = colors.black,
    hudColor = colors.darkSlateGrey,
    mainColor = colors.rosyBrown,
    background = colors.black,
    accentA = colors.cyan,
    accentB = colors.magenta,
    barColor = colors.blue
}

local RGB = {}

for name, value in pairs(colors) do
    local function hexToRGB(hexcode)
        local r = ((hexcode >> 16) & 0xFF) / 255.0
        local g = ((hexcode >> 8) & 0xFF) / 255.0
        local b = ((hexcode) & 0xFF) / 255.0
        return r, g, b
    end
    RGB[name] = hexToRGB(value)
end

colors.RGB = RGB

setmetatable(
    colors,
    {
        __index = function(self, color)
            return self.RGB[color] or {0, 0, 0}
        end
    }
)

return colors
