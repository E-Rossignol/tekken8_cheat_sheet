#define MyAppName "Tekken 8 Cheat Sheet"
#define MyAppVersion "1.3.1"
#define MyAppPublisher "Rossignol Erwan"
#define MyAppExeName "tekken_cheat_sheet.exe"

[Setup]
AppId={{A7E4C2B1-8D36-4F92-9C71-5B82E43F17A9}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}

DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}

OutputDir=build\installer
        OutputBaseFilename=Tekken8CheatSheet-Setup-{#MyAppVersion}

Compression=lzma
SolidCompression=yes

ArchitecturesInstallIn64BitMode=x64

UninstallDisplayIcon={app}\{#MyAppExeName}

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Lancer {#MyAppName}"; Flags: nowait postinstall skipifsilent