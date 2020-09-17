unit PWM_VST;

interface

uses
  Vcl.StdCtrls, Vcl.DBCtrls, Virtualtrees, System.SysUtils;

Type
  TDBTree = class(Tobject)
    var AVST : TVirtualStringTree;
    private
      procedure SetFirstData;
      procedure SetData( pNode : PVirtualNode; isFolder : Boolean; Bezeichnung : String = '');
    public
      Constructor Create( VST : TVirtualStringTree ); overload; virtual;
//      procedure AddDBNodeAtStandart;
      function AddDBNodeAtStandart : PVirtualNode;
      //TODO: AddDBNode bei einem bestimmten Ordner
      procedure FirstOpen;
      procedure TryExpandNode( pNode : PVirtualNode);
  end;

procedure TogglePWSign( Edit : TCustomEdit; hide : Boolean );

const
  SC_NO_DATA    = 'NO_DATA';
  SC_FOLDER     = 'FOLDER';
  SC_FILE       = 'FILE';

  IC_FOLDER_OPEN  = 0;
  IC_FOLDER_CLOSE = 1;
  IC_KEY          = 2;
  IC_KEY_SEL      = 3;
  IC_FAVORIT      = 4;

implementation

uses
  Vcl.Dialogs, Main_PWM;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TDBTree Klasse
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
Constructor TDBTree.Create( VST : TVirtualStringTree );
begin
  inherited Create;
  AVST := VST;
  AVST.NodeDataSize := SizeOf( rVTNodeData );
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TDBTree.SetData( pNode : PVirtualNode; isFolder : Boolean; Bezeichnung : String = '');
var
pData : pVTNodeData;
begin
  //TODO: wenn es soweit ist, dann muss dem Node noch die ID des Datensatzen zugewiesen werden damit
  //dieser den DatenSatz �ndert
  if isFolder then
  begin
    pData := AVST.GetNodeData( pNode );
    pData^.Bezeichnung := Bezeichnung;
    pData^.Benutzername := SC_NO_DATA;
    pData^.Passwort := SC_NO_DATA;
    pData^.Info := SC_NO_DATA;
    pData^.isFavorit := false;
    pData^.Ordner := SC_FOLDER;
    pData^.NodeIdx := AVST.AbsoluteIndex( pNode );
    pData^.NodeImageIdx := IC_FOLDER_OPEN;
  end
  else
  begin
    pData := AVST.GetNodeData( pNode );
    pData^.Bezeichnung := 'Neuer Schl�ssel';
    pData^.Benutzername := Main.DBEditBenutzer.Text;
    pData^.Passwort := Main.DBEditPasswort.Text;
    pData^.Info := Main.DBMemoInfo.Text;
    pData^.isFavorit := false;
    pData^.Ordner := SC_FILE;
    pData^.NodeIdx := AVST.AbsoluteIndex( pNode );
    pData^.NodeImageIdx := IC_KEY;
  end;

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TDBTree.SetFirstData;
begin


end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TDBTree.FirstOpen;
var
pNode, pNode2 : PVirtualNode;
begin
  pNode := AVST.AddChild( nil );
  SetData( pNode, true, 'Passwort-Manager' );
  pNode2 := AVST.AddChild( pNode );
  SetData( pNode2, true, 'Favoriten' );
  pNode2 := AVST.AddChild( pNode );
  SetData( pNode2, true, 'Alle' );
  AVST.FullExpand();
end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TDBTree.TryExpandNode( pNode : PVirtualNode );
begin
  if not AVST.Expanded[ pNode ] then
    AVST.FullExpand( PNode );

end;

{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
function TDBTree.AddDBNodeAtStandart : PVirtualNode;
var
pNode : PVirtualNode;
pData : pVTNodeData;
Nodes :TVTVirtualNodeEnumeration;
pChildNode : PVirtualNode;
Bezeichnung : String;
begin
  //suche nach dem Ordner 'Alle'
  Nodes := AVST.nodes;
  for pNode in Nodes do
  begin
    pData := AVST.GetNodeData( pNode );
    Bezeichnung := pData^.Bezeichnung;
    if Bezeichnung.Equals('Alle') then
    begin
      break;
    end;
  end;

  pChildNode := AVST.AddChild( pNode );
  SetData( pChildNode, false );
  Result := pChildNode;
end;

{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TDBTree Klasse Ende
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}


{------------------------------------------------------------------------------
Author: Seidel 2020-09-06
-------------------------------------------------------------------------------}
procedure TogglePWSign( Edit : TCustomEdit; hide : Boolean );
begin
  if Edit is TEdit then
  begin
    if hide then
      (Edit as TEdit).PasswordChar := '*'
    else
      (Edit as TEdit).PasswordChar := #0;
  end
  else if Edit is TDBEdit then
  begin
    if hide then
      (Edit as TDBEdit).PasswordChar := '*'
    else
      (Edit as TEdit).PasswordChar := #0;
  end
  else
    Exit;
end;

end.
