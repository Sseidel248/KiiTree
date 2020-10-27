unit Login_PWM;

{******************************************************************************
Login Dialog von "KiiTree"
Author: Sebastian Seidel

*******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, Vcl.Buttons, GradientPanel, System.UITypes,
  Edit4User, U_USB;

type
  TLogin = class(TForm)
    Image1: TImage;
    UserMasterPWEdit: TEdit;
    AnmeldeBtn: TButton;
    ImageList1: TImageList;
    CBNewUser: TCheckBox;
    ImageList2: TImageList;
    ImageList3: TImageList;
    SBToogleHide: TSpeedButton;
    Label1: TLabel;
    ESavePathForKTPs: TEdit;
    BGetKTPSavePath: TButton;
    UsernameEdit: TEdit4User;
    GradientPanel2: TGradientPanel;
    USBInput: TComponentUSB;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AnmeldeBtnClick(Sender: TObject);
    procedure UsernameEditChange(Sender: TObject);
    procedure UserMasterPWEditChange(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure CBNewUserClick(Sender: TObject);
    procedure UserMasterPWEditKeyPress(Sender: TObject; var Key: Char);
    procedure UsernameEditKeyPress(Sender: TObject; var Key: Char);
    procedure SBToogleHideClick(Sender: TObject);
    procedure BGetKTPSavePathClick(Sender: TObject);
    procedure USBInputUSBGetDriveLetter(Sender: TObject;
      const DrivePath: string);
    procedure USBInputUSBRemove(Sender: TObject);
  private
//    LoginStates : TLoginStates;                                             //erstmal nicht benutzt
//    property LoginState : TLoginStates read LoginStates write LoginStates;  //erstmal nicht benutzt
    procedure CheckKTPExist( SaveFile : string ) ;                   //erstmal nicht benutzt
    function CheckUserAndPW : Boolean;
    procedure EnableAnmeldeBtn;
    function CheckKTPExistPlus( SaveFile : String ) : Boolean;
//    function Check4FirstStart: Boolean;


//    procedure TextChange( Edit : TEdit; Str : String );
//    procedure TextStandart( Edit : TEdit; Str : String );
//    procedure TextClick( Edit : TEdit; Str : String );
    { Private-Deklarationen }
  public
//    class procedure TextChange( Edit : TEdit; Str : String );              //erstmal nicht benutzt
//    class procedure TextStandart( Edit : TEdit; Str : String );            //erstmal nicht benutzt
//    class procedure TextClick( Edit : TEdit; Str : String );               //erstmal nicht benutzt
//    class function MD5String( const Input: String ) : String;              //erstmal nicht benutzt
//    class function SHA256String( const Input : String ) : String;          //erstmal nicht benutzt
//    procedure ChangeLoginState( Enter : TLoginStates; Leave : TLoginStates = []);  //erstmal nicht benutzt
    { Public-Deklarationen }
  end;

var
  Login : TLogin;


implementation

uses
  IdHashMessageDigest, IdHash, Main_PWM, Global_PWM, IniFiles, ZipForge, Hash_Functions;

{$R *.dfm}


{------------------------------------------------------------------------------
Author: Seidel 2020-10-17
-------------------------------------------------------------------------------}
//function TLogin.Check4FirstStart: Boolean;
//var
//ini : TStringList;
//iniName : String;
//begin
//  ini := TStringList.Create;
//  try
//    //nur zum �berpr�fen falls es doch gel�scht wurde
//    if not FileExists( MainIni.IniPath ) then
//    begin
//      MainIni.CreateIfNotExist;
//    end;
//    ini.LoadFromFile( MainIni.IniPath );
//    Result := StrToBoolDef( ini.Values[ SC_FIRSTSTART ], true );
//  finally
//    ini.Free;
//  end;
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-22
-------------------------------------------------------------------------------}
function TLogin.CheckKTPExistPlus( SaveFile : String ) : Boolean;
var
sText : String;
begin
  if FileExists( SaveFile ) then
    Result := true
  else
  begin
    sText := 'Ihr Datei konnte in dem von Ihnen gew�hlten Verzeichnis nicht gefunden werden!' + sLineBreak + sLineBreak
    + 'Pr�fe Sie bitte, ob der richtige Pfad gew�hlt wurde oder w�hlen Sie einen anderes Verzeichnis.';
    Result := false;
    MessageDlg( sText, mtError, [mbOK], 0 );
    BGetKTPSavePath.SetFocus;
  end;
end;


{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.EnableAnmeldeBtn;
var
Usertext, PwText : string;
begin
  Usertext := UsernameEdit.Text;
  PwText := UserMasterPWEdit.Text;
  if Usertext.Equals( '' ) or PwText.Equals( '' ) then
  begin
    AnmeldeBtn.Enabled := false;
    SBToogleHide.Enabled := false;
  end
  else
  if ( not UsernameEdit.UserExist ) and ( CBNewUser.Checked ) then
  begin
    AnmeldeBtn.Enabled := true;
    SBToogleHide.Enabled := true;
  end
  else
  if UsernameEdit.UserExist and ( CBNewUser.Checked ) then
  begin
    AnmeldeBtn.Enabled := false;
    SBToogleHide.Enabled := false;
  end
  else
  if UsernameEdit.UserExist and ( not CBNewUser.Checked ) then
  begin
    AnmeldeBtn.Enabled := true;
    SBToogleHide.Enabled := true;
  end
  else
  begin
    AnmeldeBtn.Enabled := true;
    SBToogleHide.Enabled := true;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
function TLogin.CheckUserAndPW : Boolean;
var
ZipForge : TZipForge;
ArchiveItem : TZFArchiveItem;
stream : TMemoryStream;
Sl : TStringlist;
begin
  {$IFDEF TESTLOGIN}
    Result := UserData.User.Equals( UserData.PW_Str );
    Exit;
  {$ENDIF}
  Result := false;
  ZipForge := TZipForge.Create( nil );
  stream := TMemoryStream.Create;
  Sl := TStringList.Create;
  try
    with ZipForge do
    begin
      FileName := GetActualSaveFile( UserData.KTP_Name_MD5 );
      OpenArchive( fmOpenRead );
      EncryptionMethod := caAES_256;
      Password := AnsiString( GetCryptStr( PM_PW, UserData.User, UserData.PW_Str ) );
//      Password := SHA256String( PM_PW );
//      Password := MD5String(PM_PW);  //Change 2020.09.28
      if FindFirst( '*.ini', ArchiveItem, faAnyFile ) then
      begin
        if IsFilePasswordValid( archiveItem.FileName , Password ) then//Change 2020-10-10
        begin
          stream.Clear;
          stream.Position := 0;
          ExtractToStream( archiveItem.FileName, stream );
          stream.Position := 0;
          Sl.LoadFromStream( stream );
          stream.Position := 0;
          Result := ( Sl.Values[SC_USER].Equals( UserData.User) )
                    and ( Sl.Values[SC_PW].Equals( UserData.PW_Str )
                    and ( Sl.Values[SC_KTP].Equals( UserData.KTP_Name_MD5 ) ) );
        end;
      end;
    end;
  finally
    ZipForge.Free;
    stream.Free;
    Sl.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-07
-------------------------------------------------------------------------------}
procedure TLogin.BGetKTPSavePathClick(Sender: TObject);
var
OpenDialog : TFileOpenDialog;
begin
  OpenDialog := TFileOpenDialog.Create( nil );
  try
    OpenDialog.Options := [fdoPathMustExist, fdoPickFolders];
    OpenDialog.Title := 'W�hlen Sie den Ordner in dem Ihr KiiTree gespeichert wurde';
    if OpenDialog.Execute then //Pfad wird NUR gesetzt wenn ein Ordner erfolgreich gew�hlt wurde
    begin
      MainIni.LastLoadPath := OpenDialog.FileName + '\';
      ESavePathForKTPs.Text := OpenDialog.FileName + '\';
    end
  finally
    OpenDialog.Free;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.CBNewUserClick(Sender: TObject);
begin
  if CBNewUser.Checked then
    AnmeldeBtn.Caption := 'Passwort-Safe �ffnen und neuen Benutzer erzeugen'
  else
    AnmeldeBtn.Caption := 'Passwort-Safe �ffnen';

  UsernameEdit.Required := CBNewUser.Checked;
  MainIni.IsNewUserChecked := CBNewUser.Checked;
  UsernameEdit.Invalidate;
  EnableAnmeldeBtn;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.CheckKTPExist( SaveFile : string );
begin
  if FileExists( SaveFile ) then
  begin
    UsernameEdit.UserExist := true;
    UsernameEdit.Hint := 'Kein passender KiiTree in dem Verzeichnis gefunden!';
  end
  else
    UsernameEdit.UserExist := false;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20 !!Modalresult schlie�t ein Modal ge�ffnetes Formular
-------------------------------------------------------------------------------}
procedure TLogin.AnmeldeBtnClick(Sender: TObject);
var
User, PwStr : String;
SaveStr : String;
begin

  USer := Trim( UsernameEdit.Text );
  PwStr := UserMasterPWEdit.Text;
  UserData.KTP_Name_MD5 := GetMD5String( User ) + SC_EXT;
  UserData.User := User;
  UserData.PW_Str := PwStr;
  SaveStr := GetActualSaveFile( UserData.KTP_Name_MD5 );

  //Imagelist 0 = start; 1 = OK; 2 = fail
  try
    if {CheckPMKExist( MD5String( User ) )} not CBNewUser.Checked then  //bestehenden Benutzer w�hlen
    begin
      {$IFNDEF TESTLOGIN}
      if not CheckKTPExistPlus( SaveStr ) then
        Exit;
      {$ENDIF}

      if FileExists( SaveStr ) then  //pr�fen ob der Benutzer existiert
      begin
        if ( CheckUserAndPW ) then // und eingabe stimmt
        begin
          ModalResult := mrOk; // ok = 1 login erfolgreich
          ImageList3.GetIcon( 1, Image1.Picture.Icon );
          {$IFNDEF TESTLOGIN}
            Login.Refresh;
            Sleep(500);
          {$ENDIF}

        end
        else   //und eingabe stimmt nicht
        begin
          ImageList3.GetIcon( 2, Image1.Picture.Icon );
          {$IFNDEF TESTLOGIN}
            ShowMessage( 'Benutzername und Passwort stimmen nicht �berein!' + sLineBreak + 'Versuchen Sie es erneut.');
            UsernameEdit.SelectAll;
            Login.Refresh;
          {$ELSE}
          ModalResult := mrClose;  // = 8
          {$ENDIF}

        end;
      end
      else //Benutzer existiert nicht
      begin
        {$IFNDEF TESTLOGIN}
        if MessageDlg( 'Benutzername existiert noch nicht, soll dieser angelegt werden?',
                    mtInformation,
                    [mbYes, mbNo], 0 ) = mrYes then
        begin
          ImageList3.GetIcon( 1, Image1.Picture.Icon );
          ModalResult := mrRetry; //retry = 4 neuer Benutzer
          UserData.KTP_Name_MD5 := GetMD5String( User ) + SC_EXT;
          UserData.User := User;
          UserData.PW_Str := PwStr;
          Login.Refresh;
          Sleep(500);
        end;
        {$ELSE}
          ModalResult := mrRetry; // 4
        {$ENDIF}
      end;
    end
    else //neuer Benutzer soll erstellt werden
    begin
      //es wurde einer neuer Benutzer erstellt, deshalb beim n�chsten Start "Neuer Benutzer" Checkbox = false
      MainIni.IsNewUserChecked := false;
      ImageList3.GetIcon( 1, Image1.Picture.Icon );
      {$IFNDEF TESTLOGIN}
        UserData.KTP_Name_MD5 := GetMD5String( User ) + SC_EXT;
        UserData.User := User;
        UserData.PW_Str := PwStr;
        Login.Refresh;
        Sleep(500);
      {$ENDIF}
      ModalResult := mrRetry; //retry = 4 neuer Benutzer
    end;
  finally
    {$IFNDEF TESTLOGIN}
    MainIni.SaveSetting;
    {$ENDIF}
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // noch nicht benutzt!
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.FormCreate(Sender: TObject);

