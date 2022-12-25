local https = require("https")
--local http = require("socket.http")

local ltn12 = require("ltn12")

-- these two channels are used to send requests and progress updates back and forth
local requests_channel = love.thread.getChannel("web-requests")
local progress_channel = love.thread.getChannel("web-progress")

while true do
	-- wait for a request to arrive
	local demand = requests_channel:demand()

	if demand == false then break end

	local id, request = demand.id, demand.request

	-- create a table to store the results
	local result_table = {}
	request.sink = ltn12.sink.table(result_table)

	if request.body then
		request.source = ltn12.source.string(request.body)
	end

	-- Get code, and header response
	local status, code, header = https.request(request)

	if status then
		-- request was successful
		progress_channel:push({id=id, event={success=true, response=table.concat(result_table), code=code, header=header}})
	else
		-- in case of failure, the error message is stored in the second return value
		progress_channel:push({id=id, event={success=false, error = code}})
	end
end