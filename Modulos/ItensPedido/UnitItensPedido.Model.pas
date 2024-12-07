unit UnitItensPedido.Model;

interface

uses
  {$IFDEF PORTALORM}
  UnitPortalORM.Model;
  {$ELSE}
  UnitBancoDeDados.Model;
  {$ENDIF}

type
  [TRecursoServidor('/itensPedido')]
  [TNomeTabela('ITENS_PEDIDO', 'IP_CODIGO')]
  TItensPedido = class(TTabela)
  private
    { private declarations }
    FCodigo: integer;
    FPro: integer;
    FQuantidade: double;
    FValor: double;
    FPed: integer;
    FNome: string;
  public
    { public declarations }
    [TCampo('IP_CODIGO', 'INTEGER NOT NULL PRIMARY KEY')]
    property Codigo: integer read FCodigo write FCodigo;
    [TCampo('IP_PRO', 'INTEGER')]
    property Pro: integer read FPro write FPro;
    [TCampo('IP_QUANTIDADE', 'NUMERIC(9,2)')]
    property Quantidade: double read FQuantidade write FQuantidade;
    [TCampo('IP_VALOR', 'NUMERIC(9,2)')]
    property Valor: double read FValor write FValor;
    [TCampo('IP_PED', 'INTEGER')]
    property Ped: integer read FPed write FPed;
    [TCampo('IP_NOME', 'VARCHAR(200)')]
    property Nome: string read FNome write FNome;
  end;

implementation

end.
