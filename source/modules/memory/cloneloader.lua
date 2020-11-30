local loader = {}

local log = require("log")

local notification = require("notification")
local configdir = love.filesystem.getSaveDirectory()

function loader.loadFile(file, clonesTbl)
	if file and love.filesystem.getInfo(file, "file") then
		log.info("[CLONES] Load: %s/%s", configdir, file)
		
		local status, chunk = pcall(love.filesystem.load, file)

		if not status then
			-- Failed loading chunk, chunk is an error string
			log.error(chunk)
			notification.error(chunk)
		elseif chunk then
			-- Create a sandboxed lua environment
			local env = {}
			env._G = env

			-- Set the loaded chunk inside the sandbox
			setfenv(chunk, env)

			local status, custom_clones = pcall(chunk)
			if not status then
				-- Failed calling the chunk, custom_clones is an error string
				log.error(custom_clones)
				notification.error(custom_clones)
			else
				local num_clones = 0
				for clone_id, clones in pairs(custom_clones) do
					if type(clones) == "table" then
						clonesTbl[clone_id] = {}
						for version, info in pairs(clones) do
							if info.id and info.version then
								num_clones = num_clones + 1
								log.debug("[CLONES] %s[%d] = %s[%d]", clone_id, version, info.id, info.version)
								clonesTbl[clone_id][version] = info
							end
						end
					end
				end
				log.info("[CLONES] Loaded %d clones from %s", num_clones, file)
				notification.coloredMessage(("Loaded %d clones from %s"):format(num_clones, file))
			end
		end
	end
end

return loader