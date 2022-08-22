unit UDMRest;

interface

uses
  System.SysUtils, System.Classes, REST.Types, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope,System.Json, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, REST.Response.Adapter;

type
  TDMRest = class(TDataModule)
    rstClient: TRESTClient;
    rstRequest: TRESTRequest;
    rstResponse: TRESTResponse;
    rstAdapter: TRESTResponseDataSetAdapter;
    MemRest: TFDMemTable;

    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    function Execute(const AServerMethod: String;
      AMethod: TRESTRequestMethod): Boolean;

    procedure ClearToDefaults;


  public
    { Public declarations }

   //Entradas
   function RecebeMusicas(Artista:string):Boolean;

  end;

var
  DMRest: TDMRest;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses uFrmMain, uDmLocal, AnonThread, Constantes;

{$R *.dfm}

{ TDMRest }





procedure TDMRest.ClearToDefaults;
begin
  rstRequest.ResetToDefaults;
  rstClient.ResetToDefaults;
  rstResponse.ResetToDefaults;

  rstRequest.Accept        := 'application/json;charset=UTF-8';
  rstRequest.AcceptEncoding:= 'gzip, deflate, br';
  rstClient.Accept         := 'application/json;charset=UTF-8';
  rstClient.AcceptCharset  := 'utf-8, *;q=0.8';
  rstClient.ContentType    := CONTENTTYPE_APPLICATION_JSON;
  rstRequest.Params.AddHeader('X-TenantID','TRIANGULO');


  rstResponse.RootElement := '';
end;


procedure TDMRest.DataModuleCreate(Sender: TObject);
begin
 DmLocal.AlimentaApi;
end;

function TDMRest.Execute(const AServerMethod: String;
  AMethod: TRESTRequestMethod): Boolean;
begin
   Result := False;

  try
    try

      rstRequest.Method := AMethod;

      rstClient.BaseURL := Format('%s%s', [C_BASEURL , AServerMethod]);


      rstRequest.Execute;

      Result := rstResponse.StatusCode in ([200,204,201]);
    except
      on E: Exception do
      begin
        if Pos('O tempo limite da operação foi atingido', E.Message) > 0 then
          Result := True;
      end;
    end;
  finally

  end;
end;




function TDMRest.RecebeMusicas(Artista: string): Boolean;
var
  sArtista,sMusica: string;
  i :integer;
  JsonArr : TJSONArray;
  JsonObj,ObjID,retorno,resultados,JsonID : TJSONObject;
  recebe :string ;
begin
  Result := False;

  try
    try
   // Reset de componentes
      Self.ClearToDefaults;

      if Execute('media=music&term='+Artista, rmGET) then
      begin
      Result := True;


      JsonObj  :=  DMRest.rstRequest.Response.JSONValue as TJSONObject;

      JsonArr := JsonObj.GetValue('results') as TJSONArray;

       for i := 0 to JsonArr .Count-1 do
        begin
        retorno   := JsonArr.Items[i] as TJSONObject;

        sArtista := retorno.GetValue('artistName').Value;
        sMusica  := retorno.GetValue('trackName').Value;

          if not DMLocal.ExisteMusica(sArtista,sMusica) then
          begin
            DMLocal.QryMusicas.Append;
            DMLocal.QryMusicaswrapperType.value            := retorno.GetValue('wrapperType').Value;
            DmLocal.QryMusicaskind.value                   := retorno.GetValue('kind').Value;
            DMLocal.QryMusicasartistId.Value               := retorno.GetValue('artistId').Value.ToInteger;
            DmLocal.QryMusicascollectionId.Value           := retorno.GetValue('collectionId').Value.ToDouble;
            DmLocal.QryMusicastrackId.Value                := retorno.GetValue('trackId').Value.ToDouble;
            DMLocal.QryMusicasartistName.value             := retorno.GetValue('artistName').value;
            DMLocal.QryMusicascollectionName.value         := retorno.GetValue('collectionName').value;
            DMLocal.QryMusicastrackName.value              := retorno.GetValue('trackName').value;
            DMLocal.QryMusicascollectionCensoredName.value := retorno.GetValue('collectionCensoredName').value;
            DMLocal.QryMusicastrackCensoredName.value      := retorno.GetValue('trackCensoredName').value;
            DMLocal.QryMusicasartistViewUrl.value          := retorno.GetValue('artistViewUrl').value;
            DMLocal.QryMusicascollectionViewUrl.value      := retorno.GetValue('collectionViewUrl').value;
            DMLocal.QryMusicastrackViewUrl.value           := retorno.GetValue('trackViewUrl').value;



           Try
            DMLocal.QryMusicas.Post;
           except
            continue
           End;

          end;



        end;
        

      end;
    except
      Result := False;
    end;
  finally

  end;

end;




end.