begin
  ImageList2.GetBitmap( 0, SBToogleHide.Glyph );
  SBToogleHide.Flat := true;
  ESavePathForKTPs.Hint := 'Speicherverzeichnis von KiiTree';
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.FormHide(Sender: TObject);
begin
//  Sleep(500);
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.FormShow(Sender: TObject);
//var
//EditText : String;
begin
  UsernameEdit.SetFocus;
  UsernameEdit.Clear;
  ImageList3.GetIcon( 0, Image1.Picture.Icon );

  USBInput.Required := true;

  //�berpr�fe ob der Speicherordner vom installieren vorhanden ist ( Standartverzeichnis )
  if not DirectoryExists( DefaultSettings.DefaultUserSavePath ) then
    ForceDirectories( DefaultSettings.DefaultUserSavePath );

  {$IFNDEF TESTLOGIN}
  //nur zur Sicherheit
  MainIni.CreateIfNotExist;
  MainIni.LoadSetting( CBNewUser, ESavePathForKTPs );

  {$ENDIF}
//  ImageList1.GetIcon( 0, Image1.Picture.Icon );
//  PersonalFolder := GetSpecialFolder( Handle, IC_GET_PERSONAL_FOLDER ) + 'Documents\KiiTree\';
//  ESavePathForKTPs.Text := PersonalFolder;
//  UserData.PersonalUserSavePath := PersonalFolder;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-30
-------------------------------------------------------------------------------}
procedure TLogin.SBToogleHideClick(Sender: TObject);
begin
  if UserMasterPWEdit.PasswordChar = '*' then
  begin
    SBToogleHide.Glyph := nil;
    UserMasterPWEdit.PasswordChar := #0;
    ImageList2.GetBitmap( 1, SBToogleHide.Glyph );
  end
  else
  begin
    SBToogleHide.Glyph := nil;
    UserMasterPWEdit.PasswordChar := '*';
    ImageList2.GetBitmap( 0, SBToogleHide.Glyph );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-23
