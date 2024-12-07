unit UnitClientes.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  System.Json, Horse.GBSwagger;

type
  TClientesController = class
    class procedure Router;
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TClientesController }

uses
  UnitConnection.Model.Interfaces,
  UnitDatabase,
  UnitFunctions,
  UnitClientes.Model,
  UnitTabela.Helper.Json, UnitConstants;

class procedure TClientesController.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Clientes: TClientes;
  id: Integer;
begin
  try
    id := Req.Params.Items['id'].ToInteger();
    Clientes := TClientes.Create(TDatabase.Connection);
    Clientes.Apagar(id);
    Res.Send('').Status(THTTPStatus.NoContent);
  finally
    Clientes.DisposeOf;
  end;
end;

class procedure TClientesController.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Clientes: TClientes;
    aJson: TJSONArray;
    Query: iQuery;
begin
  aJson := TJSONArray.Create;
  Query := TDatabase.Query;
  try
    Clientes := TClientes.Create(TDatabase.Connection);
    try
      Clientes.BuscaDadosTabela(GeraCodigo('CLIENTES', 'CLI_CODIGO')-1);
    except
      Clientes.BuscaDadosTabela(1);
    end;
    Query.Open('SELECT FIRST 10 CLI_CODIGO FROM CLIENTES ORDER BY CLI_CODIGO');
    Query.Dataset.First;
    while not Query.Dataset.Eof do
    begin
      Clientes.BuscaDadosTabela(Query.Dataset.FieldByName('CLI_CODIGO').AsInteger);
      aJson.Add(Clientes.ToJsonObject);
      Query.Dataset.Next;
    end;
    Res.Send<TJSONArray>(aJson);
  finally
    Clientes.DisposeOf;
  end;
end;

class procedure TClientesController.GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Clientes: TClientes;
    aJson: TJSONArray;
    id: Integer;
begin
  aJson := TJSONArray.Create;
  id := Req.Params.Items['id'].ToInteger();
  try
    Clientes := TClientes.Create(TDatabase.Connection);
    Clientes.BuscaDadosTabela(id);
    Res.Send<TJSONObject>(Clientes.ToJsonObject);
  finally
    Clientes.DisposeOf;
  end;
end;

class procedure TClientesController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Clientes: TClientes;
begin
  try
    Clientes := TClientes.Create(TDatabase.Connection).fromJson<TClientes>(Req.Body);
    Clientes.SalvaNoBanco(1);
    Res.Send<TJSONObject>(Clientes.ToJsonObject);
  finally
    Clientes.DisposeOf;
  end;
end;

class procedure TClientesController.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Clientes: TClientes;
begin
  try
    Clientes := TClientes.Create(TDatabase.Connection).fromJson<TClientes>(Req.Body);
    Clientes.SalvaNoBanco(1);
    Res.Send<TJSONObject>(Clientes.ToJsonObject);
  finally
    Clientes.DisposeOf;
  end;
end;

class procedure TClientesController.Router;
begin
  THorse.Group
        .Prefix('/v1')
        .Route('/clientes')
          .Get(Get)
          .Post(Post)
          .Put(Put)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/clientes/:id')
          .Get(GetForID)
          .Delete(Delete)
        .&End
end;

initialization
        Swagger
    	.BasePath('v1')
        .Path('clientes')
          .Tag('Clientes')
          .GET('Lista Todos(as)', 'Lista todos(as) os(as) Clientes')
            .AddResponse(200, 'Operação bem Sucedida')
              .Schema(TClientes)
              .IsArray(True)
            .&End
            .AddResponse(400).&End
            .AddResponse(500).&End
          .&End
          .POST('Criar Cliente', 'Cria um(a) novo(a) Cliente')
            .AddParamBody('Dados do(a) Cliente', 'Cliente')
              .Required(True)
              .Schema(TClientes)
            .&End
            .AddResponse(201, 'Created')
              .Schema(TClientes)
            .&End
            .AddResponse(400, 'BadRequest')
              .Schema(TAPIError)
            .&End
            .AddResponse(500).&End
          .&End
          .PUT('Atualiza Cliente', 'Atualiza os dados de um(a) Cliente')
            .AddParamBody('Dados do(a) Cliente', 'Cliente')
              .Required(True)
              .Schema(TClientes)
            .&End
            .AddResponse(200, 'Ok')
              .Schema(TClientes)
            .&End
            .AddResponse(400, 'BadRequest')
              .Schema(TAPIError)
            .&End
            .AddResponse(500).&End
          .&End
        .&End
      .&End
      .BasePath('v1')
        .Path('clientes/{id}')
          .Tag('Clientes')
          .GET('Obtem um(a) Cliente')
            .AddParamPath('id', 'Id do(a) Cliente para buscar')
              .Required(True)
              .Schema(SWAG_INTEGER)
            .&End
            .AddResponse(200, 'Operação bem Sucedida')
              .Schema(TClientes)
            .&End
            .AddResponse(404, 'Cliente não encontrado(a)').&End
            .AddResponse(400, 'BadRequest')
              .Schema(TAPIError)
            .&End
            .AddResponse(500).&End
          .&End
          .DELETE('Apagar um(a) Cliente')
            .AddParamPath('id', 'id do(a) Cliente para deletar')
              .Required(True)
              .Schema(SWAG_INTEGER)
            .&End
            .AddResponse(404, 'Cliente não encontrado(a)').&End
            .AddResponse(400, 'BadRequest')
              .Schema(TAPIError)
            .&End
            .AddResponse(500).&End
          .&End
        .&End
      .&End
    
end.
