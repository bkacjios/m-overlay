if jit.os ~= "Windows" then return end

local ffi = require("ffi")
local kernel = ffi.load("Kernel32.dll")

local INVALID_HANDLE_VALUE = -1

local STD_INPUT_HANDLE  = -10
local STD_OUTPUT_HANDLE = -11
local STD_ERROR_HANDLE  = -12

local ENABLE_PROCESSED_OUTPUT = 0x0001
local ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004

local ATTACH_PARENT_PROCESS = 0x1

local ERROR_ACCESS_DENIED = 0x5

ffi.cdef [[
// Windows types
typedef int BOOL;
typedef char CHAR;
typedef unsigned long DWORD;
typedef void *PVOID;
typedef PVOID HANDLE;
typedef unsigned short WORD;
typedef const CHAR *LPCSTR;
typedef LPCSTR LPCTSTR;
typedef DWORD *LPDWORD;

BOOL AttachConsole(
  DWORD dwProcessId
);

BOOL AllocConsole(void);
BOOL FreeConsole(void);

HANDLE GetStdHandle(
  DWORD nStdHandle
);

BOOL SetConsoleTextAttribute(
  HANDLE hConsoleOutput,
  WORD   wAttributes
);

BOOL SetConsoleMode(
  HANDLE hConsoleHandle,
  DWORD  dwMode
);

BOOL GetConsoleMode(
  HANDLE  hConsoleHandle,
  LPDWORD lpMode
);

BOOL SetConsoleTitleA(
  LPCTSTR lpConsoleTitle
);

DWORD GetLastError();

void *freopen(
   const char *path,
   const char *mode,
   void *stream
);

int fclose(void *stream);
]]

function love.setConsoleTitle(title)
	kernel.SetConsoleTitleA(title)
end

function love.enableConsoleFlag(flag)
	local mode = ffi.new("DWORD[1]")

	local hStdOut = kernel.GetStdHandle(STD_OUTPUT_HANDLE)

	if (hStdOut == INVALID_HANDLE_VALUE) then
		return false, "could not get stdhandle for console."
	end

	kernel.GetConsoleMode(hStdOut, mode)
	kernel.SetConsoleMode(hStdOut, bit.bor(mode[0], flag))
	return true
end

function love.enableConsoleColors()
	love.enableConsoleFlag(ENABLE_VIRTUAL_TERMINAL_PROCESSING)
end

function love.isConsoleOpened()
	kernel.AttachConsole(ATTACH_PARENT_PROCESS)
	return kernel.GetLastError() == ERROR_ACCESS_DENIED
end

function love.openConsole()
	if kernel.AttachConsole(ATTACH_PARENT_PROCESS) == 0 then
		local winerr = kernel.GetLastError()

		if winerr == ERROR_ACCESS_DENIED then
			return false, "console is already open."
		end

		if not kernel.AllocConsole() then
			return false, "could not create console."
		end
	end

	local fp = ffi.C.freopen("CONOUT$", "w", io.stdout)

	if fp == nil then
		return false, "console redirection of stdout failed."
	end

	local fp = ffi.C.freopen("CONOUT$", "r", io.stdin)

	if fp == nil then
		return false, "console redirection of stdin failed."
	end

	local fp = ffi.C.freopen("CONOUT$", "w", io.stderr)

	if fp == nil then
		return false, "console redirection of stderr failed."
	end

	local hStdOut = kernel.GetStdHandle(STD_OUTPUT_HANDLE)

	if (hStdOut == INVALID_HANDLE_VALUE) then
		return false, "could not get stdhandle for console."
	end

	--local MAX_CONSOLE_LINES = 5000
	love.console(true)
	return true
end

function love.closeConsole()
	ffi.C.fclose(io.stdout)
	ffi.C.fclose(io.stdin)
	ffi.C.fclose(io.stderr)
	kernel.FreeConsole()
	love.console(false)
end

function love.console(opened)
	if opened then
		love.setConsoleTitle("M'Overlay Console")
		love.enableConsoleColors()
	end
end

if love.isConsoleOpened() then
	love.console(true)
end