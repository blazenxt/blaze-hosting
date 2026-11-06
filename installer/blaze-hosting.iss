#define MyAppName "Blaze Hosting"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Blaze Hosting"
#define MyAppURL "https://nawazfx.com/"
#define MyAppExeName "BlazeHosting.exe"

[Setup]
AppId={{8F3B0C2A-4E11-4B7A-9C21-BLAZEHOST0001}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName={autopf}\Blaze Hosting
DefaultGroupName=Blaze Hosting
OutputDir=..\dist
OutputBaseFilename=blaze-hosting-setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
CloseApplications=yes
RestartApplications=yes
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Open Blaze Hosting"; Flags: nowait postinstall skipifsilent
