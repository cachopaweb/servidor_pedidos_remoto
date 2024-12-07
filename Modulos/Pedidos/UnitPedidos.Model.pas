unit UnitPedidos.Model;

interface

uses
  {$IFDEF PORTALORM}
  UnitPortalORM.Model, UnitItensPedido.Model;
  {$ELSE}
  UnitBancoDeDados.Model;
  {$ENDIF}

type
  [TRecursoServidor('/pedidos')]
  [TNomeTabela('PEDIDOS_SITE', 'PED_CODIGO')]
  TPedidos = class(TTabela)
  private
    { private declarations }
    FCodigo: integer;
    FFormas_pagamento: string;
    FEndereco_entrega: string;
    FCli: integer;
    FStatus: string;
    FFun: integer;
    FObs: string;
    FData: TDateTime;
    FValor: double;
    FMotivo_recusa: string;
    FItensPedido: TArray<TTabela>;
    FTipoPgm: integer;
    FEmitirNF: string;
  public
    { public declarations }
    [TCampo('PED_CODIGO', 'INTEGER NOT NULL PRIMARY KEY')]
    property Codigo: integer read FCodigo write FCodigo;
    [TCampo('PED_FORMAS_PAGAMENTO', 'VARCHAR(30)')]
    property Formas_pagamento: string read FFormas_pagamento write FFormas_pagamento;
    [TCampo('PED_ENDERECO_ENTREGA', 'VARCHAR(200)')]
    property Endereco_entrega: string read FEndereco_entrega write FEndereco_entrega;
    [TCampo('PED_CLI', 'INTEGER')]
    property Cli: integer read FCli write FCli;
    [TCampo('PED_STATUS', 'VARCHAR(30)')]
    property Status: string read FStatus write FStatus;
    [TCampo('PED_FUN', 'INTEGER')]
    property Fun: integer read FFun write FFun;
    [TCampo('PED_OBS', 'VARCHAR(500)')]
    property Obs: string read FObs write FObs;
    [TCampo('PED_DATA', 'DATE')]
    property Data: TDateTime read FData write FData;
    [TCampo('PED_VALOR', 'NUMERIC(9,2)')]
    property Valor: double read FValor write FValor;
    [TCampo('PED_MOTIVO_RECUSA', 'VARCHAR(100)')]
    property Motivo_recusa: string read FMotivo_recusa write FMotivo_recusa;
    [TCampo('PED_TP', 'INTEGER')]
    property TipoPgm: integer read FTipoPgm write FTipoPgm;
    [TCampo('PED_EMITIR_NF', 'CHAR(1)')]
    property EmitirNF: string read FEmitirNF write FEmitirNF;
    [TRelacionamento('ITENS_PEDIDO', 'IP_CODIGO', 'IP_PED', TItensPedido, TTipoRelacionamento.UmPraMuitos)]
		property ItensPedido: TArray<TTabela> read FItensPedido write FItensPedido;
  end;

implementation

end.