-------------------------------------------------------------------------------}
procedure TLogin.USBInputUSBGetDriveLetter(Sender: TObject;
  const DrivePath: string);
var
sText : String;
mResult : Integer;
begin
  sText := 'Es wurde ein USB Ger�t eingesteckt!' + sLineBreak
          + 'Wollen Sie diesen USB verwenden?';
  MResult := MessageDlg( sText, mtInformation, [mbYes, mbNo], 0, mbYes );
  if MResult = mrYes then
  begin
    MainIni.LastLoadPath := DrivePath;
    ESavePathForKTPs.Text := DrivePath;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-10-23
-------------------------------------------------------------------------------}
procedure TLogin.USBInputUSBRemove(Sender: TObject);
begin
  MainIni.LastLoadPath := DefaultSettings.DefaultUserSavePath;
  ESavePathForKTPs.Text := DefaultSettings.DefaultUserSavePath;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UserMasterPWEditChange(Sender: TObject);
begin
  EnableAnmeldeBtn;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UserMasterPWEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    AnmeldeBtnClick( Sender );
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UsernameEditChange(Sender: TObject);
var
Username :String;
Path : String;
//NameWithPath : String;
UserKTP : String;
begin

    Username := GetMD5String( UsernameEdit.Text ) + SC_EXT;
  //speicherpfad innerhalb des Programms
