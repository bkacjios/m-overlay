local downloader = {}

local REQUESTS = {}

local THREAD = love.thread.newThread("downloader/thread.lua")
THREAD:start()

-- these two channels are used to send requests and progress updates back and forth
local requests_channel = love.thread.getChannel("dl-requests")
local progress_channel = love.thread.getChannel("dl-progress")

function downloader.request(request, callback)
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

function downloader.download(url, filename, callback)
	local request = {
		url = url,
		filename = filename
	}
	downloader.request(request, callback)
end

-- poll the progress channel for updates
function downloader.update()
	while progress_channel:peek() do
		-- got response from channel
		local pop = progress_channel:pop()
		local id = pop.id
		local callback = REQUESTS[id]
		if pop.event and pop.event.code then
			-- we got a status code, delete the callback
			REQUESTS[id] = nil
		end
		local succ, err = xpcall(callback, debug.traceback, pop.event)
		if not succ then
			-- calling our callback resulted in an error
			print(string.format("[DOWNLOADER] callback error: %s", err))
		end
	end
end

function downloader.close()
	requests_channel:push(false)
end

return downloader