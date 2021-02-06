local memory = require("memory")

local zce = {}

function zce.isZce()
    return memory.gameid == "PZLE01" or memory.gameid == "PZLJ01"
end

function zce.isOot()
    return memory.oot.ucode == 74 -- "J" is the ucode version for oot
end

function zce.isMajora()
    return memory.mm.ucode == 73 -- "I" is the ucode version for majora's mask
end

function zce.isZ1()
    -- "Q" is the first letter of the QFC version, I have no idea what that is
    -- but it loads in the same place every time from what I've found
    return memory.z1.qfc == 81 
end

function zce.isZ2()
    -- same concept as above
    return memory.z2.qfc == 81
end

return zce
