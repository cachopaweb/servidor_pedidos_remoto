unit UnitCatalogo.Model;

interface

uses
	UnitPortalORM.Model,
  UnitProdutos.Model;

type
	[TNomeTabela('CATALOGO', 'CAT_CODIGO')]
	TCatalogo = class(TTabela)
	private
		FCodigo: integer;
    FCodProduto: integer;
    FPrecoVenda: Currency;
    FDataCadastro: TDateTime;
    FFunCadastrou: integer;
    FDataAlteracao: TDateTime;
    FCodUsuario: integer;
    FProduto: TProdutos;
	public
		[TCampo('CAT_CODIGO', 'INTEGER NOT NULL PRIMARY KEY')]
		property Codigo: integer read FCodigo write FCodigo;
    [TCampo('CAT_USU', 'INTEGER NOT NULL')]
    property CodUsuario: integer read FCodUsuario write FCodUsuario;
    [TCampo('CAT_PRO', 'INTEGER NOT NULL')]
    property CodProduto: integer read FCodProduto write FCodProduto;
    [TCampo('CAT_PRECO_VENDA', 'NUMERIC(9,2)')]
    property PrecoVenda: Currency read FPrecoVenda write FPrecoVenda;
    [TCampo('CAT_DATA_CADASTRO', 'TIMESTAMP')]
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
    [TCampo('CAT_DATA_ALTERACAO', 'TIMESTAMP')]
    property DataAlteracao: TDateTime read FDataAlteracao write FDataAlteracao;
    [TCampo('CAT_FUN_CADASTROU', 'INTEGER')]
    property FunCadastrou: integer read FFunCadastrou write FFunCadastrou;
    [TRelacionamento('PRODUTOS', 'PRO_CODIGO', 'CAT_PRO', TProdutos, TTipoRelacionamento.UmPraUm)]
    property Produto: TProdutos read FProduto write FProduto;
	end;

implementation

end.
