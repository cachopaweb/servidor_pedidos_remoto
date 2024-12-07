unit UnitProdutos.Model;

interface

uses
  {$IFDEF PORTALORM}
  UnitPortalORM.Model, UnitUnidadeMed.Model;
  {$ELSE}
  UnitBancoDeDados.Model;
  {$ENDIF}

type
  [TRecursoServidor('/produtos')]
  [TNomeTabela('PRODUTOS', 'PRO_CODIGO')]
  TProdutos = class(TTabela)
  private
    { private declarations }
    FCodigo: integer;
    FCodFor: integer;
    FQuantidade: double;
    FValorv: double;
    FCodbarra: string;
    FNome: string;
    FEstado: string;
    FUm: integer;
    FUnidadeMed: TUnidadeMed;
  public
    { public declarations }
    [TCampo('PRO_CODIGO', 'INTEGER NOT NULL PRIMARY KEY')]
    property Codigo: integer read FCodigo write FCodigo;
    [TCampo('PRO_FOR', 'SMALLINT')]
    property CodFor: integer read FCodFor write FCodFor;
    [TCampo('PRO_QUANTIDADE', 'NUMERIC(9,2)')]
    property Quantidade: double read FQuantidade write FQuantidade;
    [TCampo('PRO_VALORV', 'NUMERIC(9,4)')]
    property Valorv: double read FValorv write FValorv;
    [TCampo('PRO_CODBARRA', 'VARCHAR(30)')]
    property Codbarra: string read FCodbarra write FCodbarra;
    [TCampo('PRO_NOME', 'VARCHAR(200)')]
    property Nome: string read FNome write FNome;
    [TCampo('PRO_ESTADO', 'VARCHAR(8)')]
    property Estado: string read FEstado write FEstado;
    [TCampo('PRO_UM', 'SMALLINT')]
    property Um: integer read FUm write FUm;
    [TRelacionamento('UNIDADE_MED', 'UM_CODIGO', 'PRO_UM', TUnidadeMed, TTipoRelacionamento.UmPraUm)]
    property UnidadeMed: TUnidadeMed read FUnidadeMed write FUnidadeMed;
  end;

implementation

end.
