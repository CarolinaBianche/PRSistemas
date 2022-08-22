unit Model.Connection;

interface

uses
  System.JSON,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Comp.UI,
  Data.DB,
  FireDAC.Comp.Client,
  Firedac.DApt,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef,
  IniFiles,
  SysUtils,
  System.Generics.Collections;

var
  FDriver : TFDPhysMSSQLDriverLink;
  FCursor : TFDGUIxWaitCursor;
  FConnList : TObjectList<TFDConnection>;
  FConexao  : TFDConnection;
  FRede     : String;
  FiltroInicio :TDateTime;

function  Connected(NomeBanco,Tipo:string) : Integer;
procedure Disconnected(Index : Integer);



implementation

function Connected(NomeBanco,Tipo:string) : Integer;
var
  ini: TIniFile;
  caminho,server, BancoDados,Usuario,Senha,Servidor,Porta,Driver :string;
begin
  if not Assigned(FConnList) then
   FConnList := TObjectList<TFDConnection>.Create;
   caminho   := ExtractFilePath(ParamStr(0));



  if FileExists(caminho + '\Conexao\Config.ini') then
  begin

    ini := TIniFile.Create(caminho + '\Conexao\Config.ini');

    FConexao := TFDConnection.Create(nil);
    FDriver  := TFDPhysMSSQLDriverLink.Create(nil);

    FConexao.FetchOptions.RowsetSize := 5000;
    FConexao.LoginPrompt := false;

    FConnList.Add(FConexao);
    Result := Pred(FConnList.Count);

    BancoDados   := ini.ReadString('REDE','DATABASE','');
    Usuario      := ini.ReadString('REDE','USERNAME','');
    Senha        := ini.ReadString('REDE','PASSWORD','');
    Servidor     := ini.ReadString('REDE','SERVER','');
    Porta        := ini.ReadString('REDE','PORTA','');
    Driver       := ini.ReadString('REDE','DRIVERID','' );

    FConnList.Items[Result].LoginPrompt := false;
    FConnList.Items[Result].Params.Clear;
    FConnList.Items[Result].Params.Add('Server=' + Servidor);
    FConnList.Items[Result].Params.Add('user_name=' + Usuario);
    FConnList.Items[Result].Params.Add('password=' + Senha);
    FConnList.Items[Result].Params.Add('Database=' + BancoDados);
    FConnList.Items[Result].Params.Add('DriverID=' + Driver);
    FConnList.Items[Result].Params.Add('OSAuthent=Yes');


    FConnList.Items[Result].Connected;
  End;

end;

procedure Disconnected(Index : Integer);
begin
  FConnList.Items[Index].Connected := False;
  FConnList.Items[Index].Free;
  FConnList.TrimExcess;
end;

end.
