local Parser = {}

function Parser.parseProgress(progressString)
    local current = string.sub(progressString, string.find(progressString, "%ba§"))
    current = tonumber((string.gsub(string.gsub(current, "a", ""), "§", "")))

    local maximum = string.sub(progressString, string.find(progressString, "%be§"))
    maximum = tonumber((string.gsub(string.gsub(maximum, "e", ""), "§", "")))

    return {current = current, maximum = maximum}
end

function Parser.parseStoredEnergy(storedEnergyString)
    local noCommaString = string.gsub(storedEnergyString, ",", "")

    local current = string.sub(noCommaString, string.find(noCommaString, "%ba§"))
    current = tonumber((string.gsub(string.gsub(current, "a", ""), "§", "")))

    local maximum = string.sub(noCommaString, string.find(noCommaString, "%be§"))
    maximum = tonumber((string.gsub(string.gsub(maximum, "e", ""), "§", "")))

    return {current = current, maximum = maximum}
end

function Parser.parseAverageInput(averageInputString)
    local noCommaString = string.gsub(averageInputString, ",", "")
    return tonumber((string.sub(noCommaString, string.find(noCommaString, "%d+"))))
end

function Parser.parseAverageOutput(averageOutputString)
    local noCommaString = string.gsub(averageOutputString, ",", "")
    return tonumber((string.sub(noCommaString, string.find(noCommaString, "%d+"))))
end

function Parser.parseProblems(problemsString)
    local problems = string.sub(problemsString, string.find(problemsString, "c%d"))
    return tonumber((string.gsub(problems, "c", "")))
end

function Parser.parseEfficiency(efficiencyString)
    local noParagraphMarkString = string.gsub(efficiencyString, "§r", "")
    local efficiency = string.sub(noParagraphMarkString, string.find(noParagraphMarkString, "%d+%.*%d*%s%%"))
    return tonumber((string.gsub(efficiency, "%s%%", "")))
end

function Parser.parseName(nameString)
    return string.gsub(string.gsub(nameString, "§9", ""), "§r", "")
end

function Parser.parseWorkArea(worAreaString)
    local size = string.sub(worAreaString, string.find(worAreaString, "§a%d+x%d+§r"))
    return string.gsub(string.gsub(size, "§a", ""), "§r", "")
end

return Parser
