#define MyAppName "JS8Call Plus"
#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif
#pragma message "AppVersion is: " + MyAppVersion
#define MyAppPublisher "JS8Call Plus"
#define MyAppURL "https://github.com/RobBobbins/JS8Call-Plus"
#define MyAppExeName "JS8Call-Plus.exe"
; SrcRoot is the checked-out repo, passed in by the build workflow (/DSrcRoot=...)
#ifndef SrcRoot
  #define SrcRoot "D:\a\JS8Call-Plus\JS8Call-Plus"
#endif

[Setup]
AppId={{31B3285A-8C78-4F1F-A7A3-5EF875B7EE23}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
LicenseFile={#SrcRoot}\build\JS8Call\LICENSE
DefaultDirName={autopf}\{#MyAppName}
UsePreviousAppDir=no
; UninstallDisplayIcon={app}\{#MyAppExeName}
; "ArchitecturesAllowed=x64compatible" specifies that Setup cannot run
; on anything but x64 and Windows 11 on Arm.
ArchitecturesAllowed=x64compatible
; "ArchitecturesInstallIn64BitMode=x64compatible" requests that the
; install be done in "64-bit mode" on x64 or Windows 11 on Arm,
; meaning it should use the native 64-bit Program Files directory and
; the 64-bit view of the registry.
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
; Uncomment the following line to run in non administrative install mode (install for current user only).
;PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir={#SrcRoot}\build\JS8Call
; This can be changed from the ci-windows.yml for release builds
OutputBaseFilename=JS8Call-Plus-installer
SetupIconFile={#SrcRoot}\icons\windows-icons\js8call.ico
UninstallDisplayIcon={#SrcRoot}\icons\windows-icons\js8call.ico
SolidCompression=yes
; WizardStyle introduced in 6.6.0, Github has 6.5.4
; WizardStyle=modern dynamic

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SrcRoot}\build\JS8Call\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SrcRoot}\build\JS8Call\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SrcRoot}\icons\windows-icons\js8call.ico"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\js8call.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\js8call.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

