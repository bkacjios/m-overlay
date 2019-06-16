function table.shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i] 
	end
	return tbl
end

function table.merge(first, second)
	for k,v in pairs(second) do
		first[k] = v
	end
end

function table.hasValue(tbl, val)
	for key, value in pairs(tbl) do
		if (value == val) then return true, key end
	end
	return false
end

function table.val_to_str(v)
	if "string" == type(v) then
		v = string.gsub(v, "\n", "\\n" )
		if string.match(string.gsub(v,"[^'\"]",""), '^"+$') then
			return "'" .. v .. "'"
		end
		return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
	else
		return "table" == type(v) and table.tostring(v) or tostring( v )
	end
end

function table.key_to_str(k)
	if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
		return k
	else
		return "[" .. table.val_to_str(k) .. "]"
	end
end

function table.print(tbl, indent, done)
	done = done or {[tbl] = true}
	indent = indent or 1

	for k, v in pairs(tbl) do
		local tabs = string.rep("\t", indent)
		if (type(v) == "table" and not done[v]) then
			print(tabs .. table.key_to_str(k) .. " = {")
			done[v] = true
			table.print(v, indent + 1, done)
			print(tabs .. "}")
		else
			print(tabs .. table.key_to_str(k) .. " = " .. table.val_to_str(v))
		end
	end
end

function table.copy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

function table.concatNumberedList(table, sep, oxford)
	if type(table) ~= "table" then
		return tostring(table)
	end

	local str = ""
	local num = #table
	for i=1,num do
		if i < num then
			-- If we aren't at the end of the list, use commas
			-- If we're one before the end of the list, use an oxford comma if we want it
			str = str .. i .. ". " .. table[i] .. ((oxford or i < num - 1) and ", " or " ")
		elseif i > 1 then
			-- If we're the last item and we have more than 1 item already..
			-- Seperate using our defined seperator word
			str = str .. (sep or "and") .. " " .. i .. ". " .. table[i]
		else
			-- Single item..
			str = i .. ". " .. table[i]
		end
	end
	return str
end

function table.concatList(table, sep, oxford)
	if type(table) ~= "table" then
		return tostring(table)
	end

	local str = ""
	local num = #table
	for i=1,num do
		if i < num then
			-- If we aren't at the end of the list, use commas
			-- If we're one before the end of the list, use an oxford comma if we want it
			str = str .. table[i] .. ((oxford or i < num - 1) and ", " or " ")
		elseif i > 1 then
			-- If we're the last item and we have more than 1 item already..
			-- Seperate using our defined seperator word
			str = str .. (sep or "and") .. " " .. table[i]
		else
			-- Single item..
			-- Don't even bother concating the string
			str = table[i]
		end
	end
	return str
end

function table.max(tbl)
	local max_key = nil
	local max_value = -math.huge
	for key, value in pairs(tbl) do
		value = assert(tonumber(value), "expected a table full of numbers..")
		if value > max_value then
			max_key = key
			max_value = value
		end
	end
	return max_key, max_value
end

function table.min(tbl)
	local min_key = nil
	local min_value = math.huge
	for key, value in pairs(tbl) do
		value = assert(tonumber(value), "expected a table full of numbers..")
		if value < min_value then
			min_key = key
			min_value = value
		end
	end
	return min_key, min_value
end

function table.avg(tbl)
	local num = 0
	local total = 0
	for key, value in pairs(tbl) do
		value = assert(tonumber(value), "expected a table full of numbers..")
		total = total + value
		num = num + 1
	end
	return total / num
end

function table.sum(tbl)
	local total = 0
	for key, value in pairs(tbl) do
		value = assert(tonumber(value), "expected a table full of numbers..")
		total = total + value
	end
	return total
end

function table.random(tbl)
	return tbl[math.random(1, #tbl)]
end

function table.random2(tbl)
	local keys = {}
	for k,v in pairs(tbl) do
		table.insert(keys, k)
	end
	local key = keys[math.random(1, #keys)]
	return key, tbl[key]
end