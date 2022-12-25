local https = require("https")

-- these two channels are used to send requests and progress updates back and forth
local requests_channel = love.thread.getChannel("dl-requests")
local progress_channel = love.thread.getChannel("dl-progress")

-- this is a re-implementation of the ltn12 file sink that uses love.filesystem instead of Lua's io functions
local function love_file_sink(filename)
	-- create enclosing directories
	local dirname = string.gmatch(filename, "(.*/)([^/]*)")()
	if dirname then
		local dir_ok = love.filesystem.createDirectory(dirname)
		if not dir_ok then error("could not create directory "..dirname) end
	end

	local file = love.filesystem.newFile(filename)
	local ok, err = file:open("w")
	if not ok then error(err) end

	return function(chunk, err)
		if chunk then
			local ok, err = file:write(chunk, #chunk)
			if not ok then return nil, err end
		else
			file:close()
			return nil, err
		end

		-- indicate that we accept more data
		return true
	end
end

-- this is a special "sink" that sends progress updates whenever it receives a new chunk of data.
-- See http://lua-users.org/wiki/FiltersSourcesAndSinks for a bit of documentation
local function progress_sink(id, output_sink)
	return function(chunk, err)
		if chunk then
			progress_channel:push({id = id, event = {chunk = #chunk}})
		elseif er then
			-- if chunk is nil, then the download is finished, or we have an error
			progress_channel:push({id = id, event = {error = err}})
		end

		-- forward chunk and err to the underlying sink
		return output_sink(chunk, err)
	end
end

-- checks if the file has a redirect and gets the content length
local function getFinalUrlAndSize(id, url)
	local request = {
		url = url,
		method = "HEAD", -- this only retrieves the header, which contains the size that we're interested in.
	}
	local success, code, header = https.request(request)
	if success then
		if code == 200 then
			local size = header["content-length"]
			progress_channel:push({id = id, event = {size = tonumber(header["content-length"])}})
			-- we have a valid url and size
			return url, size
		elseif code == 302 then -- check if we already were redirected to prevent infinite redirect loops
			-- url redirected
			local location = header["location"]
			-- get the redirected url size
			return getFinalUrlAndSize(id, location)
		else
			progress_channel:push({id = id, event = {code = code, header = header}})
		end
	else
		-- in case of failure, the error message is stored in the second return value
		progress_channel:push({id = id, event = {finished = true, error = code}})
	end

	-- Failed to get a url and or content length
	return nil
end

while true do
	-- wait for a request to arrive
	local demand = requests_channel:demand()

	if demand == false then break end

	local id, request = demand.id, demand.request

	-- extract the url and output filename
	local url, filename = request.url, request.filename

	-- we need to send two separate requests: one to determine the size
	-- of the thing we are downloading, and another one to actually download
	-- something.

	url, size = getFinalUrlAndSize(id, url)

	-- now we start the actual download
	if url then
		-- this is the sink that will capture the downloaded data.
		local output_sink = love_file_sink(filename)

		-- this time we send an actual GET request.
		-- note also that we use our custom sink to capture the downloaded data.
		local request = {
			url = url,
			sink = progress_sink(id, output_sink),
			method = "GET",
		}

		local success, code, header = https.request(request)

		if success then
			progress_channel:push({id = id, event = {code = code, header = header}})
		else
			-- in case of failure, the error message is stored in the second return value
			progress_channel:push({id = id, event = {error = code}})
		end
	end

end
