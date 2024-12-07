unit UnitClientes.Model;

interface

uses
  {$IFDEF PORTALORM}
  UnitPortalORM.Model;
  {$ELSE}
  UnitBancoDeDados.Model;
  {$ENDIF}

type
  [TRecursoServidor('/clientes')]
  [TNomeTabela('CLIENTES', 'CLI_CODIGO')]
  TClientes = class(TTabela)
  private
    { private declarations }
    FCodigo: integer;
    FNome: string;
    FCnpj_cpf: string;
    FEndereco: string;    
  public
    { public declarations }
    [TCampo('CLI_CODIGO', 'INTEGER NOT NULL PRIMARY KEY')]
    property Codigo: integer read FCodigo write FCodigo;
    [TCampo('CLI_NOME', 'VARCHAR(100)')]
    property Nome: string read FNome write FNome;
    [TCampo('CLI_CNPJ_CPF', 'VARCHAR(18)')]
    property Cnpj_cpf: string read FCnpj_cpf write FCnpj_cpf;
    [TCampo('CLI_ENDERECO', 'VARCHAR(200)')]
    property Endereco: string read FEndereco write FEndereco;    
  end;

implementation

end.
