unit Ossel.firedac.funcoes;

interface

uses

  Model.Connection,
  uServerController,
  Ossel.Template.StarAdmin,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,   PNGImage,
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages, System.Variants, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFrmPadrao, IWVCLComponent,
  IWBaseLayoutComponent, IWBaseContainerLayout, IWContainerLayout,
  IWTemplateProcessorHTML, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl,
  IWControl, IWCompButton, IWCompLabel, IWCompMemo, IWCompExtCtrls,Soap.EncdDecd;

Function AutenticarUsuario(Login:string;Senha:String;Tipo:String):Boolean;
Function GerarID(GEN:string):Integer;
Function Get_Pendencia(Inscricao,Cpf:string):Boolean;
Function Get_base64:string;
Function Get_Status:string;
Function Get_Conveniados(Cidade,Especialidade,Nome:string):string;
Function Get_Cidades    :TStringList;
Function Get_Especialidade :TStringList;
Function Get_Conveniados_Especialidades(Conveniado:string):TStringList;
Function Get_Conveniados_Contato(Conveniado:string):string;
Function GET_Conveniados_Endereco(Conveniado:string):string;
Function Get_Cidade_Filtro(Cidade:string):string;
Function Get_Especialidade_Filtro(Especialidade:string):string;
function Get_TOKEN(Size, Tipo: Integer): String;
function Get_Localizacao:string;
function Get_DataAssinatura:string;
function Get_Equipamentos :TStringList;
function Get_Solicitacao_Equip:string;
function Get_Comprovantes(Tipo:string):string;
function Get_LinhaDigitavel:string;
function ValidaInscricao(Inscricao,CPF:string) : Boolean;
Function PreencheNome(Inscricao:string) :TStringList;

implementation

function ValidaInscricao(Inscricao,CPF:string) : Boolean;
 var
 QryI:TFDQuery;
begin

 try

   try
   QryI := TFDQuery.Create(nil);
   QryI.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryI.Active := false;
   QryI.SQL.Clear;
   QryI.SQL.ADD('Select Inscricao,CPF ');
   QryI.SQL.Add('From Associados');
   QryI.SQL.Add('Where Inscricao=:INSC and CPF=:CPF');
   QryI.ParamByName('INSC').AsString := Inscricao;
   QryI.ParamByName('CPF').AsString  := CPF;
   QryI.Active := true;

     result := not QryI.IsEmpty;


    except
      Result := false
   end;

 finally
  QryI.Destroy;
 end;


end;

function PreencheNome(Inscricao:string):TStringList;
var
 Qry :TFDQuery;
 Lista     :TStringList;
begin
 Try
  Try

   Qry := TFDQuery.Create(nil);
   Qry.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   Qry.Active := false;
   Qry.SQL.Clear;
   Qry.SQL.Add('Select D.Nome,A.Nome as Titular from Associados A  ');
   Qry.SQL.Add('Left Join Dependentes D on A.Inscricao=D.Inscricao');
   Qry.SQL.Add('where A.inscricao=:Insc and D.Falecimento is null and');
   Qry.SQL.Add('D.Status=1');
   Qry.ParamByName('Insc').AsString := Inscricao;
   Qry.Active := true;


   if not Qry.IsEmpty then
    begin
     Lista := TStringList.Create;
     Lista.Add(Qry.FieldByName('Titular').AsString);
      while not Qry.Eof do
       begin
        Lista.Add(Qry.FieldByName('Nome').AsString);
        Qry.Next;
       end;
    end;

   result := Lista;

  Finally

   FreeAndNil(Qry);

  End;
 Except

 End;
end;


function Get_LinhaDigitavel:string;
 var
 QryCp :TFDQuery;
begin

 try

   try
   QryCp := TFDQuery.Create(nil);
   QryCp.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryCp.Active := false;
   QryCp.SQL.Clear;
   QryCp.SQL.ADD('Select LinhaDigitavel ');
   QryCp.SQL.Add('From GoldPag_Boletos');
   QryCp.SQL.Add('Where ID='+UserSession.ID_Cadastro.ToString);
   QryCp.Active := true;


        result := QryCp.FieldByName('LinhaDigitavel').AsString;


    except
      Result := '';
   end;

 finally
  QryCp.Destroy;
 end;


end;

function Get_Comprovantes(Tipo:string):string;
 var
 QryCp :TFDQuery;
