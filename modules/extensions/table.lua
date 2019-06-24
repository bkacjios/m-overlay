function table.merge(a,b)
	for k,v in pairs(b) do
		if not a[k] then a[k]=v end
	end
	return a
end

function table.clone(a)
	local ret = {}
	for k,v in pairs(a) do
		ret[k] = type(v) == "table" and table.clone(v) or v
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

function table.hasValue(tbl, val)
	for key, value in pairs(tbl) do
		if (value == val) then return true, key end
	end
	return false
end

do
	local function val_to_str(v, stack, scope)
		if type(v) == "string" then
			v = string.gsub(v, "\n", "\\n" )
			if string.match(string.gsub(v,"[^'\"]",""), '^"+$') then
				return "'" .. v .. "'"
			end
			return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
		else
			return type(v) == "table" and table.tostring(v, stack, scope) or tostring(v)
		end
	end

	local function key_to_str(k, stack, scope)
		if type(k) == "string" and string.match(k, "^[_%a][_%a%d]*$") then
			return k
		else
			return "[" .. val_to_str(k, stack, scope) .. "]"
		end
	end

	function table.tostring(tbl, stack, scope)
		stack = stack or {}
		scope = scope or 0

		if stack[tbl] then return error("circular reference") end

		stack[tbl] = true
		scope = scope + 1

		local result = "{\n"

		for k, v in pairs(tbl) do
			local tabs = string.rep("\t", scope)
			if type(v) == "table" then
				result = result .. tabs .. key_to_str(k, stack, scope) .. " = " .. table.tostring(v, stack, scope) .. "\n"
			else
				result = result .. tabs .. key_to_str(k, stack, scope) .. " = " .. val_to_str(v, stack, scope) .. "\n"
			end
		end

		scope = scope - 1
		stack[tbl] = nil

		return result .. string.rep("\t", scope) .. "}"
	end
end

--[[local test = {
	1, 2, 5,
	["Kappa 1 2 3 \n lul"] = true,
	data = {
		1337.84239,
		test = {
			7, 8, "NINE"
		}
	}
}

print(table.tostring(love))]]

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

function table.randomkeyvalue(tbl)
	local keys = {}
	for k,v in pairs(tbl) do
		table.insert(keys, k)
	end
	local key = keys[math.random(1, #keys)]
	return key, tbl[key]
end