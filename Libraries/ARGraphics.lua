comp = require("component"); screen = require("term"); computer = require("computer"); event = require("event")

local AR = {}

local terminal = {x = 8257, y = 199, z = -2731}
local function hexToRGB(hexcode) 
    local r = ((hexcode >> 16) & 0xFF) / 255.0
    local g = ((hexcode >> 8) & 0xFF) / 255.0
    local b = ((hexcode) & 0xFF) / 255.0
    return r, g, b
end
function AR.hexToRGB(hexcode) 
    local r = ((hexcode >> 16) & 0xFF) / 255.0
    local g = ((hexcode >> 8) & 0xFF) / 255.0
    local b = ((hexcode) & 0xFF) / 255.0
    return r, g, b
end
function AR.cube(glasses, x, y, z, color, alpha, scale)
    scale = scale or 1; alpha = alpha or 1
    local cube = glasses.addCube3D()
    cube.set3DPos(x - terminal.x, y - terminal.y, z - terminal.z)
    cube.setColor(hexToRGB(color)); cube.setAlpha(alpha); cube.setScale(scale)
    return cube
end

function AR.line(glasses, source, dest, color, alpha, scale)
    scale = scale or 1; alpha = alpha or 1
    local line = glasses.addLine3D()
    line.setVertex(1, source.x - terminal.x+0.5, source.y - terminal.y+0.5, source.z - terminal.z+0.5)
    line.setVertex(2, dest.x - terminal.x+0.5, dest.y - terminal.y+0.5, dest.z - terminal.z+0.5)
    line.setColor(hexToRGB(color)); line.setAlpha(alpha); line.setScale(scale)
    return line
end

function AR.worldText(glasses, name, x, y, z, color, alpha, scale)
    scale = scale or 0.04; alpha = alpha or 1
    local text = glasses.addFloatingText()
    text.set3DPos(x - terminal.x, y - terminal.y, z - terminal.z)
    text.setColor(hexToRGB(color)); text.setAlpha(alpha); text.setScale(scale)
    text.setText(name)
    return text
end

function AR.hudTriangle(glasses, a, b, c, color, alpha)
    alpha = alpha or 1.0
    local triangle = glasses.addTriangle()
    triangle.setColor(hexToRGB(color)); triangle.setAlpha(alpha);
    triangle.setVertex(1, a[1], a[2]); triangle.setVertex(2, b[1], b[2]); triangle.setVertex(3, c[1], c[2])
    return triangle
end

function AR.hudQuad(glasses, a, b, c, d, color, alpha)
    alpha = alpha or 1.0
    local quad = glasses.addQuad()
    quad.setColor(hexToRGB(color)); quad.setAlpha(alpha)
    quad.setVertex(1, a[1], a[2]); quad.setVertex(2, b[1], b[2]); quad.setVertex(3, c[1], c[2]); quad.setVertex(4, d[1], d[2])
    return quad
end

function AR.hudRectangle(glasses, x, y, w, h, color, alpha)
    alpha = alpha or 1.0
    local rect = glasses.addRect()
    rect.setPosition(x, y); rect.setSize(h, w)
    rect.setColor(hexToRGB(color)); rect.setAlpha(alpha)
    return rect
end

function AR.textSize(textObject, scale)
    local oldX, oldY = textObject.getPosition()
    oldX = oldX * textObject.getScale()
    oldY = oldY * textObject.getScale()
    textObject.setScale(scale)
    textObject.setPosition(oldX/(scale+1), oldY/(scale+1))
end

function AR.hudText(glasses, displayText, x, y, color, scale)
    scale = scale or 1
    local text = glasses.addTextLabel()
    text.setText(displayText)
    text.setPosition(x, y)
    text.setColor(hexToRGB(color))
    AR.textSize(text, scale)
    return text
end

return AR