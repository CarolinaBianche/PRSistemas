program PRSistemas;

uses
  System.StartUpCopy,
  FMX.Forms,
  ufrmLogin in '..\Source\Forms\ufrmLogin.pas' {FrmLogin},
  ufrmCadastro in '..\Source\Forms\ufrmCadastro.pas' {frmCadastro},
  PR.Classe.Pessoa in '..\Source\Classes\PR.Classe.Pessoa.pas',
  PR.funcoes in '..\Source\Library\PR.funcoes.pas',
  uDmRest in '..\Source\Rest\uDmRest.pas' {DmRest: TDataModule},
  ufrmEmail in '..\Source\Forms\ufrmEmail.pas' {FrmEmail},
  Model.Connection in '..\Source\Conexao\Model.Connection.pas',
  PR.Classe.Dados in '..\Source\Classes\PR.Classe.Dados.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmLogin, FrmLogin);
  Application.CreateForm(TDmRest, DmRest);
  Application.Run;
end.
