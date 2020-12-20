local Parser = {
    parseProgress = function(progressString)
        local a = "Progress: §a2§r s / §e5§r s"
        return {current = 0, max = 1}
    end,
    parseStoredEnergy = function(storedEnergyString)
        local noCommaString = string.gsub(storedEnergyString, ",", "")

        local current = string.sub(noCommaString, string.find(noCommaString, "%ba§"))
        current = string.gsub(current, "a", "")
        current = tonumber((string.gsub(current, "§", "")))

        local maximum = string.sub(noCommaString, string.find(noCommaString, "%be§"))
        maximum = string.gsub(maximum, "e", "")
        maximum = tonumber((string.gsub(maximum, "§", "")))
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
        return tonumber((string.gsub(string.sub(problemsString, string.find(problemsString, "c%d")), "c", "")))
    end,
    parseEfficiency = function(efficiencyString)
        local noParagraphMarkString = string.gsub(efficiencyString, "§r", "")
        local efficiency = string.sub(noParagraphMarkString, string.find(noParagraphMarkString, "%d+%.*%d*%s%%"))
        return tonumber((string.gsub(efficiency, "%s%%", "")))
    end
}

return Parser
