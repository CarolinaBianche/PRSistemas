create table Dados (
  id int identity primary key,
  Nome varchar(100), 
  Cpf  varchar(20), 
  Rg   varchar(20), 
  NomeMae varchar(100), 
  NomePai varchar(100)

);

create table DadosEndereco (
  id int identity primary key,
  idDados int ,
  Endereco varchar(100), 
  Bairro  varchar(50), 
  Cidade   varchar(50), 
  Numero varchar(10), 
  Estado varchar(20),
  Pais varchar(20),
  Complemento varchar(100),
  Cep varchar(10)
);

ALTER TABLE DadosEndereco
   ADD CONSTRAINT FK_Dados_Endereco FOREIGN KEY (IdDados)
      REFERENCES Dados (Id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
;
