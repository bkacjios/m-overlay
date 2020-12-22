local ffi = require("ffi")
local log = require("log")

local format = string.format

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

local kernel = load("Kernel32.dll")
local psapi = load("Psapi.dll")

local libc = ffi.C

cdef [[
// Stupid Windows typenames..

//#define MAX_PATH 260

typedef int BOOL;
typedef unsigned long DWORD;
typedef long LONG;

typedef void *PVOID;
typedef PVOID HANDLE;

typedef void *LPVOID;
typedef const void *LPCVOID;

typedef DWORD *LPDWORD;

typedef char CHAR;

typedef unsigned __int64 ULONG_PTR; // 64-bit
// typedef unsigned long ULONG_PTR; // 32-bit

typedef ULONG_PTR SIZE_T;

typedef struct {
	HANDLE process_handle;
	ULONG_PTR dolphin_base_addr;
	ULONG_PTR dolphin_addr_size;
} MEMORY_STRUCT;

typedef struct tagPROCESSENTRY32 {
	DWORD dwSize;
	DWORD cntUsage;
	DWORD th32ProcessID;
	ULONG_PTR th32DefaultHeapID; // DWORD on 32-bit
	DWORD th32ModuleID;
	DWORD cntThreads;
	DWORD th32ParentProcessID;
	LONG pcPriClassBase;
	DWORD dwFlags;
	CHAR  szExeFile[260];
} PROCESSENTRY32,*PPROCESSENTRY32,*LPPROCESSENTRY32;

HANDLE CreateToolhelp32Snapshot(
	DWORD dwFlags,
	DWORD th32ProcessID
);

BOOL Process32First(
	HANDLE           hSnapshot,
	LPPROCESSENTRY32 lppe
);

BOOL Process32Next(
	HANDLE           hSnapshot,
	LPPROCESSENTRY32 lppe
);

HANDLE OpenProcess(
	DWORD dwDesiredAccess,
	BOOL  bInheritHandle,
	DWORD dwProcessId
);

BOOL ReadProcessMemory(
	HANDLE  hProcess,
	LPCVOID lpBaseAddress,
	LPVOID  lpBuffer,
	SIZE_T  nSize,
	SIZE_T  *lpNumberOfBytesRead
);

BOOL WriteProcessMemory(
	HANDLE  hProcess,
	LPVOID  lpBaseAddress,
	LPCVOID lpBuffer,
	SIZE_T  nSize,
	SIZE_T  *lpNumberOfBytesWritten
);

BOOL CloseHandle(
	HANDLE hObject
);

typedef struct _MEMORY_BASIC_INFORMATION {
	PVOID  BaseAddress;
	PVOID  AllocationBase;
	DWORD  AllocationProtect;
	SIZE_T RegionSize;
	DWORD  State;
	DWORD  Protect;
	DWORD  Type;
} MEMORY_BASIC_INFORMATION, *PMEMORY_BASIC_INFORMATION;

typedef union _PSAPI_WORKING_SET_EX_BLOCK {
	ULONG_PTR Flags;
	/*union {
		struct {
			ULONG_PTR Valid : 1;
			ULONG_PTR ShareCount : 3;
			ULONG_PTR Win32Protection : 11;
			ULONG_PTR Shared : 1;
			ULONG_PTR Node : 6;
			ULONG_PTR Locked : 1;
			ULONG_PTR LargePage : 1;
			ULONG_PTR Reserved : 7;
			ULONG_PTR Bad : 1;
			ULONG_PTR ReservedUlong : 32;
		};
		struct {
			ULONG_PTR Valid : 1;
			ULONG_PTR Reserved0 : 14;
			ULONG_PTR Shared : 1;
			ULONG_PTR Reserved1 : 15;
			ULONG_PTR Bad : 1;
			ULONG_PTR ReservedUlong : 32;
		} Invalid;
	};*/
} PSAPI_WORKING_SET_EX_BLOCK, *PPSAPI_WORKING_SET_EX_BLOCK;

typedef struct _PSAPI_WORKING_SET_EX_INFORMATION {
	PVOID                      VirtualAddress;
	PSAPI_WORKING_SET_EX_BLOCK VirtualAttributes;
} PSAPI_WORKING_SET_EX_INFORMATION, *PPSAPI_WORKING_SET_EX_INFORMATION;

SIZE_T VirtualQueryEx(
	HANDLE                    hProcess,
	LPCVOID                   lpAddress,
	PMEMORY_BASIC_INFORMATION lpBuffer,
	SIZE_T                    dwLength
);

BOOL QueryWorkingSetEx(
	HANDLE hProcess,
	PVOID  pv,
	DWORD  cb
);

BOOL GetExitCodeProcess(
	HANDLE  hProcess,
	LPDWORD lpExitCode
);

DWORD WaitForSingleObject(
	HANDLE hHandle,
	DWORD  dwMilliseconds
);

DWORD GetLastError();
]]

