local ffi = require("ffi")
local libc = ffi.C
local kernel = ffi.load("Kernel32.dll")
local errno = ffi.errno

ffi.cdef[[
typedef int BOOL;
typedef unsigned long DWORD;
typedef char CHAR;
typedef wchar_t WCHAR;
typedef const wchar_t* LPCWSTR;

typedef unsigned short WORD;

typedef void *PVOID;
typedef PVOID HANDLE;

typedef struct _FILETIME
{
	DWORD dwLowDateTime;
	DWORD dwHighDateTime;
} FILETIME;

typedef struct _WIN32_FIND_DATAW {
  DWORD    dwFileAttributes;
  FILETIME ftCreationTime;
  FILETIME ftLastAccessTime;
  FILETIME ftLastWriteTime;
  DWORD    nFileSizeHigh;
  DWORD    nFileSizeLow;
  DWORD    dwReserved0;
  DWORD    dwReserved1;
  WCHAR    cFileName[260];
  WCHAR    cAlternateFileName[14];
  DWORD    dwFileType;
  DWORD    dwCreatorType;
  WORD     wFinderFlags;
} WIN32_FIND_DATAW, *PWIN32_FIND_DATAW, *LPWIN32_FIND_DATAW;

typedef struct _WIN32_FIND_DATAA {
  DWORD    dwFileAttributes;
  FILETIME ftCreationTime;
  FILETIME ftLastAccessTime;
  FILETIME ftLastWriteTime;
  DWORD    nFileSizeHigh;
  DWORD    nFileSizeLow;
  DWORD    dwReserved0;
  DWORD    dwReserved1;
  CHAR    cFileName[260];
  CHAR    cAlternateFileName[14];
  DWORD    dwFileType;
  DWORD    dwCreatorType;
  WORD     wFinderFlags;
} WIN32_FIND_DATAA, *PWIN32_FIND_DATAA, *LPWIN32_FIND_DATAA;

HANDLE FindFirstFileW(
  LPCWSTR             lpFileName,
  LPWIN32_FIND_DATAW lpFindFileData
);

HANDLE FindFirstFileA(
  LPCSTR             lpFileName,
  LPWIN32_FIND_DATAA lpFindFileData
);

BOOL FindNextFileW(
	HANDLE             hFindFile,
	LPWIN32_FIND_DATAW lpFindFileData
);

BOOL FindNextFileA(
	HANDLE             hFindFile,
	LPWIN32_FIND_DATAA lpFindFileData
);

BOOL FindClose(
  HANDLE hFindFile
);
]]

local windows = {}

local WIN32_FIND_DATAW_PTR = ffi.typeof("WIN32_FIND_DATAW")
local WIN32_FIND_DATAA_PTR = ffi.typeof("WIN32_FIND_DATAA")

function windows.getItems(path)
	local ffd = WIN32_FIND_DATAA_PTR()
	local hFind = kernel.FindFirstFileA(string.format("%s\\*", path), ffd)

	local entries = {}

	repeat
		local name = ffi.string(ffd.cFileName)
		if name ~= "." and name ~= ".." then
			table.insert(entries, name)
		end
	until kernel.FindNextFileA(hFind, ffd) == 0

	kernel.FindClose(hFind)

	return entries
end

return windows