begin

 try

   try
   QryCp := TFDQuery.Create(nil);
   QryCp.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryCp.Active := false;
   QryCp.SQL.Clear;
   QryCp.SQL.ADD('Select CP.MotivoRecusa,CP.DataRegistro,CP.ID, ');
   QryCp.SQL.ADD('Case (CP.STATUS)                                   ');
   QryCp.SQL.ADD('When ''R'' THEN ''RECUSADO''                           ');
   QryCp.SQL.ADD('When ''P'' THEN ''AGUARDANDO''         ');
   QryCp.SQL.ADD('When ''A'' THEN ''APROVADO''  END as StatusSOL         ');
   QryCp.SQL.ADD('from GoldPag_Comprovante CP              ');
   QryCp.SQL.ADD('where inscricao = '''+UserSession.UserInscricao+'''   ');
   QryCp.SQL.Add('order by CP.DataRegistro desc');
   QryCp.Active := true;

     result :='<div class="row">';
     while not QryCp.Eof do
      begin
        result := result + MontaComprovante(QryCp.FieldByName('DataRegistro').AsString,
                                            QryCp.FieldByName('StatusSOL').AsString,
                                            QryCp.FieldByName('MotivoRecusa').AsString,
                                            '',
                                            QryCp.FieldByName('ID').asinteger.tostring);

        QryCp.Next;
      end;

      result := result + '</div>';
   except
      Result := '';
   end;

 finally
  QryCp.Destroy;
 end;


end;



function Get_Solicitacao_Equip:string;
var
 QryE :TFDQuery;
begin

 try

   try
   QryE := TFDQuery.Create(nil);
   QryE.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryE.Active := false;
   QryE.SQL.Clear;
   QryE.SQL.ADD('Select GE.Descricao, RQ.Observacao,RQ.MotivoRecusa,RQ.DataInsert,RQ.DataLimiteRetirada, ');
   QryE.SQL.ADD('Case (RQ.LocalRetirada)  ');
   QryE.SQL.ADD('When ''E'' THEN ''ENTREGAR NA RESIDENCIA'' ');
   QryE.SQL.ADD('When ''R'' THEN ''RETIRAR NA EMPRESA'' END as Retirada,');
   QryE.SQL.ADD('Case (RQ.STATUS)                                   ');
   QryE.SQL.ADD('When ''R'' THEN ''RECUSADO''                           ');
   QryE.SQL.ADD('When ''P'' THEN ''AGUARDANDO DISPONIBILIDADE''         ');
   QryE.SQL.ADD('When ''A'' THEN ''APROVADO''  END as StatusSOL         ');
   QryE.SQL.ADD('from GoldPag_RequisicaoEquipamento RQ              ');
   QryE.SQL.ADD('left join GrupoEquip  GE on GE.CodigoGrupoEquip=RQ.CodGrupoEquipamento ');
   QryE.SQL.ADD('where inscricao = '''+UserSession.UserInscricao+'''   ');
   QryE.SQL.Add('order by RQ.DATAINSERT desc');
   QryE.Active := true;

     result :='<div class="row">';
     while not QryE.Eof do
      begin
        result := result + MontaSolicitacaoEquip(QryE.FieldByName('Observacao').AsString,
                                            QryE.FieldByName('DataInsert').AsString,
                                            QryE.FieldByName('Retirada').asstring,
                                            QryE.FieldByName('StatusSOL').AsString,
                                            QryE.FieldByName('Descricao').AsString,
                                            QryE.FieldByName('MotivoRecusa').AsString,
                                            QryE.FieldByName('DataLimiteRetirada').AsString);

        QryE.Next;
      end;

      result := result + '</div>';
   except
      Result := '';
   end;

 finally
  QryE.Destroy;
 end;
end;

function Get_Equipamentos :TStringList;
var
 QryEsp    :TFDQuery;
 Lista     :TStringList;
begin
 Try
  Try

   QryEsp := TFDQuery.Create(nil);
   QryEsp.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryEsp.Active := false;
   QryEsp.SQL.Clear;
   QryEsp.SQL.Add('select E.DESCRICAO,E.CODIGOGRUPOEQUIP  ');
   QryEsp.SQL.Add('from GRUPOEQUIP E              ');
   QryEsp.SQL.Add('Order by E.Descricao');
   QryEsp.Active := true;


   if not QryEsp.IsEmpty then
    begin
     Lista := TStringList.Create;
      while not QryEsp.Eof do
       begin
        Lista.Add(QryEsp.FieldByName('DESCRICAO').AsString+'='+
                  QryEsp.FieldByName('CODIGOGRUPOEQUIP').AsString);
        QryEsp.Next;
       end;
    end;

   result := Lista;

  Finally

   FreeAndNil(QryEsp);

  End;
 Except

 End;
end;


function Get_DataAssinatura:string;
var
 QryAssi :TFDQuery;
begin

 try

   try
   QryAssi := TFDQuery.Create(nil);
   QryAssi.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryAssi.Active := false;
   QryAssi.SQL.Clear;
   QryAssi.SQL.ADD('Select  DataAssinatura');
   QryAssi.SQL.Add('From  AssociadosSeguroWeb');
   QryAssi.SQL.Add('Where Inscricao=:COD  ');
   QryAssi.ParamByName('COD').AsString := UserSession.UserInscricao;
   QryAssi.Active := true;

    if  QryAssi.FieldByName('DataAssinatura').AsString<>'' then
     begin
      Result := QryAssi.FieldByName('DataAssinatura').AsString;

     end else
      Result :='';

   except
      Result := '';
   end;

 finally
  QryAssi.Destroy;
 end;
end;


function Get_Localizacao:string;
 var
 QryAssi :TFDQuery;
begin

 try

   try
   QryAssi := TFDQuery.Create(nil);
   QryAssi.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryAssi.Active := false;
   QryAssi.SQL.Clear;
   QryAssi.SQL.ADD('Select  Id,IdSeq,Token,Pais,Estado,Cidade,Lat,Lon,IP,Assinatura');
   QryAssi.SQL.Add('From  AssociadosSeguroWeb');
   QryAssi.SQL.Add('Where Inscricao=:COD  ');
   QryAssi.ParamByName('COD').AsString := UserSession.UserInscricao;
   QryAssi.Active := true;

    if  QryAssi.FieldByName('ASSINATURA').AsString<>'' then
     begin
      Result := 'Token :' + QryAssi.FieldByName('Token').AsString + '-' +
                'Pais :' + QryAssi.FieldByName('Pais').AsString + '-' +
                'Estado :' + QryAssi.FieldByName('Estado').AsString + '-' +
                'Cidade :' + QryAssi.FieldByName('Cidade').AsString + '-' +
                'Lat :' + QryAssi.FieldByName('Lat').AsString + '-' +
                'Lon :' + QryAssi.FieldByName('Lon').AsString + '-' +
                'IP Origem  :' + QryAssi.FieldByName('IP').AsString + '-' ;

     end else
      Result :='';

   except
      Result := '';
   end;

 finally
  QryAssi.Destroy;
 end;
end;

function Get_TOKEN(Size, Tipo: Integer): String;
var
  I: Integer;
  Chave: String;
const
  str1 = '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  str2 = '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  str3 = '1234567890abcdefghijklmnopqrstuvwxyz';
  str4 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  str5 = '1234567890';
  str6 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  str7 = 'abcdefghijklmnopqrstuvwxyz';
  str8 = '-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';
begin
  Chave := '';

  for I := 1 to Size do
  begin
    case Tipo of
      1 : Chave := Chave + str1[Random(Length(str1)) + 1];
      2 : Chave := Chave + str2[Random(Length(str2)) + 1];
      3 : Chave := Chave + str3[Random(Length(str3)) + 1];
      4 : Chave := Chave + str4[Random(Length(str4)) + 1];
      5 : Chave := Chave + str5[Random(Length(str5)) + 1];
      6 : Chave := Chave + str6[Random(Length(str6)) + 1];
      7 : Chave := Chave + str7[Random(Length(str7)) + 1];
      8 : Chave := Chave + str7[Random(Length(str8)) + 1];
    end;
  end;

  Result := Chave;
end;

Function Get_Especialidade_Filtro(Especialidade:string):string;
var
 QryE    :TFDQuery;
begin
 Try
  Try

   QryE := TFDQuery.Create(nil);
   QryE.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryE.Active := false;
   QryE.SQL.Clear;
   QryE.SQL.Add('select E.Descricao ');
   QryE.SQL.Add('from Especialidades E             ');
   QryE.SQL.Add('Where E.Codigo='''+Especialidade+''' ');
   QryE.Active := true;


   if not QryE.IsEmpty then
    begin
    result :=  QryE.FieldByName('Descricao').AsString;
    end;


  Finally

   FreeAndNil(QryE);

  End;
 Except

 End;
end;



Function Get_Cidade_Filtro(Cidade:string):string;
var
 QryC    :TFDQuery;
begin
 Try
  Try

   QryC := TFDQuery.Create(nil);
   QryC.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryC.Active := false;
   QryC.SQL.Clear;
   QryC.SQL.Add('select CD.Nome ');
   QryC.SQL.Add('from Cidades CD             ');
   QryC.SQL.Add('Where CD.Codigo='''+Cidade+''' ');
   QryC.Active := true;


   if not QryC.IsEmpty then
    begin
    result :=  QryC.FieldByName('Nome').AsString;
    end;


  Finally

   FreeAndNil(QryC);

  End;
 Except

 End;
end;


Function GET_Conveniados_Endereco(Conveniado:string):string;
var
 QryC    :TFDQuery;
begin
 Try
  Try

   QryC := TFDQuery.Create(nil);
   QryC.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryC.Active := false;
   QryC.SQL.Clear;
   QryC.SQL.Add('select C.Endereco,C.Bairro,CD.Nome,C.CEP,CD.UF ');
   QryC.SQL.Add('from Conveniados C              ');
   QryC.SQL.Add('Left join Cidades CD on CD.Codigo=C.Cidade');
   QryC.SQL.Add('Where C.Codigo='''+Conveniado+''' ');
   QryC.Active := true;


   if not QryC.IsEmpty then
    begin
    result :=  MontaEndereco(QryC.FieldByName('Endereco').asstring,
                  QryC.FieldByName('Bairro').asstring,
                  QryC.FieldByName('Nome').asstring,
                  QryC.FieldByName('Uf').asstring,
                  QryC.FieldByName('Cep').AsString);
    end;


  Finally

   FreeAndNil(QryC);

  End;
 Except

 End;
end;


Function Get_Conveniados_Contato(Conveniado:string):string;
var
 QryC    :TFDQuery;
begin
 Try
  Try

   QryC := TFDQuery.Create(nil);
   QryC.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryC.Active := false;
   QryC.SQL.Clear;
   QryC.SQL.Add('select C.Telefone,C.Telefone2,C.Telefone3,Email ');
   QryC.SQL.Add('from Conveniados C              ');
   QryC.SQL.Add('Where C.Codigo='''+Conveniado+''' ');
   QryC.Active := true;


   if not QryC.IsEmpty then
    begin
    result :=  MontaContato(QryC.FieldByName('Telefone').asstring,
                  QryC.FieldByName('Telefone2').asstring,
                  QryC.FieldByName('Telefone3').asstring,
                  QryC.FieldByName('email').asstring);
    end;


  Finally

   FreeAndNil(QryC);

  End;
 Except

 End;
end;


Function Get_Conveniados_Especialidades(Conveniado:string):TStringList;
var
 QryEsp    :TFDQuery;
 Lista     :TStringList;
begin
 Try
  Try

   QryEsp := TFDQuery.Create(nil);
   QryEsp.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryEsp.Active := false;
   QryEsp.SQL.Clear;
   QryEsp.SQL.Add('select distinct CE.especialidade, E.Descricao  ');
   QryEsp.SQL.Add('from ConveniadosEspecialidades CE              ');
   QryEsp.SQL.Add('Left join Especialidades E on E.Codigo=CE.Especialidade');
   QryEsp.SQL.Add('Where CE.Conveniado='''+Conveniado+''' ');
   QryEsp.SQL.Add('Order by E.Descricao');
   QryEsp.Active := true;


   if not QryEsp.IsEmpty then
    begin
     Lista := TStringList.Create;
      while not QryEsp.Eof do
       begin
        Lista.Add(QryEsp.FieldByName('DESCRICAO').AsString);
        QryEsp.Next;
       end;
    end;

   result := Lista;

  Finally

   FreeAndNil(QryEsp);

  End;
 Except

 End;
end;

Function Get_Especialidade :TStringList;
var
 QryEsp    :TFDQuery;
 Lista     :TStringList;
begin
 Try
  Try

   QryEsp := TFDQuery.Create(nil);
   QryEsp.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryEsp.Active := false;
   QryEsp.SQL.Clear;
   QryEsp.SQL.Add('select distinct CE.especialidade, E.Descricao  ');
   QryEsp.SQL.Add('from ConveniadosEspecialidades CE              ');
   QryEsp.SQL.Add('Left join Especialidades E on E.Codigo=CE.Especialidade');
   QryEsp.SQL.Add('Order by E.Descricao');
   QryEsp.Active := true;


   if not QryEsp.IsEmpty then
    begin
     Lista := TStringList.Create;
      while not QryEsp.Eof do
       begin
        Lista.Add(QryEsp.FieldByName('DESCRICAO').AsString+'='+
                  QryEsp.FieldByName('ESPECIALIDADE').AsString);
        QryEsp.Next;
       end;
    end;

   result := Lista;

  Finally

   FreeAndNil(QryEsp);

  End;
 Except

 End;
end;



Function Get_Cidades    :TStringList;
var
 QryCidade :TFDQuery;
 Lista     :TStringList;
begin
 Try
  Try

   QryCidade := TFDQuery.Create(nil);
   QryCidade.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryCidade.Active := false;
   QryCidade.SQL.Clear;
   QryCidade.SQL.Add('SELECT distinct Conveniados.Cidade, Cidades.Nome,Cidades.Codigo ');
   QryCidade.SQL.Add('FROM Conveniados                                 ');
   QryCidade.SQL.Add('LEFT JOIN Cidades on Cidades.Codigo=Conveniados.Cidade');
   QryCidade.SQL.Add('WHERE Cidades.Nome is not  null ');
   QryCidade.SQL.Add('ORDER BY CIDADES.NOME');
   QryCidade.Active := true;


   if not QryCidade.IsEmpty then
    begin
     Lista := TStringList.Create;
      while not QryCidade.Eof do
       begin
        Lista.Add(QryCidade.FieldByName('NOME').AsString+'='+
                  QryCidade.FieldByName('CODIGO').AsString);
        QryCidade.Next;
       end;
    end;

   result := Lista;

  Finally

   FreeAndNil(QryCidade);

  End;
 Except

 End;
end;


Function Get_Conveniados(Cidade,Especialidade,Nome:string):string;
var
 QryC :TFDQuery;
begin

 try
   UserSession.FiltroCidades := Cidade;
   UserSession.FiltroEspecialidade := Especialidade;
   UserSession.FiltroNome  := Nome;

   try
   QryC := TFDQuery.Create(nil);
   QryC.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryC.Active := false;
   QryC.SQL.Clear;
   QryC.SQL.ADD('Select  Conveniados.*');
   QryC.SQL.Add('From  Conveniados');
   if Especialidade<>'' then
   QryC.SQL.Add('Left Join ConveniadosEspecialidades CE on CE.Conveniado=Conveniados.Codigo ');


   QryC.SQL.Add('Where StatusConv = ''ativo''  ');

   if Cidade<>'' then
   QryC.SQL.Add('and Conveniados.Cidade =' + Cidade);


   if Especialidade<>'' then
   QryC.SQL.Add('and CE.Especialidade =''' + Especialidade +''' ');

   if Nome<>'' then
   QryC.SQL.Add(' and  Conveniados.Conveniado like ''%'+StringReplace(UpperCase(Nome), ' ', '%', [rfReplaceAll])+'%'' ');




   QryC.SQL.Add('order by Conveniados.Conveniado');
   QryC.Active := true;

     result :='<div class="row">';
     while not QryC.Eof do
      begin
        result := result + MontaConveniados(QryC.FieldByName('Conveniado').AsString,
                                            QryC.FieldByName('Endereco').AsString,
                                            QryC.FieldByName('Telefone').asstring,
                                            QryC.FieldByName('Codigo').AsInteger);

        QryC.Next;
      end;

      result := result + '</div>';
   except
      Result := '';
   end;

 finally
  QryC.Destroy;
 end;
end;



Function Get_Status:string;
 var
 QryAssi :TFDQuery;
begin

 try

   try
   QryAssi := TFDQuery.Create(nil);
   QryAssi.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryAssi.Active := false;
   QryAssi.SQL.Clear;
   QryAssi.SQL.ADD('Select  Id,IdSeq,Inscricao,Assinatura,DataAssinatura,StatusWeb');
   QryAssi.SQL.Add('From  AssociadosSeguroWeb');
   QryAssi.SQL.Add('Where Inscricao=:COD  ');
   QryAssi.ParamByName('COD').AsString := UserSession.UserInscricao;
   QryAssi.Active := true;

    if  QryAssi.FieldByName('StatusWeb').AsString<>'' then
      Result :=  QryAssi.FieldByName('StatusWeb').AsString else
      Result := '';

   except
      Result := '';
   end;

 finally
  QryAssi.Destroy;
 end;
end;



function Get_base64: string;
 var
 QryAssi :TFDQuery;
begin

 try

   try
   QryAssi := TFDQuery.Create(nil);
   QryAssi.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryAssi.Active := false;
   QryAssi.SQL.Clear;
   QryAssi.SQL.ADD('Select  Id,IdSeq,Inscricao,Assinatura,DataAssinatura,StatusWeb');
   QryAssi.SQL.Add('From  AssociadosSeguroWeb');
   QryAssi.SQL.Add('Where Inscricao=:COD  ');
   QryAssi.ParamByName('COD').AsString := UserSession.UserInscricao;
   QryAssi.Active := true;

    if  QryAssi.FieldByName('ASSINATURA').AsString<>'' then
      Result :=  QryAssi.FieldByName('ASSINATURA').AsString else
      Result := '';

   except
      Result := '';
   end;

 finally
  QryAssi.Destroy;
 end;
end;

Function Get_Pendencia(Inscricao,Cpf:string):Boolean;
var
 QryPen :TFDQuery;
begin
 Try
  Result := True;
  Try

   QryPen := TFDQuery.Create(nil);
   QryPen.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryPen.Active := false;
   QryPen.SQL.Clear;
   QryPen.SQL.Add('Select SN.Inscricao,SN.CPF,SN.DATAInsert');
   QryPen.SQL.Add('from AssociadosSegurosNovo SN ');
   QryPen.SQL.Add('Left Join AssociadosSeguroWeb  SW on SW.IDSeq=SN.idSeq');
   QryPen.SQL.Add('where SN.CPF=:CPF AND (SW.STATUSWEB is Null or SW.STATUSWEB='''' )');
   QryPen.ParamByName('CPF').AsString := CPF;
   QryPen.Active := true;

   result := not QryPen.IsEmpty;

  Finally
   FreeAndNil(QryPen);
  End;
 except
  result:=false;
 End;