local MEMORY = {}
MEMORY.__index = MEMORY
MEMORY.init = metatype("MEMORY_STRUCT", MEMORY)

local TH32CS_SNAPPROCESS = 0x02

local PROCESS_QUERY_INFORMATION = 0x0400
local PROCESS_VM_OPERATION = 0x0008
local PROCESS_VM_READ = 0x0010
local PROCESS_VM_WRITE = 0x0020

local MEM_MAPPED = 0x40000

local STILL_ACTIVE = 259

local function NOTWITHINMEMRANGE(addr)
	return addr < 0x80000000 or addr > 0x81800000
end

local PROCESSENTRY32_PTR = typeof("PROCESSENTRY32[1]")
local MEMORY_BASIC_INFORMATION_PTR = typeof("MEMORY_BASIC_INFORMATION[1]")
local PSAPI_WORKING_SET_EX_INFORMATION_PTR = typeof("PSAPI_WORKING_SET_EX_INFORMATION[1]")

function MEMORY:hasPermissions()
	-- Windows doesn't need any special permissions to read memory from another process
	return true
end

local valid_process_names = {
	["Dolphin.exe"] = true,
	["Slippi Dolphin.exe"] = true,
	["DolphinWx.exe"] = true,
	["DolphinQt2.exe"] = true,
}

function MEMORY:findprocess()
	if self:hasProcess() then return false end

	local handle
	local snapshot = kernel.CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0) -- Create the snapshot

	local pe32 = PROCESSENTRY32_PTR()[0] -- Will store the info about the process
	pe32.dwSize = sizeof(pe32)

	repeat
		local name = string(pe32.szExeFile)
		if valid_process_names[name] then
			local handle = kernel.OpenProcess(PROCESS_VM_OPERATION + PROCESS_VM_READ + PROCESS_QUERY_INFORMATION, false, pe32.th32ProcessID)

			local status = new("DWORD[1]")
			-- Check if the process is active, we don't want to rehook the closing application
			if handle ~= nil and kernel.GetExitCodeProcess(handle, status) and status[0] == STILL_ACTIVE then
				-- We have an active process that matches, let's use it
				self.process_handle = handle
				break
			elseif handle then
				-- Dolphin is closing.. ignore and close the handle..
				kernel.CloseHandle(handle)
			end
		end
	until kernel.Process32Next(snapshot, pe32) == 0
	
	kernel.CloseHandle(snapshot)

	return self:hasProcess()
end

function MEMORY:isProcessActive()
	local status = new("DWORD[1]")
	return self.process_handle ~= nil and kernel.GetExitCodeProcess(self.process_handle, status) and status[0] == STILL_ACTIVE
end

function MEMORY:hasProcess()
	return self.process_handle ~= nil
end

function MEMORY:clearGamecubeRAMOffset()
	self.dolphin_base_addr = nil
end

function MEMORY:hasGamecubeRAMOffset()
	return self.dolphin_base_addr ~= nil
end

function MEMORY:getGamecubeRAMOffset()
	return tonumber(self.dolphin_base_addr)
end

