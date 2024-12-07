unit UnitPedidos.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  Horse.GBSwagger,
  System.Json, UnitItensPedido.Model;

type
  TPedidosController = class
    class procedure Router;
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TPedidosController }

uses
  UnitConnection.Model.Interfaces,
  UnitDatabase,
  UnitFunctions,
  UnitPedidos.Model,
  UnitTabela.Helper.Json, UnitConstants;

class procedure TPedidosController.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Pedidos: TPedidos;
  id: Integer;
begin
  try
    id := Req.Params.Items['id'].ToInteger();
    Pedidos := TPedidos.Create(TDatabase.Connection);
    Pedidos.Apagar(id);
    Res.Send('').Status(THTTPStatus.NoContent);
  finally
    Pedidos.DisposeOf;
  end;
end;

class procedure TPedidosController.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Pedidos: TPedidos;
    aJson: TJSONArray;
    Query: iQuery;
    Status: string;
begin
	Status := Req.Query.Items['status'];
  aJson := TJSONArray.Create;
  Query := TDatabase.Query;
  try
    Pedidos := TPedidos.Create(TDatabase.Connection);
    try
      Pedidos.BuscaDadosTabela(GeraCodigo('PEDIDOS_SITE', 'PED_CODIGO')-1);
    except
      Pedidos.BuscaDadosTabela(1);
    end;
    if not Status.IsEmpty then
    begin
    	Query.Open(Format('SELECT PED_CODIGO FROM PEDIDOS_SITE WHERE PED_STATUS = ''%s'' ORDER BY PED_CODIGO', [Status]));
    end else
    begin
      Query.Open('SELECT PED_CODIGO FROM PEDIDOS_SITE ORDER BY PED_CODIGO');    
    end;
    Query.Dataset.First;
    while not Query.Dataset.Eof do
    begin
      Pedidos.BuscaDadosTabela(Query.Dataset.FieldByName('PED_CODIGO').AsInteger);
      aJson.Add(Pedidos.ToJsonObject);
      Query.Dataset.Next;
    end;
    Res.Send<TJSONArray>(aJson);
  finally
    Pedidos.DisposeOf;
  end;
end;

class procedure TPedidosController.GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Pedidos: TPedidos;
    aJson: TJSONArray;
    id: Integer;
begin
  aJson := TJSONArray.Create;
  id := Req.Params.Items['id'].ToInteger();
  try
    Pedidos := TPedidos.Create(TDatabase.Connection);
    Pedidos.BuscaDadosTabela(id);
    Res.Send<TJSONObject>(Pedidos.ToJsonObject);
  finally
    Pedidos.DisposeOf;
  end;
end;

class procedure TPedidosController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Pedido: TPedidos;
  i: Integer;
begin
  try
    Pedido := TPedidos.Create(TDatabase.Connection).fromJson<TPedidos>(Req.Body);
    if Pedido.Codigo = 0 then
    	Pedido.Codigo := GeraCodigo('PEDIDOS_SITE', 'PED_CODIGO');
    Pedido.SalvaNoBanco(1);
    Res.Send<TJSONObject>(Pedido.ToJsonObject);
  finally
    Pedido.DisposeOf;
  end;
end;

class procedure TPedidosController.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Pedidos: TPedidos;
begin
  try
    Pedidos := TPedidos.Create(TDatabase.Connection).fromJson<TPedidos>(Req.Body);
    Pedidos.SalvaNoBanco(1);
    Res.Send<TJSONObject>(Pedidos.ToJsonObject);
  finally
    Pedidos.DisposeOf;
  end;
end;

class procedure TPedidosController.Router;
begin
  THorse.Group
        .Prefix('/v1')
        .Route('/pedidos')
          .Get(Get)
          .Post(Post)
          .Put(Put)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/pedidos/:id')
          .Get(GetForID)
          .Delete(Delete)
        .&End
end;

initialization
    Swagger
  .BasePath('v1')
    .Path('/pedidos')
      .Tag('Pedidos')
      .GET('Lista Todas', 'Lista todas as Pedidos')
        .AddResponse(200, 'Operação bem Sucedida')
          .Schema(TPedidos)
          .IsArray(True)
        .&End
        .AddParamQuery('status', 'Busca pelo Status do Pedido')
        	.Schema(SWAG_STRING)          
        .&End
        .AddResponse(400).&End
        .AddResponse(500).&End
      .&End
      .POST('Criar Pedido', 'Cria uma nova Pedido')
        .AddParamBody('Dados da Pedido', 'Pedido')
          .Required(True)
          .Schema(TPedidos)
        .&End
        .AddResponse(201, 'Created')
          .Schema(TPedidos)
        .&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
      .PUT('Atualiza Pedido', 'Atualiza os dados de uma Pedido')
        .AddParamBody('Dados da Pedido', 'Pedido')
          .Required(True)
          .Schema(TPedidos)
        .&End
        .AddResponse(200, 'Ok')
          .Schema(TPedidos)
        .&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
    .&End
  .&End
  .BasePath('v1')
    .Path('/pedidos/{id}')
      .Tag('Pedidos')
      .GET('Obtem uma Pedido')
        .AddParamPath('id', 'Id da Pedido para buscar')
          .Required(True)
          .Schema(SWAG_INTEGER)
        .&End
        .AddResponse(200, 'Operação bem Sucedida')
          .Schema(TPedidos)
        .&End
        .AddResponse(404, 'Pedido não encontrada').&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
      .DELETE('Apagar uma Pedido')
        .AddParamPath('id', 'id da Pedido para deletar')
          .Required(True)
          .Schema(SWAG_INTEGER)
        .&End
        .AddResponse(404, 'Pedido não encontrada').&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
    .&End
  .&End

  end.
