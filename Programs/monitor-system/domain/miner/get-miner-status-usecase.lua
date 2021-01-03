local function exec(miners)
    local statuses = {}
    if #miners > 0 then
        for address, miner in ipairs(miners) do
            statuses[address] = {
                active = miner:isMachineActive(),
                hasWork = miner:hasWork()
            }
        end
    end
    return statuses
end

return exec
