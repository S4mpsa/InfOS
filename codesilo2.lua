comp = require("component"); event = require("event")
ARG = require("ARGraphics"); get = require("easy"); config = require("config")
ARW = require("ARWidgets")

function popupText(glasses, text, x, y, color)
    local substringLength = 1
    local width = #text * 5
    local steps = math.ceil(#text / substringLength)
    local stepLength = substringLength * 5
    local i = 1
    local background = ARG.hudQuad(glasses, {x-5, y}, {x-5, y+9}, {x-5+1, y+9}, {x-5+1, y}, machineBackground, 0.5)
    local top = ARG.hudQuad(glasses, {x-5, y-1}, {x-5, y}, {x-5+1, y}, {x-5+1, y-1}, machineBackground)
    local bottom = ARG.hudQuad(glasses, {x-5, y+9}, {x-5, y+10}, {x-5+1, y+10}, {x-5+1, y+9}, machineBackground)
    local hudText = ARG.hudText(glasses, "", x+1, y+1, color)
    local wedge = ARG.hudQuad(glasses, {x-5-10, y-1}, {x-5, y-1}, {x-5, y+10}, {x-5+11, y+10}, machineBackground)
    local direction = 1
    local function advance()
        background.setVertex(3, math.min(width + 10, x + stepLength * i + 10), y+9)
        background.setVertex(4, math.min(width, x + stepLength * i), y)
        top.setVertex(3, math.min(width, x + stepLength * i), y)
        top.setVertex(4, math.min(width, x + stepLength * i), y-1)
        bottom.setVertex(3, math.min(width + 10, x + stepLength * i + 10), y+10)
        bottom.setVertex(4, math.min(width + 10, x + stepLength * i + 10), y+9)
        wedge.setVertex(1, math.min(width-1, x + stepLength * i-1), y-1)
        wedge.setVertex(2, math.min(width + 10, x + stepLength * i + 10), y+10)
        wedge.setVertex(3, math.min(width + 11, x + stepLength * i + 11), y+10)
        wedge.setVertex(4, math.min(width + 1, x + stepLength * i + 1), y-1)
        hudText.setText(string.sub(text, 1, substringLength * i))
        i = i + direction
        if i < 0 then
            glasses.removeObject(background.getID())
            glasses.removeObject(top.getID())
            glasses.removeObject(bottom.getID())
            glasses.removeObject(hudText.getID())
            glasses.removeObject(wedge.getID())
        end
    end
    local function retract()
        direction = -1
        event.timer(0.03, advance, steps+2)
    end
    event.timer(0.03, advance, steps)
    return retract
end

a = popupText(comp.glasses, "Made by Sampsa  ", 0, 50, workingColour)
b = popupText(comp.glasses, "Widget breakdown in comments!", 0, 65, workingColour)
c = popupText(comp.glasses, "+ github!", 0, 80, workingColour)