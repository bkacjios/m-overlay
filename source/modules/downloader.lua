-- This code is dedicated to the public domain. 2017, Moritz Neikes

local http = require("socket.https")

-- these two channels are used to send requests and progress updates back
-- and forth
local requests_channel = love.thread.getChannel("dl-requests")
local progress_channel = love.thread.getChannel("dl-progress")

-- this is a re-implementation of the ltn12 file sink that uses love.filesystem
-- instead of Lua's io functions
local function love_file_sink(filename)
  -- create enclosing directories
  local dirname = string.gmatch(filename, "(.*/)([^/]*)")()
  if dirname then
    local dir_ok = love.filesystem.createDirectory(dirname)
    if not dir_ok then error("Could not create directory "..dirname) end
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

-- this is a special "sink" that sends progress updates whenever it receives
-- a new chunk of data.
-- See http://lua-users.org/wiki/FiltersSourcesAndSinks for a bit of documentation
local function progress_sink(output_sink)
  return function(chunk, err)
    if chunk then
      progress_channel:push({chunk = #chunk})
    else

      -- if chunk is nil, then the download is finished, or we have an error
      if err then
        progress_channel:push({error = err})
      else
        progress_channel:push({finished = true})
      end

    end

    -- forward chunk and err to the underlying sink
    return output_sink(chunk, err)
  end
end

while true do

  -- wait for a request to arrive
  local request = requests_channel:demand()

  -- extract the url and output filename
  local url, filename = request.url, request.filename

  -- we need to send two separate requests: one to determine the size
  -- of the thing we are downloading, and another one to actually download
  -- something.

  local proceed
  do
    local request = {
      url = url,
      method = "HEAD", -- this only retrieves the header, which contains the
                       -- size that we're interested in.
    }
    local success, status_code, response_header = http.request(request)
    if success then
      if status_code == 200 then
        file_size = response_header["content-length"]
        progress_channel:push({file_size = tonumber(response_header["content-length"])})
        -- we only proceed to sending a second request when this worked fine.
        proceed = true
      else
        progress_channel:push({error = string.format("Received status code %d",
                                                     tonumber(status_code))})
      end
    else
      -- in case of failure, the error message is stored in the second return value
      local err = status_code
      progress_channel:push({error = err})
    end
  end

  -- now we start the actual download
  if proceed then
    -- this is the sink that will capture the downloaded data.
    local output_sink = love_file_sink(filename)

    -- this time we send an actual GET request.
    -- note also that we use our custom sink to capture the downloaded data.
    local request = {
      url = url,
      sink = progress_sink(output_sink),
      method = "GET",
    }

    local success, status_code = http.request(request)

    if success then
      if status_code ~= 200 then
        progress_channel:push({error = string.format("Received status code %d",
                                                     tonumber(status_code))})
      end
    else
      -- in case of failure, the error message is stored in the second return value
      local err = status_code
      progress_channel:push({error = err})
    end
  end

end
