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
local errno = ffi.errno

local lshift = bit.lshift
local rshift = bit.rshift
local bswap = bit.bswap
local band = bit.band
local bor = bit.bor

local libc = ffi.C

cdef [[
static const int MAXCOMLEN = 16;

char *strerror(int errnum);

typedef struct task *task_t;
typedef task_t task_port_t;

typedef signed int pid_t;
typedef unsigned int uid_t;
typedef unsigned int gid_t;
typedef unsigned long uintptr_t;
typedef unsigned long long u_int64_t;

typedef uint32_t natural_t;
typedef uint32_t mach_port_t;
typedef uint64_t mach_vm_address_t;
typedef uint64_t mach_vm_size_t;
typedef mach_port_t vm_map_read_t;
typedef natural_t mach_msg_type_number_t;
typedef natural_t mach_port_t;
typedef int vm_region_flavor_t;
typedef int *vm_region_info_t;

typedef struct {
	pid_t pid;
	task_t task;
	unsigned __int64  dolphin_base_addr;
	unsigned __int64  dolphin_addr_size;
} MEMORY_STRUCT;

typedef struct proc_bsdinfo {
	uint32_t		pbi_flags;		/* 64bit; emulated etc */
	uint32_t		pbi_status;
	uint32_t		pbi_xstatus;
	uint32_t		pbi_pid;
	uint32_t		pbi_ppid;
	uid_t			pbi_uid;
	gid_t			pbi_gid;
	uid_t			pbi_ruid;
	gid_t			pbi_rgid;
	uid_t			pbi_svuid;
	gid_t			pbi_svgid;
	uint32_t		rfu_1;			/* reserved */
	char			pbi_comm[MAXCOMLEN];
	char			pbi_name[2*MAXCOMLEN];	/* empty if no name is registered */
	uint32_t		pbi_nfiles;
	uint32_t		pbi_pgid;
	uint32_t		pbi_pjobc;
	uint32_t		e_tdev;			/* controlling tty dev */
	uint32_t		e_tpgid;		/* tty process group id */
	int32_t			pbi_nice;
	uint64_t		pbi_start_tvsec;
	uint64_t		pbi_start_tvusec;
} proc_bsdinfo;

typedef struct proc_bsdshortinfo {
        uint32_t                pbsi_pid;		/* process id */
        uint32_t                pbsi_ppid;		/* process parent id */
        uint32_t                pbsi_pgid;		/* process perp id */
        uint32_t                pbsi_status;		/* p_stat value, SZOMB, SRUN, etc */
        char                    pbsi_comm[MAXCOMLEN];	/* upto 16 characters of process name */
        uint32_t                pbsi_flags;		/* 64bit; emulated etc */
        uid_t                   pbsi_uid;		/* current uid on process */
        gid_t                   pbsi_gid;		/* current gid on process */
        uid_t                   pbsi_ruid;		/* current ruid on process */
        gid_t                   pbsi_rgid;		/* current tgid on process */
        uid_t                   pbsi_svuid;		/* current svuid on process */
        gid_t                   pbsi_svgid;		/* current svgid on process */
        uint32_t                pbsi_rfu;		/* reserved for future use*/
} proc_bsdshortinfo;

int proc_listpids(uint32_t type, uint32_t typeinfo, void *buffer, int buffersize); // , int32_t * retval
int proc_pidinfo(int pid, int flavor, uint64_t arg, void* buffer, uint32_t buffersize); // , int32_t * retval
int vm_read(uint32_t target_task, uintptr_t address, uintptr_t size, uintptr_t *data, uint32_t * dataCnt);

pid_t getpgid(pid_t pid);

int task_for_pid(mach_port_t task, pid_t pid, task_port_t *target);
mach_port_t mach_task_self(void);

int mach_vm_region(vm_map_read_t target_task, mach_vm_address_t *address, mach_vm_size_t *size, vm_region_flavor_t flavor, vm_region_info_t info, mach_msg_type_number_t *infoCnt, mach_port_t *object_name);
]]

local PROC_ALL_PIDS = 1
local PROC_PIDTBSDINFO = 3

local MEMORY = {}
MEMORY.__index = MEMORY
MEMORY.init = metatype("MEMORY_STRUCT", MEMORY)
MEMORY.task = new("task_t[1]")

function MEMORY:hasPermissions()
	return true
end

local valid_process_names = {
	["Dolphin"] = true,
	["Slippi Dolphin"] = true,
	["DolphinWx"] = true,
	["DolphinQt2"] = true,
}

local PROC_BSDINFO_PTR = typeof("proc_bsdinfo[1]")

function MEMORY:findprocess()
	if self:hasProcess() then return false end

	local num_pids = libc.proc_listpids(PROC_ALL_PIDS, 0, nil, 0)
	local pids = new("pid_t[?]", num_pids)
	libc.proc_listpids(PROC_ALL_PIDS, 0, pids, sizeof(pids))

	local proc = PROC_BSDINFO_PTR()[0]

	for i=0, num_pids do
		local pid = pids[i]
		if pid ~= 0 then
			local st = libc.proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, proc, sizeof(PROC_BSDINFO_PTR))
			if valid_process_names[string(proc.pbi_name)] then
					self.pid = pid
					log.debug("Found dolphin-emu process: /proc/%d", self.pid)
				break
			end
		end
	end

	return self:hasProcess()
end

function MEMORY:isProcessActive()
	if self.pid then
		return libc.getpgid(self.pid) >= 0
	end
	return false
end

function MEMORY:hasProcess()
	return self.pid ~= 0
end

function MEMORY:clearGamecubeRAMOffset()
	self.dolphin_base_addr = 0
end

function MEMORY:hasGamecubeRAMOffset()
	return self.dolphin_base_addr ~= 0
end

function MEMORY:getGamecubeRAMOffset()
	return tonumber(self.dolphin_base_addr)
end

function MEMORY:getGamecubeRAMSize()
	return tonumber(self.dolphin_addr_size)
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
		local err = libc.task_for_pid(libc.mach_task_self(), self.pid, self.task)

		if error ~= 0 then
			return false
		end

		-- while libc.mach_vm_region(self.task, regionAddr, size, VM_REGION_EXTENDED_INFO, regInfo, cnt, obj) == 0 do
			-- TODO: Scan all memory regions..
		-- end
	end

	return false
end

function MEMORY:read(addr, output, size)
	return false
end

function MEMORY:write(addr, input, size)
	return false
end

return MEMORY
