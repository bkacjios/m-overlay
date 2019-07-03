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

where /q 7z || ECHO Could not find 7Zip, please download and install: https://www.7-zip.org/download.html && goto :exit

SET INSTALLER_DIR=.\installer
SET BUILD_DIR=.\build
SET BUILD_OUTPUT_DIR=%BUILD_DIR%\%BIT%
SET SOURCE_DIR=.\source
SET RELEASES_DIR=.\releases
SET TOOLS_DIR=.\tools

if not exist %BUILD_DIR% mkdir %BUILD_DIR%
if not exist %RELEASES_DIR% mkdir %RELEASES_DIR%
if not exist %BUILD_OUTPUT_DIR% mkdir %BUILD_OUTPUT_DIR%

SET BRANCH=dirty
SER VERSION=1

REM Get GIT commit number
FOR /F "tokens=* USEBACKQ" %%F IN (`git -C %SOURCE_DIR% rev-list --count --first-parent HEAD`) DO (
	SET VERSION=%%F
)

REM Get GIT branch
FOR /F "tokens=* USEBACKQ" %%F IN (`git -C %SOURCE_DIR% rev-parse --abbrev-ref HEAD`) DO (
	SET BRANCH=%%F
)

SET PATH=%PATH%;%INNO_SETUP_DIR%;%TOOLS_DIR%

SET EXE_NAME=%NAME%-%BIT%.exe
SET EXE_PATH=%BUILD_OUTPUT_DIR%\%EXE_NAME%

SET ZIP=%BUILD_DIR%\%NAME%.love

echo Zipping files in %SOURCE_DIR% into %ZIP%

if exist %ZIP% del %ZIP%
7z a -tzip -mx=9 -xr!*.git -xr!*.dll %ZIP% "%SOURCE_DIR%\*"

echo Copying LOVE2D binaries and license to %BUILD_OUTPUT_DIR%
copy %LOVE_DIR%\license.txt %BUILD_OUTPUT_DIR%
xcopy /d %LOVE_DIR%\*.dll %BUILD_OUTPUT_DIR% /y
xcopy /d %SOURCE_DIR%\*.dll %BUILD_OUTPUT_DIR% /y

echo Copying love.exe %BUILD_DIR%
copy /b %LOVE_DIR%\love.exe+,, %BUILD_DIR%

echo Customizing love.exe
rcedit-x64 "%BUILD_DIR%\love.exe" --set-icon "%INSTALLER_DIR%\icon.ico"
rcedit-x64 "%BUILD_DIR%\love.exe" --set-version-string "FileDescription" "M'Overlay"
rcedit-x64 "%BUILD_DIR%\love.exe" --set-version-string "FileVersion" "%VERSION%"
rcedit-x64 "%BUILD_DIR%\love.exe" --set-version-string "InternalName" "%NAME%-%BIT%"
rcedit-x64 "%BUILD_DIR%\love.exe" --set-version-string "OriginalFilename" "%EXE_NAME%"

REM We have to merge AFTER rcedit, since rcedit destroys the merged data
echo Merging love.exe + %ZIP% into %EXE_PATH%
copy /b "%BUILD_DIR%\love.exe"+%ZIP% %EXE_PATH%

SET ZIP="%RELEASES_DIR%\%NAME%-%BIT% (%BRANCH%-%VERSION%).zip"

REM Remove old zip if it exists
if exist %ZIP% del %ZIP%

REM Create a release zip
7z a -tzip -mx=9 %ZIP% "%BUILD_OUTPUT_DIR%\*"

if exist %INNO_SETUP_DIR% (
	echo Building installer
	iscc release.iss
)

:exit
@PAUSE