unit PR.Classe.Dados;

interface

uses
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages, System.Variants, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,Model.Connection,UFrmLogin,PR.Classe.Pessoa;

  Function gravar_pessoa(Nome,Identidade,Cpf,NomeMae,NomePai,Cep,Logradouro,
                        Numero,Complemento,Bairro,Cidade,Estado,Pais:string;CodigoPessoa:Integer):Boolean;
  Function Consultar_pessoa(IdPessoa:integer):TPessoa;



implementation

Function gravar_pessoa(Nome,Identidade,Cpf,NomeMae,NomePai,Cep,Logradouro,
                        Numero,Complemento,Bairro,Cidade,Estado,Pais:string;CodigoPessoa:Integer):Boolean;
var
 QryI:TFDQuery;
 idDados:integer;
 Transacao  : TFDTransaction;
begin

 try
   idDados:=0;
   try
     Transacao := TFDTransaction.Create(nil);

     Transacao.Connection :=  Model.Connection.FConnList.Items[FrmLogin.FIndexConn];

     Transacao.StartTransaction;

     QryI := TFDQuery.Create(nil);
     QryI.Connection := Model.Connection.FConnList.Items[FrmLogin.FIndexConn];
     QryI.Active := false;
     QryI.SQL.Clear;
     if CodigoPessoa=0 then
       begin
         QryI.SQL.ADD('INSERT INTO DADOS (Nome,Cpf,Rg,NomeMae,NomePai)');
         QryI.SQL.Add('  VALUES(:Nome,:Cpf,:Rg,:NomeMae,:NomePai)');
       end else
       begin
         QryI.SQL.ADD('UPDATE  DADOS ');
         QryI.SQL.ADD('SET Nome=:Nome,Cpf=:Cpf,Rg=:Rg,NomeMae=:NomeMae,NomePai=:NomePai ');
         QryI.SQL.ADD('WHERE ID=:ID');
         QryI.ParamByName('ID').AsInteger := CodigoPessoa;
       end;
     QryI.ParamByName('Nome').AsString    := Nome;
     QryI.ParamByName('Cpf').AsString     := Cpf;
     QryI.ParamByName('Rg').AsString      := Identidade;
     QryI.ParamByName('NomeMae').AsString := NomeMae;
     QryI.ParamByName('NomePai').AsString := NomePai;
     try
       QryI.ExecSQL;
     except
       Transacao.Rollback;
     end;
   //
    if CodigoPessoa=0 then
      begin
       QryI.Active := false;
       QryI.SQL.Clear;
       QryI.SQL.ADD('Select (ISNULL(Max(id),0)) as QTD FROM DADOS');
       QryI.Open;
       idDados := QryI.FieldByName('QTD').AsInteger;
      end else
      idDados:= CodigoPessoa;
   //
     QryI.Active := false;
     QryI.SQL.Clear;
     if CodigoPessoa=0 then
       begin
         QryI.SQL.ADD('INSERT INTO DadosEndereco (idDados,Endereco,Bairro,Cidade,Estado,Pais,Cep,Numero)');
         QryI.SQL.Add('  VALUES(:idDados,:Endereco,:Bairro,:Cidade,:Estado,:Pais,:Cep,:Numero)');
       end
       else
       begin
         QryI.SQL.ADD('UPDATE DadosEndereco');
         QryI.SQL.ADD('SET idDados=:idDados,Endereco=:Endereco,Bairro=:Bairro,Cidade=:Cidade,Estado=:Estado,Pais=:Pais,Cep=:Cep,Numero=:Numero ');
         QryI.SQL.Add('WHERE IdDados=:Id');
         QryI.ParamByName('Id').AsInteger := idDados;
       end;


     QryI.ParamByName('idDados').AsInteger:= idDados;
     QryI.ParamByName('Endereco').AsString:= Logradouro;
     QryI.ParamByName('Bairro').AsString  := Bairro;
     QryI.ParamByName('Cidade').AsString  := Cidade;
     QryI.ParamByName('Estado').AsString  := Estado;
     QryI.ParamByName('Pais').AsString    := Pais;
     QryI.ParamByName('Cep').AsString     := Cep;
     QryI.ParamByName('Numero').AsString  := Numero;

     QryI.ExecSQL;
     Transacao.Commit;
   except
     Transacao.Rollback;
     Result := false
   end;

 finally
  QryI.Destroy;
 end;


end;

Function Consultar_pessoa(IdPessoa:integer):TPessoa;
var
 QryC:TFDQuery;
 Dados : TPessoa;
 DadosEnd :TEndereco;
Begin
 QryC := TFDQuery.Create(nil);
 QryC.Connection := Model.Connection.FConnList.Items[FrmLogin.FIndexConn];
 QryC.Active := false;
 QryC.SQL.Clear;
 QryC.SQL.ADD('SELECT D.ID,D.NOME, D.RG,D.CPF,D.NOMEPAI,D.NOMEMAE,');
 QryC.SQL.Add('DE.ENDERECO,DE.NUMERO,DE.BAIRRO,DE.CIDADE,DE.ESTADO,DE.PAIS,DE.CEP,DE.COMPLEMENTO,CEP');
 QryC.SQL.ADD('FROM Dados D');
 QryC.SQL.Add('LEFT JOIN DadosEndereco DE on D.Id= DE.IdDados  ');
 QryC.SQL.Add('WHERE D.ID=:ID');
 QryC.ParamByName('ID').AsInteger := IdPessoa;
 QryC.Open;

 if not QryC.IsEmpty then
  Begin
   try
     Dados := TPessoa.Create;
     Dados.Codigo := QryC.FieldByName('ID').AsInteger;
     Dados.Nome := QryC.FieldByName('Nome').AsString;
     Dados.Identidade := QryC.FieldByName('RG').AsString;
     Dados.CPF := QryC.FieldByName('Cpf').AsString;
     Dados.NomeMae:= QryC.FieldByName('NomeMae').AsString;
     Dados.NomePai:= QryC.FieldByName('NomePai').AsString;

     DadosEnd := TEndereco.Create;
     DadosEnd.Logradouro := QryC.FieldByName('Endereco').AsString;
     DadosEnd.Numero := QryC.FieldByName('Numero').AsString;
     DadosEnd.Bairro := QryC.FieldByName('Bairro').AsString;
     DadosEnd.Cidade := QryC.FieldByName('Cidade').AsString;
     DadosEnd.Estado := QryC.FieldByName('Estado').AsString;
     DadosEnd.Pais   := QryC.FieldByName('Pais').AsString;
     DadosEnd.Complemento := QryC.FieldByName('Complemento').AsString;
     DadosEnd.Cep    := QryC.FieldByName('Cep').AsString;

     Dados.Endereco := DadosEnd;



     Result := Dados;
   finally

   end;
  End;
End;

end.
