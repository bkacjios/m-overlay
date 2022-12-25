; -- 64Bit.iss --
; Demonstrates installation of a program built for the x64 (a.k.a. AMD64)
; architecture.
; To successfully run this installation and the program it installs,
; you must have a "x64" edition of Windows.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

[Setup]
#define AppName "M'Overlay"
;#define AppMajor
;#define AppMinor
;#define AppRevision
;#define AppBuild
;#define AppVersion GetVersionComponents("build/x64/m-overlay-x64.exe", AppMajor, AppMinor, AppRevision, AppBuild)
;#define AppVersion Str(AppMajor) + "." + Str(AppMinor) + "." + Str(AppRevision)
#define AppVersion 2.1.0
PrivilegesRequired=lowest
DisableWelcomePage=no
AppName={#AppName}
AppId={#AppName}
AppVersion={#AppVersion}
AppPublisher=Bkacjios
AppPublisherURL=https://github.com/bkacjios
AppUpdatesURL=https://github.com/bkacjios/m-overlay/releases
AppSupportURL=https://github.com/bkacjios/m-overlay/issues
WizardStyle=modern
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
UninstallDisplayIcon={app}\m-overlay-x64.exe
SetupIconFile=installer/icon.ico
WizardImageFile=installer/wizardbanner.bmp
WizardSmallImageFile=installer/wizard.bmp
Compression=lzma2
SolidCompression=yes
OutputDir=./releases
OutputBaseFilename=m-overlay-x64-installer
; "ArchitecturesAllowed=x64" specifies that Setup cannot run on
; anything but x64.
ArchitecturesAllowed=x64
; "ArchitecturesInstallIn64BitMode=x64" requests that the install be
; done in "64-bit mode" on x64, meaning it should use the native
; 64-bit Program Files directory and the 64-bit view of the registry.
ArchitecturesInstallIn64BitMode=x64
LicenseFile=build/x64/license.txt

[Files]
Source: "build/x64/license.txt"; DestDir: "{app}"; DestName: "license.txt"; Flags: ignoreversion
Source: "build/x64/m-overlay-x64.exe"; DestDir: "{app}"; DestName: "m-overlay-x64.exe"; Flags: ignoreversion
Source: "build/x64/love.dll"; DestDir: "{app}"; DestName: "love.dll"; Flags: ignoreversion
Source: "build/x64/lua51.dll"; DestDir: "{app}"; DestName: "lua51.dll"; Flags: ignoreversion
Source: "build/x64/mpg123.dll"; DestDir: "{app}"; DestName: "mpg123.dll"; Flags: ignoreversion
Source: "build/x64/msvcp120.dll"; DestDir: "{app}"; DestName: "msvcp120.dll"; Flags: ignoreversion
Source: "build/x64/msvcr120.dll"; DestDir: "{app}"; DestName: "msvcr120.dll"; Flags: ignoreversion
Source: "build/x64/OpenAL32.dll"; DestDir: "{app}"; DestName: "OpenAL32.dll"; Flags: ignoreversion
Source: "build/x64/SDL2.dll"; DestDir: "{app}"; DestName: "SDL2.dll"; Flags: ignoreversion
Source: "build/x64/ssl.dll"; DestDir: "{app}"; DestName: "ssl.dll"; Flags: ignoreversion
Source: "build/application.love"; DestDir: "{userappdata}/m-overlay"; DestName: "application.love"; Flags: ignoreversion

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; \
    GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\m-overlay-x64.exe"
Name: "{commondesktop}\{#AppName}"; Filename: "{app}\m-overlay-x64.exe"; \
    Tasks: desktopicon

[Run]
Filename: {app}\m-overlay-x64.exe; Description: "Launch {#AppName}"; Flags: postinstall shellexec skipifsilent nowait

[Code]

{ ///////////////////////////////////////////////////////////////////// }
function GetUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstallString: String;
begin
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\M''Overlay_is1');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;


{ ///////////////////////////////////////////////////////////////////// }
function IsUpgrade(): Boolean;
begin
  Result := (GetUninstallString() <> '');
end;


{ ///////////////////////////////////////////////////////////////////// }
function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
{ Return Values: }
{ 1 - uninstall string is empty }
{ 2 - error executing the UnInstallString }
{ 3 - successfully executed the UnInstallString }

  { default return value }
  Result := 0;

  { get the uninstall string of the old app }
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/VERYSILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
end;

{ ///////////////////////////////////////////////////////////////////// }
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep=ssInstall) then
  begin
    if (IsUpgrade()) then
    begin
      MsgBox('M''Overlay has changed install directories, so the old version will be uninstalled first. Your config files and music will remain untouched.', mbInformation, MB_OK);
      UnInstallOldVersion();
    end;
  end;
end;