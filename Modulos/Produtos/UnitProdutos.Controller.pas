unit UnitProdutos.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  Horse.GBSwagger,
  System.Json;

type
  TProdutosController = class
    class procedure Router;
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TProdutosController }

uses
  UnitConnection.Model.Interfaces,
  UnitDatabase,
  UnitFunctions,
  UnitProdutos.Model,
  UnitTabela.Helper.Json, UnitConstants;

class procedure TProdutosController.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Produtos: TProdutos;
  id: Integer;
begin
  try
    id := Req.Params.Items['id'].ToInteger();
    Produtos := TProdutos.Create(TDatabase.Connection);
    Produtos.Apagar(id);
    Res.Send('').Status(THTTPStatus.NoContent);
  finally
    Produtos.DisposeOf;
  end;
end;

class procedure TProdutosController.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Produtos: TProdutos;
    aJson: TJSONArray;
    Query: iQuery;
begin
  aJson := TJSONArray.Create;
  Query := TDatabase.Query;
  try
    Produtos := TProdutos.Create(TDatabase.Connection);
    Produtos.CriaTabela;
    Query.Open('SELECT PRO_CODIGO FROM PRODUTOS WHERE PRO_ESTADO = ''ATIVO'' AND PRO_TIPO_ITEM = ''00'' ORDER BY PRO_CODIGO');
    Query.Dataset.First;
    while not Query.Dataset.Eof do
    begin
      Produtos.BuscaDadosTabela(Query.Dataset.FieldByName('PRO_CODIGO').AsInteger);
      aJson.Add(Produtos.ToJsonObject);
      Query.Dataset.Next;
    end;
    Res.Send<TJSONArray>(aJson);
  finally
    Produtos.DisposeOf;
  end;
end;

class procedure TProdutosController.GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Produtos: TProdutos;
    aJson: TJSONArray;
    id: Integer;
begin
  aJson := TJSONArray.Create;
  id := Req.Params.Items['id'].ToInteger();
  try
    Produtos := TProdutos.Create(TDatabase.Connection);
    Produtos.BuscaDadosTabela(id);
    Res.Send<TJSONObject>(Produtos.ToJsonObject);
  finally
    Produtos.DisposeOf;
  end;
end;

class procedure TProdutosController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Produtos: TProdutos;
begin
  try
    Produtos := TProdutos.Create(TDatabase.Connection).fromJson<TProdutos>(Req.Body);
    Produtos.SalvaNoBanco(1);
    Res.Send<TJSONObject>(Produtos.ToJsonObject);
  finally
    Produtos.DisposeOf;
  end;
end;

class procedure TProdutosController.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Produtos: TProdutos;
begin
  try
    Produtos := TProdutos.Create(TDatabase.Connection).fromJson<TProdutos>(Req.Body);
    Produtos.SalvaNoBanco(1);
    Res.Send<TJSONObject>(Produtos.ToJsonObject);
  finally
    Produtos.DisposeOf;
  end;
end;

class procedure TProdutosController.Router;
begin
  THorse.Group
        .Prefix('/v1')
        .Route('/produtos')
          .Get(Get)
          .Post(Post)
          .Put(Put)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/produtos/:id')
          .Get(GetForID)
          .Delete(Delete)
        .&End
end;

initialization
    Swagger
	.BasePath('v1')
    .Path('produtos')
      .Tag('Produtos')
      .GET('Lista Todas', 'Lista todas os Produtos')
        .AddResponse(200, 'Operação bem Sucedida')
          .Schema(TProdutos)
          .IsArray(True)
        .&End
        .AddResponse(400).&End
        .AddResponse(500).&End
      .&End
      .POST('Criar Produto', 'Cria um novo Produto')
        .AddParamBody('Dados da Produto', 'Produto')
          .Required(True)
          .Schema(TProdutos)
        .&End
        .AddResponse(201, 'Created')
          .Schema(TProdutos)
        .&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
      .PUT('Atualiza Produto', 'Atualiza os dados de um Produto')
        .AddParamBody('Dados da Produto', 'Produto')
          .Required(True)
          .Schema(TProdutos)
        .&End
        .AddResponse(200, 'Ok')
          .Schema(TProdutos)
        .&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
    .&End
  .&End
  .BasePath('v1')
    .Path('produtos/{id}')
      .Tag('Produtos')
      .GET('Obtem um Produto')
        .AddParamPath('id', 'Id do Produto para buscar')
          .Required(True)
          .Schema(SWAG_INTEGER)
        .&End
        .AddResponse(200, 'Operação bem Sucedida')
          .Schema(TProdutos)
        .&End
        .AddResponse(404, 'Produto não encontrada').&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
      .DELETE('Apagar uma Produto')
        .AddParamPath('id', 'id da Produto para deletar')
          .Required(True)
          .Schema(SWAG_INTEGER)
        .&End
        .AddResponse(404, 'Produto não encontrado').&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
    .&End
  .&End

end.
