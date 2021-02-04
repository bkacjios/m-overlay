local memory = require("memory")

local zce = {}

function zce.isZce()
    return memory.gameid == "PZLE01"
end

function zce.isOot()
    return memory.oot.ucode == 74 -- "J" is the ucode version for oot
end

function zce.isMajora()
    return memory.mm.ucode == 73 -- "I" is the ucode version for majora's mask
end

return zce
