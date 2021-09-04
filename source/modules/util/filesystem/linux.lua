local ffi = require("ffi")
local libc = ffi.C
local errno = ffi.errno

ffi.cdef[[
typedef struct {
	ino_t          d_ino;       /* Inode number */
	off_t          d_off;       /* Not an offset; see below */
	unsigned short d_reclen;    /* Length of this record */
	unsigned char  d_type;      /* Type of file; not supported
								  by all filesystem types */
	char           name[256];   /* Null-terminated filename */
} dirent;
typedef struct __dirstream DIR;

char *strerror(int errnum);
DIR *opendir(const char *name);
int closedir(DIR *dirp);
dirent *readdir(DIR *dirp);
]]

local linux = {}

function linux.getItems(path)
	local dir = libc.opendir(path)
	local entries = {}

	if dir ~= nil then
		local entry
		while true do
			entry = libc.readdir(dir)
			if entry == nil then break end -- end of list
			local name = ffi.string(entry.name)
			if name ~= "." and name ~= ".." then
				table.insert(entries, name)
			end
		end
		libc.closedir(dir)
	end

	return entries
end

return linux