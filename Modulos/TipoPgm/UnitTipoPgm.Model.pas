unit UnitTipoPgm.Model;

interface

uses
  {$IFDEF PORTALORM}
  UnitPortalORM.Model;
  {$ELSE}
  UnitBancoDeDados.Model;
  {$ENDIF}

type
  [TRecursoServidor('/tipoPgm')]
  [TNomeTabela('TIPO_PGM', 'TP_CODIGO')]
  TTipoPgm = class(TTabela)
  private
    { private declarations }
    FCodigo: integer;
    FDescricao: string;
    FCon: integer;
    FTipo: string;
    FNome: string;
    FTitulo: string;
    FCondicao: string;
    FDias_prazo_rec: integer;
    FTx_operacao: double;
    FTx_antecipacao: double;
    FSub_des: integer;
    FAnalisar: string;
  public
    { public declarations }
    [TCampo('TP_CODIGO', 'INTEGER NOT NULL PRIMARY KEY')]
    property Codigo: integer read FCodigo write FCodigo;
    [TCampo('TP_DESCRICAO', 'VARCHAR(20)')]
    property Descricao: string read FDescricao write FDescricao;
    [TCampo('TP_CON', 'SMALLINT')]
    property Con: integer read FCon write FCon;
    [TCampo('TP_TIPO', 'VARCHAR(2)')]
    property Tipo: string read FTipo write FTipo;
    [TCampo('TP_NOME', 'VARCHAR(2)')]
    property Nome: string read FNome write FNome;
    [TCampo('TP_TITULO', 'VARCHAR(1)')]
    property Titulo: string read FTitulo write FTitulo;
    [TCampo('TP_CONDICAO', 'CHAR(1)')]
    property Condicao: string read FCondicao write FCondicao;
    [TCampo('TP_DIAS_PRAZO_REC', 'SMALLINT')]
    property Dias_prazo_rec: integer read FDias_prazo_rec write FDias_prazo_rec;
    [TCampo('TP_TX_OPERACAO', 'NUMERIC(3,2)')]
    property Tx_operacao: double read FTx_operacao write FTx_operacao;
    [TCampo('TP_TX_ANTECIPACAO', 'NUMERIC(3,2)')]
    property Tx_antecipacao: double read FTx_antecipacao write FTx_antecipacao;
    [TCampo('TP_SUB_DES', 'INTEGER')]
    property Sub_des: integer read FSub_des write FSub_des;
    [TCampo('TP_ANALISAR', 'CHAR(1)')]
    property Analisar: string read FAnalisar write FAnalisar;
  end;

implementation

end.