function MEMORY:getGamecubeRAMSize()
	return tonumber(self.dolphin_addr_size)
end

function MEMORY:close()
	if self:hasProcess() then
		kernel.CloseHandle(self.process_handle)
		self.process_handle = nil
		self.dolphin_base_addr = nil
	end
end

function MEMORY:__gc()
	self:close()
end

function MEMORY:findGamecubeRAMOffset()
	local info = MEMORY_BASIC_INFORMATION_PTR()[0]

	local p = new("unsigned char*[1]", nil)[0]

	while kernel.VirtualQueryEx(self.process_handle, p, info, sizeof(info)) == sizeof(info) do
		p = p + info.RegionSize

		if (info.RegionSize >= 0x2000000 and info.Type == MEM_MAPPED) then
			local wsinfo = PSAPI_WORKING_SET_EX_INFORMATION_PTR()[0]
			wsinfo.VirtualAddress = info.BaseAddress

			if psapi.QueryWorkingSetEx(self.process_handle, wsinfo, sizeof(wsinfo)) == 1 then
				local flags = tonumber(wsinfo.VirtualAttributes.Flags)

				if band(flags, lshift(1, 0)) == 1 then -- Check if the Valid flag is set
					--log.debug("%08X %x", tonumber(cast("ULONG_PTR", info.BaseAddress)), tonumber(cast("ULONG_PTR", info.RegionSize)))
					self.dolphin_base_addr = cast("ULONG_PTR", info.BaseAddress)
					self.dolphin_addr_size = cast("ULONG_PTR", info.RegionSize)
					return true
				end
			end
		end
	end

	return false
end

local GC_RAM_START = cast("uint32_t", 0x80000000)
local GC_RAM_END = cast("uint32_t", 0x81800000)
local WII_RAM_START = cast("uint32_t", 0x90000000)
local WII_RAM_END = cast("uint32_t", 0x94000000)

local WII_RAM_LOCAL_START = cast("uint32_t", 0x02000000)

local CAST_ADDR = ffi.new("uint32_t", 0x00000000)

function MEMORY:read(addr, output, size)
	if not self:hasProcess() or not self:hasGamecubeRAMOffset() then return false end
	local read = new("SIZE_T[1]") -- How many bytes are read from memory

	CAST_ADDR = cast("uint32_t", addr)

	if CAST_ADDR >= WII_RAM_START and CAST_ADDR <= WII_RAM_END then
		CAST_ADDR = WII_RAM_LOCAL_START + (CAST_ADDR % WII_RAM_START)
	elseif CAST_ADDR >= GC_RAM_START and CAST_ADDR <= GC_RAM_END then
		CAST_ADDR = (CAST_ADDR % GC_RAM_START)
	else
		log.warn("[MEMORY] Attempt to read from invalid address %08X", tonumber(CAST_ADDR))
		return false
	end

	local success = kernel.ReadProcessMemory(self.process_handle, ffi.cast("LPCVOID", self.dolphin_base_addr + CAST_ADDR), output, size, read)
	if not success then
		log.debug("[MEMORY] Failed reading from address [%08X] ERROR #%d", CAST_ADDR, tonumber(kernel.GetLastError()))
	--else
	--	log.debug("[MEMORY] read 0x%X size 0x%X bytes from 0x%08X = %q", tonumber(read[0]), size, tonumber(CAST_ADDR), tohex(ffi.string(output, read[0])))
	end
	return success and read[0] == size
end

function MEMORY:write(addr, input, size)
	if not self:hasProcess() or not self:hasGamecubeRAMOffset() then return false end
	local written = new("SIZE_T[1]") -- How many bytes are written to memory
	local success = kernel.WriteProcessMemory(self.process_handle, ffi.cast("LPVOID", self.dolphin_base_addr + (addr % 0x80000000)), input, size, written)
	if not success then
		log.debug("[MEMORY] Failed writing to address [%08X = %08X] ERROR #%d", addr, tonumber(input), tonumber(kernel.GetLastError()))
	end
	return success and written[0] == size
end

return MEMORY