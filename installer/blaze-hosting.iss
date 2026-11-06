#define MyAppName "Blaze Hosting"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Blaze Hosting"
#define MyAppURL "https://nawazfx.com/"
#define MyAppExeName "BlazeHosting.exe"

[Setup]
AppId={{8F3B0C2A-4E11-4B7A-9C21-BLAZEHOST0001}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL=https://panel.nawazfx.com/
AppUpdatesURL=https://nawazfx.com/app/
DefaultDirName={autopf}\Blaze Hosting
DefaultGroupName=Blaze Hosting
DisableProgramGroupPage=yes
DisableWelcomePage=no
LicenseFile=LICENSE.txt
InfoBeforeFile=INFO.txt
OutputDir=..\dist
OutputBaseFilename=blaze-hosting-setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
WizardSizePercent=120,120
WizardResizable=yes
WizardImageFile=wizard.bmp
WizardSmallImageFile=wizard-small.bmp
SetupIconFile=app.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName=Blaze Hosting
PrivilegesRequired=lowest
CloseApplications=yes
RestartApplications=yes
MinVersion=6.1sp1
VersionInfoVersion=1.0.0
VersionInfoCompany=Blaze Hosting
VersionInfoDescription=Isolated native client for panel.nawazfx.com
VersionInfoProductName=Blaze Hosting
VersionInfoProductVersion=1.0.0
VersionInfoCopyright=Blaze Hosting
SetupLogging=yes
ShowLanguageDialog=no
AllowNoIcons=yes
UsePreviousAppDir=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
SetupAppTitle=Blaze Hosting Setup
SetupWindowTitle=Blaze Hosting 1.0.0 — Setup
WelcomeLabel1=Welcome to Blaze Hosting
WelcomeLabel2=This installs the isolated native Windows client for your panel.nawazfx.com account.%n%nIt is not a browser. Only your servers. Create an account or sign in after install.
FinishedHeadingLabel=Blaze Hosting is ready
FinishedLabel=Setup finished. Open Blaze Hosting to create an account or sign in to panel.nawazfx.com.
ClickFinish=Click Finish to exit Setup.
ConfirmUninstall=Remove Blaze Hosting from this PC? Your panel account stays on the server.

[Tasks]
Name: "desktopicon"; Description: "Desktop shortcut"; GroupDescription: "Shortcuts:"; Flags: checkedonce
Name: "quicklaunchicon"; Description: "Start Menu pin"; GroupDescription: "Shortcuts:"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "app.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app.ico"; Comment: "Isolated client — panel.nawazfx.com"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\app.ico"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Open Blaze Hosting now"; Flags: nowait postinstall skipifsilent unchecked

[UninstallDelete]
Type: filesandordirs; Name: "{userappdata}\com.blazenxt.hosting"
Type: filesandordirs; Name: "{localappdata}\hosting"

[Code]
procedure InitializeWizard;
begin
  WizardForm.WelcomeLabel1.Font.Style := [fsBold];
  WizardForm.LicenseAcceptedRadio.Caption := 'I accept the Blaze Hosting terms';
  WizardForm.LicenseNotAcceptedRadio.Caption := 'I do not accept the terms';
end;
