local ranks = {
    t = {
        {
            name = "Grandmaster",
            min = 2191.75,
            max = 3000
        },
        {
            name = "Diamond 3",
            max = 2191.74,
            min = 2136.28
        },
        {
            name = "Diamond 2",
            max = 2136.27,
            min = 2073.67
        },
        {
            name = "Diamond 1",
            max = 2073.66,
            min = 2003.92
        },
        {
            name = "Platinum 3",
            max = 2003.91,
            min = 1927.03
        },
        {
            name = "Platinum 2",
            max = 1927.02,
            min = 1843
        },
        {
            name = "Platinum 1",
            max = 1842.99,
            min = 1751.83
        },
        {
            name = "Gold 3",
            max = 1751.82,
            min = 1653.52
        },
        {
            name = "Gold 2",
            max = 1653.51,
            min = 1548.07
        },
        {
            name = "Gold 1",
            max = 1548.06,
            min = 1435.48
        },
        {
            name = "Silver 3",
            max = 1435.47,
            min = 1315.75
        },
        {
            name = "Silver 2",
            max = 1315.74,
            min = 1188.88
        },
        {
            name = "Silver 1",
            max = 1188.87,
            min = 1054.87
        },
        {
            name = "Bronze 3",
            max = 1054.86,
            min = 913.72
        },
        {
            name = "Bronze 2",
            max = 913.71,
            min = 765.43
        },
        {
            name = "Bronze 1",
            max = 765.42,
            min = 0
        }
    },
    f = {
        {
            name = "Master 3",
            max = 3000,
            min = 2350
        },
        {
            name = "Master 2",
            max = 2349.99,
            min = 2275
        },
        {
            name = "Master 1",
            max = 2274.99,
            min = 2191.75
        },
        {
            name = "Diamond 3",
            max = 2191.74,
            min = 2136.28
        },
        {
            name = "Diamond 2",
            max = 2136.27,
            min = 2073.67
        },
        {
            name = "Diamond 1",
            max = 2073.66,
            min = 2003.92
        },
        {
            name = "Platinum 3",
            max = 2003.91,
            min = 1927.03
        },
        {
            name = "Platinum 2",
            max = 1927.02,
            min = 1843
        },
        {
            name = "Platinum 1",
            max = 1842.99,
            min = 1751.83
        },
        {
            name = "Gold 3",
            max = 1751.82,
            min = 1653.52
        },
        {
            name = "Gold 2",
            max = 1653.51,
            min = 1548.07
        },
        {
            name = "Gold 1",
            max = 1548.06,
            min = 1435.48
        },
        {
            name = "Silver 3",
            max = 1435.47,
            min = 1315.75
        },
        {
            name = "Silver 2",
            max = 1315.74,
            min = 1188.88
        },
        {
            name = "Silver 1",
            max = 1188.87,
            min = 1054.87
        },
        {
            name = "Bronze 3",
            max = 1054.86,
            min = 913.72
        },
        {
            name = "Bronze 2",
            max = 913.71,
            min = 765.43
        },
        {
            name = "Bronze 1",
            max = 765.42,
            min = 0
        }
    }
}

function getRank(elo, b)
    if b then b = 't' else b = 'f' end
    print('getting rank')
    for k, v in ipairs(ranks[b]) do
        if v.min < elo and v.max > elo then
            return v.name
        end
    end
end