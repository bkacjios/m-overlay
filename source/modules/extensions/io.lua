function io.copy(pathFrom, pathTo)
	local fileFrom, err = io.open(pathFrom, "rb")
	if not fileFrom then return error(err) end

	local fileTo, err = io.open(pathTo, "wb")
	if not fileTo then return error(err) end

	fileTo:write(fileFrom:read("*all"))

	fileFrom:close()
	fileTo:close()
end