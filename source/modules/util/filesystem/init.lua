local filesystem = {
	subsystem = require("util.filesystem." .. jit.os:lower())
}

-- getDirectoryItems fails to get items if the folder is a symlink
-- https://love2d.org/forums/viewtopic.php?p=219899&sid=133d3c486ccbeb05cdcacfe150395ab5#p219899

function filesystem.getDirectoryItems(path)
	local savePath = love.filesystem.getSaveDirectory()
	return filesystem.subsystem.getItems(string.format("%s/%s", savePath, path))
end

return filesystem