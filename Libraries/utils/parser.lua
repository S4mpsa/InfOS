local Parser = {
    parseProgress = function(progressString)
        local a = "Progress: §a2§r s / §e5§r s"
        return {current = 0, max = 1}
    end,
    parseStoredEnergy = function(storedEnergyString)
        local noCommaString = string.gsub(storedEnergyString, ",", "")

        local current = string.sub(noCommaString, string.find(noCommaString, "%ba§"))
        current = tonumber((string.gsub(string.gsub(current, "a", ""), "§", "")))

        local maximum = string.sub(noCommaString, string.find(noCommaString, "%be§"))
        maximum = tonumber((string.gsub(string.gsub(maximum, "e", ""), "§", "")))

        return {current = current, maximum = maximum}
    end,
    parseAverageInput = function(averageInputString)
        local noCommaString = string.gsub(averageInputString, ",", "")
        return tonumber((string.sub(noCommaString, string.find(noCommaString, "%d+"))))
    end,
    parseAverageOutput = function(averageOutputString)
        local noCommaString = string.gsub(averageOutputString, ",", "")
        return tonumber((string.sub(noCommaString, string.find(noCommaString, "%d+"))))
    end,
    parseProblems = function(problemsString)
        local problems = string.sub(problemsString, string.find(problemsString, "c%d"))
        return tonumber((string.gsub(problems, "c", "")))
    end,
    parseEfficiency = function(efficiencyString)
        local noParagraphMarkString = string.gsub(efficiencyString, "§r", "")
        local efficiency = string.sub(noParagraphMarkString, string.find(noParagraphMarkString, "%d+%.*%d*%s%%"))
        return tonumber((string.gsub(efficiency, "%s%%", "")))
    end,
    parseName = function(nameString)
        return string.gsub(string.gsub(nameString, "§9", ""), "§r", "")
    end,
    parseWorkArea = function(worAreaString)
        local size = string.sub(worAreaString, string.find(worAreaString, "§a%d+x%d+§r"))
        return string.gsub(string.gsub(size, "§a", ""), "§r", "")
    end
}

return Parser
