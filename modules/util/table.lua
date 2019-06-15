function table.Print(tbl, indent, done)
	done = done or {}
	indent = indent or 0
	
	for k, v in pairs(tbl) do
		if (type(v) == "table" and not done[v]) then
			print(string.rep("\t", indent) .. string.format("%s:", tostring(k)))
			table.Print(v, indent + 2, done)
		else
			print(string.rep("\t", indent) .. string.format("%s\t=\t%s", tostring(k), tostring(v)))
		end
	end
end

function table.GetWinningKey(tab)
	local highest = -10000
	local winner = nil
	
	for k, v in RandomPairs(tab) do
		if (v > highest) then 
			winner = k
			highest = v
		end
	end
	
	return winner
end

function table.Shuffle(t)
	local n = #t
 
	while n > 2 do
		local k = math.random(n)
		t[n], t[k] = t[k], t[n]
		n = n - 1
	end
 
	return t
end

function table.merge(a,b)
	for k,v in pairs(b) do
		if not a[k] then a[k]=v end
	end
	return a
end

function table.clone(a)
	local ret = {}
	for k,v in pairs(a) do
		ret[k] = type(v) == 'table' and table.clone(v) or v
	end
	return ret
end

local function reversedipairsiter(t, i)
    i = i - 1
    if i ~= 0 then
        return i, t[i]
    end
end

function reversedipairs(t)
    return reversedipairsiter, t, #t + 1
end