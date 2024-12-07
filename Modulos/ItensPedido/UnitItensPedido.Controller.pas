unit UnitItensPedido.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  System.Json, Horse.GBSwagger;

type
  TItensPedidoController = class
    class procedure Router;
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TItensPedidoController }

uses
  UnitConnection.Model.Interfaces,
  UnitDatabase,
  UnitFunctions,
  UnitItensPedido.Model,
  UnitTabela.Helper.Json, UnitConstants;

class procedure TItensPedidoController.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var ItensPedido: TItensPedido;
  id: Integer;
begin
  try
    id := Req.Params.Items['id'].ToInteger();
    ItensPedido := TItensPedido.Create(TDatabase.Connection);
    ItensPedido.Apagar(id);
    Res.Send('').Status(THTTPStatus.NoContent);
  finally
    ItensPedido.DisposeOf;
  end;
end;

class procedure TItensPedidoController.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var ItensPedido: TItensPedido;
    aJson: TJSONArray;
    Query: iQuery;
begin
  aJson := TJSONArray.Create;
  Query := TDatabase.Query;
  try
    ItensPedido := TItensPedido.Create(TDatabase.Connection);
    try
      ItensPedido.BuscaDadosTabela(GeraCodigo('ITENS_PEDIDO', 'IP_CODIGO')-1);
    except
      ItensPedido.BuscaDadosTabela(1);
    end;
    Query.Open('SELECT IP_CODIGO FROM ITENS_PEDIDO ORDER BY IP_CODIGO');
    Query.Dataset.First;
    while not Query.Dataset.Eof do
    begin
      ItensPedido.BuscaDadosTabela(Query.Dataset.FieldByName('IP_CODIGO').AsInteger);
      aJson.Add(ItensPedido.ToJsonObject);
      Query.Dataset.Next;
    end;
    Res.Send<TJSONArray>(aJson);
  finally
    ItensPedido.DisposeOf;
  end;
end;

class procedure TItensPedidoController.GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var ItensPedido: TItensPedido;
    aJson: TJSONArray;
    id: Integer;
begin
  aJson := TJSONArray.Create;
  id := Req.Params.Items['id'].ToInteger();
  try
    ItensPedido := TItensPedido.Create(TDatabase.Connection);
    ItensPedido.BuscaDadosTabela(id);
    Res.Send<TJSONObject>(ItensPedido.ToJsonObject);
  finally
    ItensPedido.DisposeOf;
  end;
end;

class procedure TItensPedidoController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var ItensPedido: TItensPedido;
  aJson: TJSONArray;
  i: Integer;
begin
  try
  	aJson := Req.Body<TJSONArray>;
    for i := 0 to Pred(aJson.Count) do
		begin
      ItensPedido := TItensPedido.Create(TDatabase.Connection).fromJson<TItensPedido>(aJson.Items[i].ToJSON);
      if ItensPedido.Codigo = 0 then
      	ItensPedido.Codigo := GeraCodigo('ITENS_PEDIDO', 'IP_CODIGO');
      ItensPedido.SalvaNoBanco(1);
    end;
    Res.Send<TJSONArray>(aJson);
  finally
    ItensPedido.DisposeOf;
  end;
end;

class procedure TItensPedidoController.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var ItensPedido: TItensPedido;
begin
  try
    ItensPedido := TItensPedido.Create(TDatabase.Connection).fromJson<TItensPedido>(Req.Body);
    ItensPedido.SalvaNoBanco(1);
    Res.Send<TJSONObject>(ItensPedido.ToJsonObject);
  finally
    ItensPedido.DisposeOf;
  end;
end;

class procedure TItensPedidoController.Router;
begin
  THorse.Group
        .Prefix('/v1')
        .Route('/itensPedido')
          .Get(Get)
          .Post(Post)
          .Put(Put)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/itensPedido/:id')
          .Get(GetForID)
          .Delete(Delete)
        .&End
end;

initialization
    Swagger
	.BasePath('v1')
    .Path('itensPedido')
      .Tag('ItensPedidos')
      .GET('Lista Todos(as)', 'Lista todos(as) os(as) ItensPedidos')
        .AddResponse(200, 'Operação bem Sucedida')
          .Schema(TItensPedido)
          .IsArray(True)
        .&End
        .AddResponse(400).&End
        .AddResponse(500).&End
      .&End
      .POST('Criar ItensPedido', 'Cria um(a) novo(a) ItensPedido')
        .AddParamBody('Dados do(a) ItensPedido', 'ItensPedido')
          .Required(True)
          .Schema(TItensPedido)
        .&End
        .AddResponse(201, 'Created')
          .Schema(TItensPedido)
        .&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
      .PUT('Atualiza ItensPedido', 'Atualiza os dados de um(a) ItensPedido')
        .AddParamBody('Dados do(a) ItensPedido', 'ItensPedido')
          .Required(True)
          .Schema(TItensPedido)
        .&End
        .AddResponse(200, 'Ok')
          .Schema(TItensPedido)
        .&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
    .&End
  .&End
  .BasePath('v1')
    .Path('itensPedido/{id}')
      .Tag('ItensPedidos')
      .GET('Obtem um(a) ItensPedido')
        .AddParamPath('id', 'Id do(a) ItensPedido para buscar')
          .Required(True)
          .Schema(SWAG_INTEGER)
        .&End
        .AddResponse(200, 'Operação bem Sucedida')
          .Schema(TItensPedido)
        .&End
        .AddResponse(404, 'ItensPedido não encontrado(a)').&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
      .DELETE('Apagar um(a) ItensPedido')
        .AddParamPath('id', 'id do(a) ItensPedido para deletar')
          .Required(True)
          .Schema(SWAG_INTEGER)
        .&End
        .AddResponse(404, 'ItensPedido não encontrado(a)').&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
    .&End
  .&End

end.
