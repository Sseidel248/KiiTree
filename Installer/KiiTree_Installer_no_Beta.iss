; Script generated by the Inno Script Studio Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppVersion "1.0.0"
#define MyAppBuild "0"
#define MyAppName "KiiTree"

[Setup]
AppName = {#MyAppName}
AppPublisher = Sebastian Seidel
AppCopyright=Sebastian Seidel
DefaultDirName = {sd}\{#MyAppName}
//verhindert ein anzeigen der Startmen�gruppe
DisableProgramGroupPage = yes
DefaultGroupName = {#MyAppName}
;WizardImageFile = "..\Bilder\InstallLogo_test_164x314.bmp" 
AppVersion= {#MyAppVersion}.{#MyAppBuild}
VersionInfoProductVersion={#MyAppVersion}.{#MyAppBuild}
VersionInfoVersion = {#MyAppVersion}.{#MyAppBuild}
AppVerName = KiiTree Beta {#MyAppVersion}.{#MyAppBuild}
OutputBaseFilename = {#MyAppName}_{#MyAppVersion}.{#MyAppBuild}
OutputDir = ..\Installer\
VersionInfoCompany=Sebastian Seidel
VersionInfoCopyright=Sebastian Seidel
VersionInfoProductName=KiiTree
;VersionInfoProductTextVersion=Beta
WizardStyle=modern
AppContact=sseidel248@yahoo.de
DisableWelcomePage = false
//zeigt die Seite wo der User aussucht wohin er es installieren m�chte
DisableDirPage = no
AlwaysShowDirOnReadyPage = yes
UninstallDisplayIcon = {app}\Bilder\KiiTree_v1.ico
UninstallDisplayName = {#MyAppName} {#MyAppVersion}.{#MyAppBuild}
//zum eintragen von Organisation etc.
;UserInfoPage = true

[Files]
Source: "..\Release\KiiTree.exe"; DestDir: "{app}\Anwendung"; Flags: ignoreversion;
Source: "..\DB\EmtyTable.xml"; DestDir: "{app}\DB"; Flags: ignoreversion

Source: "..\Bilder\KiiTree_v1.ico"; DestDir: "{app}\Bilder"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\VerionInfo.txt"; DestDir: "{app}\Anwendung"; Flags: ignoreversion
;Source: "..\Bilder\InstallLogo_test_164x314.bmp"; DestDir: "{app}"; Flags: deleteafterinstall
;Source: "KiiTree.ini"; DestDir: "{app}\Anwendung"; Attribs: hidden

[Icons]
Name: "{group}\KiiTree_Icon"; Filename: "{app}\Bilder\KiiTree_v1.ico"; WorkingDir: "{app}\Bilder"; IconFilename: "{app}\Bilder\KiiTree_v1.ico"; IconIndex: 0
Name: "{userdesktop}\KiiTree"; Filename: "{app}\Anwendung\KiiTree.exe"; IconFilename: "{app}\Bilder\KiiTree_v1.ico"; IconIndex: 0; Tasks: Desktop_Icon
Name: "{userappdata}\MicrosoftInternetExplorerQuickLaunchTest"; Filename: "{app}\Anwendung\KiiTree.exe"; IconFilename: "{app}\Bilder\KiiTree_v1.ico"; IconIndex: 0; Tasks: quicklaunchicon

[Dirs]
Name: "{app}\DB"
Name: "{app}\Bilder"
Name: "{app}\Anwendung"
Name: "{userdocs}\KiiTree"

[INI]
; Imported INI File: "D:\Delphi embarcadero\Passwort_Manager\README.md"

[Tasks]
Name: "Desktop_Icon"; Description: "Desktop Icon Erstellen"; GroupDescription: "Additional Icon"
Name: "quicklaunchicon"; Description: "Quick Launch Icon erstellen"; GroupDescription: "Additional Icon"

[InstallDelete]
Type: files; Name: "{app}\KiiTree_v1.ico"

[UninstallDelete]
Type: dirifempty; Name: "{app}"
Type: files; Name: "{app}\Anwendung\KiiTree.ini"

[Languages]
Name: "German"; MessagesFile: "compiler:Languages\German.isl"

[Code]
procedure VergleicheVersion;
var
Version,
VersionNew : String;
begin
  GetVersionNumbersString( '..\Release\KiiTree.exe', Version );
  VersionNew := '{#MyAppVersion}.{#MyAppBuild}';

  if CompareStr( Version, VersionNew ) < 0  then
    MsgBox( Version + ' < ' + VersionNew, mbInformation, MB_OK )
  else
    MsgBox( Version + ' >= ' + VersionNew, mbInformation, MB_OK );

end;

//wird ausgef�hrt bevor das Setup startet
{
function InitializeSetup(): Boolean;
var
str : String;
begin
  VergleicheVersion;
  Result := true;
end;
}

//wird ausgel�st bevor alles verarbeitet wird, also der gr�ne ladebalken kommt

procedure CurPageChanged(CurPageID: Integer);
var
str : String;
begin
  if CurPageID = wpSelectDir then
  begin
    str := 'Wichtiger Hinweis!' + #10#13 + #10#13
    + 'Wenn Sie das Programm unter dem Pfad: "C:\Programme\" oder "C:\Programm (x86)\" installieren, kann es zu Problemen mit der UAC (Benutzerrechteverwaltung) kommen, wodurch die Anwendung nur mit Administatorenrechte gestartet werden kann.';

    MsgBox( Str, mbInformation, MB_OK );
  end;
end;


//wird beim den Pfaden und den aussuchen von dektop verkn�pfung und so aufgerufen

{function ShouldSkipPage( PageID: Integer ): Boolean;
var
str : String;
begin

  if ( PageID = wpSelectDir ) then 
  begin
    str := 'Wichtiger Hinweis!' + #10#13 + #10#13
    + 'Wenn Sie das Programm unter dem Pfad: "C:\Programme\" oder "C:\Programm (x86)\" installieren, kann es zu Problemen mit der UAC (Benutzerrechteverwaltung) kommen, wodurch die Anwendung nur mit Administatorenrechte gestartet werden kann.';

    MsgBox( Str, mbInformation, MB_OK );

  end;
end;}

