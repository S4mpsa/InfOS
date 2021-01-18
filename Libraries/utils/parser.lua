local parser = {}

function parser.parseProgress(progressString)
    local current = string.sub(progressString, string.find(progressString, "%ba§"))
    current = tonumber((string.gsub(string.gsub(current, "a", ""), "§", "")))

    local maximum = string.sub(progressString, string.find(progressString, "%be§", (string.find(progressString, "/"))))
    maximum = tonumber((string.gsub(string.gsub(maximum, "e", ""), "§", "")))

    return {current = current, maximum = maximum}
end

function parser.parseStoredEnergy(storedEnergyString)
    local noCommaString = string.gsub(storedEnergyString, ",", "")

    local current = string.sub(noCommaString, string.find(noCommaString, "%ba§"))
    current = tonumber((string.gsub(string.gsub(current, "a", ""), "§", "")))

    local maximum = string.sub(noCommaString, string.find(noCommaString, "%be§"))
    maximum = tonumber((string.gsub(string.gsub(maximum, "e", ""), "§", "")))

    return {current = current, maximum = maximum}
end

function parser.parseAverageInput(averageInputString)
    local noCommaString = string.gsub(averageInputString, ",", "")
    return tonumber((string.sub(noCommaString, string.find(noCommaString, "%d+"))))
end

function parser.parseAverageOutput(averageOutputString)
    local noCommaString = string.gsub(averageOutputString, ",", "")
    return tonumber((string.sub(noCommaString, string.find(noCommaString, "%d+"))))
end

function parser.parseProblems(problemsString)
    local problems = string.sub(problemsString, string.find(problemsString, "c%d"))
    return tonumber((string.gsub(problems, "c", "")))
end

function parser.parseEfficiency(efficiencyString)
    local noParagraphMarkString = string.gsub(efficiencyString, "§r", "")
    local efficiency = string.sub(noParagraphMarkString, string.find(noParagraphMarkString, "%d+%.*%d*%s%%"))
    return tonumber((string.gsub(efficiency, "%s%%", "")))
end

function parser.parseName(nameString)
    return string.gsub(string.gsub(nameString, "§9", ""), "§r", "")
end

function parser.parseWorkArea(worAreaString)
    local size = string.sub(worAreaString, string.find(worAreaString, "§a%d+x%d+§r"))
    return string.gsub(string.gsub(size, "§a", ""), "§r", "")
end

function parser.parseProbablyUses(probablyUsesString)
    local noCommaString = string.gsub(probablyUsesString, ",", "")
    local estimate = string.sub(noCommaString, string.find(noCommaString, "%bc§"))
    return tonumber((string.gsub(string.gsub(estimate, "c", ""), "§", "")))
end

return parser
