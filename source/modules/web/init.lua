local web = {}

local log = require("log")

local REQUESTS = {}
local THREAD_POOL_SIZE = 3

local THREAD = love.thread.newThread("modules/web/thread.lua")

-- these two channels are used to send requests and progress updates back and forth
local requests_channel = love.thread.getChannel("web-requests")
local progress_channel = love.thread.getChannel("web-progress")

-- main request method
function web.request(request, callback)
	for id=1,#REQUESTS+1 do
		-- find a nil table entry
		if REQUESTS[id] == nil then
			-- save our callback with ID as the key
			REQUESTS[id] = callback
			-- push our request to the web-requests thread channel
			requests_channel:push({id=id,request=request})
			break
		end
	end
end

-- helper function for a GET request
function web.get(url, callback)
	local request = {
		method = "GET",
		url = url
	}
	web.request(request, callback)
end

-- helper function for a POST request
function web.post(url, body, headers, callback)
	local request = {
		method = "POST",
		url = url,
		body = body,
		headers = headers
	}
	web.request(request, callback)
end

-- poll the progress channel for updates
function web.update()
	while progress_channel:peek() do
		-- got response from channel
		local pop = progress_channel:pop()
		local id = pop.id
		local callback = REQUESTS[id]
		local succ, err = xpcall(callback, debug.traceback, pop.event)
		if not succ then
			-- calling our callback resulted in an error
			log.error("[WEB] callback error: %s", err)
		end
		REQUESTS[id] = nil
	end
end

function web.close()
	requests_channel:push(false) -- false ends the thread loop
	if THREAD:isRunning() then
		THREAD:wait()
	end
end

return web