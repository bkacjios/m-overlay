@echo OFF

REM Release name
SET NAME=m-overlay

REM Architecture
REM auto, x64, x86
SET BIT=x64

SET INNO_SETUP_DIR="C:\Program Files (x86)\Inno Setup 6"

SET LOVE_64_DIR="C:\Program Files\LOVE"
SET LOVE_32_DIR="C:\Program Files (x86)\LOVE"

IF "%BIT%"=="x64" (
	if exist %LOVE_64_DIR% SET LOVE_DIR=%LOVE_64_DIR%
)
IF "%BIT%"=="x86" (
	if exist %LOVE_32_DIR% SET LOVE_DIR=%LOVE_32_DIR%
)

if not exist %LOVE_DIR% goto :exit

where /q 7z || ECHO Could not find 7Zip, please download and install: https://www.7-zip.org/download.html and add it to PATH && goto :exit

SET INSTALLER_DIR=.\installer
SET BUILD_DIR=.\build
SET BUILD_OUTPUT_DIR=%BUILD_DIR%\%BIT%
SET SOURCE_DIR=.\source
SET LAUNCHER_DIR=.\launcher
SET RELEASES_DIR=.\releases
SET TOOLS_DIR=.\tools

if not exist %BUILD_DIR% mkdir %BUILD_DIR%
if not exist %BUILD_OUTPUT_DIR% mkdir %BUILD_OUTPUT_DIR%

SET BRANCH=dirty
SET COMMIT=1
SET VERSION=v0.0.0

REM Get GIT commit number
FOR /F "tokens=* USEBACKQ" %%F IN (`git -C %SOURCE_DIR% rev-list --count --first-parent HEAD`) DO (
	SET COMMIT=%%F
)

REM Get latest tag
FOR /F "tokens=* USEBACKQ" %%F IN (`git -C %SOURCE_DIR% describe --tags`) DO (
	echo %%F
	SET VERSION=%%F
)

IF "%VERSION:~0,1%"=="v" (
	echo Stripping 'v' from VERSION
	SET VERSION=%VERSION:~1%
)

if not exist %RELEASES_DIR%\%VERSION% mkdir %RELEASES_DIR%\%VERSION%

echo %VERSION% > %SOURCE_DIR%\version.txt

REM Get GIT branch
FOR /F "tokens=* USEBACKQ" %%F IN (`git -C %SOURCE_DIR% rev-parse --abbrev-ref HEAD`) DO (
	SET BRANCH=%%F
)

SET PATH=%PATH%;%INNO_SETUP_DIR%;%TOOLS_DIR%

SET EXE_NAME=%NAME%-%BIT%.exe
SET EXE_PATH=%BUILD_OUTPUT_DIR%\%EXE_NAME%

SET APPLICATION_LOVE=%BUILD_DIR%\application.love
SET LAUNCHER_LOVE=%BUILD_DIR%\%NAME%-%BIT%-installer.love

echo Zipping files in %SOURCE_DIR% into %APPLICATION_LOVE%

if exist %APPLICATION_LOVE% del %APPLICATION_LOVE%

REM timeout /t 3 /nobreak

7z a -tzip -mx=9 -xr!*.git -xr!*.dll %APPLICATION_LOVE% "%SOURCE_DIR%\*"
7z a -tzip -mx=9 -xr!*.git -xr!*.dll %LAUNCHER_LOVE% "%LAUNCHER_DIR%\*"

copy %APPLICATION_LOVE% %RELEASES_DIR%\%VERSION% /y
copy %LAUNCHER_LOVE% %RELEASES_DIR%\%VERSION% /y

echo Copying LOVE2D binaries and license to %BUILD_OUTPUT_DIR%
copy %LOVE_DIR%\license.txt %BUILD_OUTPUT_DIR%
xcopy /d %LOVE_DIR%\*.dll %BUILD_OUTPUT_DIR% /y
xcopy /d %SOURCE_DIR%\*.dll %BUILD_OUTPUT_DIR% /y
del %BUILD_OUTPUT_DIR%\sqlite3.dll

echo Copying love.exe %BUILD_DIR%
copy /b %LOVE_DIR%\love.exe+,, %BUILD_DIR%

echo Customizing love.exe
rcedit-x64 "%BUILD_DIR%\love.exe" --set-icon "%INSTALLER_DIR%\icon.ico"
rcedit-x64 "%BUILD_DIR%\love.exe" --set-file-version "%VERSION%"
rcedit-x64 "%BUILD_DIR%\love.exe" --set-version-string "FileDescription" "M'Overlay"
rcedit-x64 "%BUILD_DIR%\love.exe" --set-version-string "InternalName" "%NAME%-%BIT%"
rcedit-x64 "%BUILD_DIR%\love.exe" --set-version-string "OriginalFilename" "%EXE_NAME%"

REM We have to merge AFTER rcedit, since rcedit destroys the merged data
echo Merging love.exe + %LAUNCHER_LOVE% into %EXE_PATH%
copy /b "%BUILD_DIR%\love.exe"+%LAUNCHER_LOVE% %EXE_PATH%
REM copy /b "%BUILD_DIR%\love.exe"+%APPLICATION_LOVE% %EXE_PATH%

SET PORTABLE_ZIP="%RELEASES_DIR%\%VERSION%\%NAME%-%BIT%-portable.zip"

REM Remove old zip if it exists
if exist %PORTABLE_ZIP% del %PORTABLE_ZIP%

REM Create a release zip
7z a -tzip -mx=9 %PORTABLE_ZIP% "%BUILD_OUTPUT_DIR%\*"

if exist %INNO_SETUP_DIR% (
	echo Building installer
	iscc release.iss
	move "%RELEASES_DIR%\m-overlay-x64-installer.exe" "%RELEASES_DIR%\%VERSION%"
)

:exit
@PAUSE