//  NameWithPath := Concat( UserData.AppSavePath, Username );
  //Speicherpfad im "Eigene Dateien" Ordner
  //TODO: MainIni.LastLoadPath anpassen
    Path := GetActualSavePath;
    UserKTP := Concat( Path, Username );
//  if CheckKTPExist( NameWithPath ) then
//    UsernameEdit.UserExist := true
//  else
  if CBNewUser.Checked then
  begin
    CheckKTPExist( UserKTP );
  end;
  EnableAnmeldeBtn;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
procedure TLogin.UsernameEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    UserMasterPWEdit.SetFocus;
    UserMasterPWEdit.SelectAll;
  end;
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
//procedure TLogin.TextChange( Edit : TEdit; Str : String);
//var
//EditText : String;
//begin
//  EditText := Edit.Text;
//  if not EditText.Equals('') then
//    Edit.Font.Color := clBlack
//  else
//    Edit.Font.Color := clMedGray;
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
//procedure TLogin.TextStandart( Edit : TEdit; Str : String);
//var
//EditText : String;
//begin
//  EditText := Edit.Text;
//  if EditText.Equals('') then
//  begin
//    Edit.Text := Str;
//    Edit.Font.Color := clMedGray;
//  end
//  else if EditText.Equals(Str) then
//  begin
//    Edit.Font.Color := clMedGray;
//  end
//  else
//  begin
//    Edit.Font.Color := clBlack;
//  end;
//
//end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-20
-------------------------------------------------------------------------------}
//procedure TLogin.TextClick( Edit : TEdit; Str : String);
//var
//EditText : String;
//begin
//  EditText := Edit.Text;
//  if not EditText.Equals( Str ) then
//    Edit.SelectAll
//  else
//    Edit.Clear;
//end;

end.
