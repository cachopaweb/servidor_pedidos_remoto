unit UnitUnidadeMed.Model;

interface

uses
  {$IFDEF PORTALORM}
  UnitPortalORM.Model;
  {$ELSE}
  UnitBancoDeDados.Model;
  {$ENDIF}

type
  [TRecursoServidor('/unidadeMed')]
  [TNomeTabela('UNIDADE_MED', 'UM_CODIGO')]
  TUnidadeMed = class(TTabela)
  private
    { private declarations }
    FCodigo: integer;
    FUnidade: string;
    FDescricao: string;
  public
    { public declarations }
    [TCampo('UM_CODIGO', 'INTEGER NOT NULL PRIMARY KEY')]
    property Codigo: integer read FCodigo write FCodigo;
    [TCampo('UM_UNIDADE', 'VARCHAR(3)')]
    property Unidade: string read FUnidade write FUnidade;
    [TCampo('UM_DESCRICAO', 'VARCHAR(20)')]
    property Descricao: string read FDescricao write FDescricao;
  end;

implementation

end.
