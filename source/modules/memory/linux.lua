local ffi = require("ffi")
local log = require("log")

local format = string.format
local sub = string.sub

local cast = ffi.cast
local cdef = ffi.cdef
local load = ffi.load
local metatype = ffi.metatype
local new = ffi.new
local typeof = ffi.typeof
local sizeof = ffi.sizeof
local string = ffi.string

local lshift = bit.lshift
local rshift = bit.rshift
local bswap = bit.bswap
local band = bit.band
local bor = bit.bor

local libc = load("libc.so")

cdef [[
typedef signed int pid_t;

typedef struct {
	pid_t pid;
	unsigned __int64  dolphin_base_addr;
} MEMORY_STRUCT;

typedef struct {
	void *iov_base;	/* pointer to start of buffer */
	size_t iov_len;	/* size of buffer in bytes */
} iovec;

ssize_t process_vm_readv(pid_t pid,
                         iovec *local_iov,
                         unsigned long liovcnt,
                         iovec *remote_iov,
                         unsigned long riovcnt,
                         unsigned long flags);

ssize_t process_vm_writev(pid_t pid,
                          iovec *local_iov,
                          unsigned long liovcnt,
                          iovec *remote_iov,
                          unsigned long riovcnt,
                          unsigned long flags);
]]

local MEMORY = {}
MEMORY.__index = MEMORY
MEMORY.init = metatype("MEMORY_STRUCT", MEMORY)

local lfs = require("lfs")

local function NOTWITHINMEMRANGE(addr)
	return addr < 0x80000000 or addr > 0x81800000
end

function MEMORY:findprocess(name)
	if self:hasProcess() then return false end

	for pid in lfs.dir("/proc") do
		if pid ~= "." and pid ~= ".." then
			local attr = lfs.attributes("/proc/" .. pid)
			if attr and attr.mode == "directory" then
				local f = io.open("/proc/" .. pid .. "/comm")
				if f then
					local line = f:read("*line")
					if line == "dolphin-emu" or line == "dolphin-emu-qt2" or line == "dolphin-emu-wx" then
						self.pid = tonumber(pid)
					end
					f:close()
				end
			end
		end
	end

	return self:hasProcess()
end

function MEMORY:isProcessActive()
	if self.pid ~= 0 then
		--local status = new("DWORD[1]")
		--kernel.GetExitCodeProcess(self.pid, status)
		--return status[0] == STILL_ACTIVE
		return true
	end
	return false
end

function MEMORY:hasProcess()
	return self.pid ~= 0
end

function MEMORY:hasGamecubeRAMOffset()
	return self.dolphin_base_addr ~= 0
end

function MEMORY:close()
	if self:hasProcess() then
		self.pid = 0
		self.dolphin_base_addr = 0
	end
end

function MEMORY:__gc()
	self:close()
end

function MEMORY:findGamecubeRAMOffset()
	if self:hasProcess() then
		local maps = "/proc/" .. self.pid .. "/maps"
		local attr = lfs.attributes(maps)
		if attr.mode == "file" then
			local f = io.open(maps)
			if f then
				local line
				repeat
					line = f:read("*line")
					if not line then break end
					if #line > 74 then
						if sub(line, 74, 74 + 18) == "/dev/shm/dolphinmem" or sub(line, 74, 74 + 19) == "/dev/shm/dolphin-emu" then
							local startAddr = tonumber(sub(line, 1, 12), 16)
							local endAddr = tonumber(sub(line, 14, 14 + 12), 16)
							local size = endAddr - startAddr
							if size == 0x2000000 then
								self.dolphin_base_addr = startAddr
								return true
							end
						end
					end
				until false
				f:close()
			end
		end
	end

	return false
end

local function read(mem, addr, output, size)
	local localvec = new("iovec[1]")
	local remotevec = new("iovec[1]")

	local ramaddr = mem.dolphin_base_addr + (addr % 0x80000000)	

	localvec[0].iov_base = output
	localvec[0].iov_len = size

	remotevec[0].iov_base = ffi.cast("void*", ramaddr)
	remotevec[0].iov_len = size

	local read = libc.process_vm_readv(mem.pid, localvec, 1, remotevec, 1, 0)

	if read == size then
		return true
	else
		mem:close()
		return false
	end
end

function MEMORY:readByte(addr)
	if not self:hasProcess() then return 0 end
	local output = new("int8_t[1]")
	read(self, addr, output, sizeof(output))
	return output[0]
end

function MEMORY:readBool(addr)
	return self:readByte(addr) == 1
end

function MEMORY:readUByte(addr)
	if not self:hasProcess() then return 0 end
	local output = new("uint8_t[1]")
	read(self, addr, output, sizeof(output))
	return output[0]
end

local function bswap16(n)
	return bor(rshift(n, 8), lshift(band(n, 0xFF), 8))
end

function MEMORY:readShort(addr)
	if not self:hasProcess() then return 0 end
	local output = new("int16_t[1]")
	read(self, addr, output, sizeof(output))
	return bswap16(output[0])
end

function MEMORY:readUShort(addr)
	if not self:hasProcess() then return 0 end
	local output = new("uint16_t[1]")
	read(self, addr, output, sizeof(output))
	return bswap16(output[0])
end

local flatconversion = ffi.new("union { uint32_t i; float f; }")

function MEMORY:readFloat(addr)
	if not self:hasProcess() then return 0 end
	local output = new("uint32_t[1]")
	read(self, addr, output, sizeof(output))
	flatconversion.i = bswap(output[0])
	return flatconversion.f
end

function MEMORY:readInt(addr)
	if not self:hasProcess() then return 0 end
	local output = new("int32_t[1]")
	read(self, addr, output, sizeof(output))
	return bswap(output[0])
end

function MEMORY:readUInt(addr)
	if not self:hasProcess() then return 0 end
	local output = new("uint32_t[1]")
	read(self, addr, output, sizeof(output))
	return bswap(output[0])
end

function MEMORY:read(addr, len)
	if not self:hasProcess() then return "" end
	local output = new("unsigned char[?]", len)
	read(self, addr, output, sizeof(output))
	return string(output, sizeof(output))
end

return MEMORY