end;

Function GerarID(GEN:string):Integer;
var
 Qry :TFDQuery;
begin
 Try
  Result := 0;
  Try

   Qry := TFDQuery.Create(nil);
   Qry.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   Qry.Active := false;
   Qry.SQL.Clear;
   Qry.SQL.Add('select gen_id('+GEN+',1) as ID from rdb$database');
   Qry.Active := true;

   if not Qry.IsEmpty then
    Begin
     result:= Qry.FieldByName('ID').AsInteger;
    End;


  Finally
   FreeAndNil(Qry);
  End;
 except
  result:=0;
 End;
end;

Function AutenticarUsuario(Login:string;Senha:String;Tipo:String):Boolean;
var
 QryUser :TFDQuery;
begin
 Try
  Result := true;
  Try

   QryUser := TFDQuery.Create(nil);
   QryUser.Connection := Model.Connection.FConnList.Items[UserSession.FIndexConn];
   QryUser.Active := false;
   QryUser.SQL.Clear;
   QryUser.SQL.Add('SELECT A.NOME,AC.CPF, AC.LOGIN, AC.SENHA,AC.IDENTIFICADOR,AC.EMAIL,A.INSCRICAO');
   QryUser.SQL.Add('FROM GOLDPAG_ACESSO AC');
   QryUser.SQL.Add(' LEFT JOIN ASSOCIADOS A ON A.INSCRICAO=AC.IDENTIFICADOR ');
   QryUser.SQL.Add('WHERE AC.LOGIN=:USU ');
   QryUser.SQL.Add('AND AC.SENHA=:SEN');
   QryUser.ParamByName('USU').AsString := Login;
   QryUser.ParamByName('SEN').AsString := Senha;
   QryUser.Active := true;

   if not QryUser.IsEmpty then
    Begin
     UserSession.userId        := QryUser.FieldByName('IDENTIFICADOR').AsInteger;
     UserSession.userCPF       := QryUser.FieldByName('CPF').AsString;
     UserSession.UserLogado    := QryUser.FieldByName('NOME').AsString;
     UserSession.UserNome      := QryUser.FieldByName('NOME').AsString;
     UserSession.userEmail     := QryUser.FieldByName('EMAIL').AsString;
     UserSession.UserInscricao := QryUser.FieldByName('INSCRICAO').AsString;

    End;

   Result := not QryUser.IsEmpty;

  Finally
   FreeAndNil(QryUser);
  End;
 except
  result:=false;
 End;
end;




end.
