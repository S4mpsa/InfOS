local function exec(miner)
    return miner.isMachineActive() and miner.hasWork() -- TODO: differenciate cases
end

return exec
