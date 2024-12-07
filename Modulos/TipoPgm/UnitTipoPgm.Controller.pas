unit UnitTipoPgm.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  System.Json, Horse.GBSwagger;

type
  TTipoPgmController = class
    class procedure Router;
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TTipoPgmController }

uses
  UnitConnection.Model.Interfaces,
  UnitDatabase,
  UnitFunctions,
  UnitTipoPgm.Model,
  UnitTabela.Helper.Json, UnitConstants;

class procedure TTipoPgmController.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var TipoPgm: TTipoPgm;
  id: Integer;
begin
  try
    id := Req.Params.Items['id'].ToInteger();
    TipoPgm := TTipoPgm.Create(TDatabase.Connection);
    TipoPgm.Apagar(id);
    Res.Send('').Status(THTTPStatus.NoContent);
  finally
    TipoPgm.DisposeOf;
  end;
end;

class procedure TTipoPgmController.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var TipoPgm: TTipoPgm;
    aJson: TJSONArray;
    Query: iQuery;
begin
  aJson := TJSONArray.Create;
  Query := TDatabase.Query;
  try
    TipoPgm := TTipoPgm.Create(TDatabase.Connection);
    try
      TipoPgm.BuscaDadosTabela(GeraCodigo('TIPO_PGM', 'TP_CODIGO')-1);
    except
      TipoPgm.BuscaDadosTabela(1);
    end;
    Query.Open('SELECT TP_CODIGO FROM TIPO_PGM WHERE TP_TIPO = ''R'' ORDER BY TP_CODIGO');
    Query.Dataset.First;
    while not Query.Dataset.Eof do
    begin
      TipoPgm.BuscaDadosTabela(Query.Dataset.FieldByName('TP_CODIGO').AsInteger);
      aJson.Add(TipoPgm.ToJsonObject);
      Query.Dataset.Next;
    end;
    Res.Send<TJSONArray>(aJson);
  finally
    TipoPgm.DisposeOf;
  end;
end;

class procedure TTipoPgmController.GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var TipoPgm: TTipoPgm;
    aJson: TJSONArray;
    id: Integer;
begin
  aJson := TJSONArray.Create;
  id := Req.Params.Items['id'].ToInteger();
  try
    TipoPgm := TTipoPgm.Create(TDatabase.Connection);
    TipoPgm.BuscaDadosTabela(id);
    Res.Send<TJSONObject>(TipoPgm.ToJsonObject);
  finally
    TipoPgm.DisposeOf;
  end;
end;

class procedure TTipoPgmController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var TipoPgm: TTipoPgm;
begin
  try
    TipoPgm := TTipoPgm.Create(TDatabase.Connection).fromJson<TTipoPgm>(Req.Body);
    TipoPgm.SalvaNoBanco(1);
    Res.Send<TJSONObject>(TipoPgm.ToJsonObject);
  finally
    TipoPgm.DisposeOf;
  end;
end;

class procedure TTipoPgmController.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var TipoPgm: TTipoPgm;
begin
  try
    TipoPgm := TTipoPgm.Create(TDatabase.Connection).fromJson<TTipoPgm>(Req.Body);
    TipoPgm.SalvaNoBanco(1);
    Res.Send<TJSONObject>(TipoPgm.ToJsonObject);
  finally
    TipoPgm.DisposeOf;
  end;
end;

class procedure TTipoPgmController.Router;
begin
  THorse.Group
        .Prefix('/v1')
        .Route('/tipoPgm')
          .Get(Get)
          .Post(Post)
          .Put(Put)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/tipoPgm/:id')
          .Get(GetForID)
          .Delete(Delete)
        .&End
end;

initialization
  Swagger
	.BasePath('v1')
    .Path('tipoPgm')
      .Tag('TipoPgm')
      .GET('Lista Todos(as)', 'Lista todos(as) os(as) TipoPgms')
        .AddResponse(200, 'Operação bem Sucedida')
          .Schema(TTipoPgm)
          .IsArray(True)
        .&End
        .AddResponse(400).&End
        .AddResponse(500).&End
      .&End
      .POST('Criar TipoPgm', 'Cria um(a) novo(a) TipoPgm')
        .AddParamBody('Dados do(a) TipoPgm', 'TipoPgm')
          .Required(True)
          .Schema(TTipoPgm)
        .&End
        .AddResponse(201, 'Created')
          .Schema(TTipoPgm)
        .&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
      .PUT('Atualiza TipoPgm', 'Atualiza os dados de um(a) TipoPgm')
        .AddParamBody('Dados do(a) TipoPgm', 'TipoPgm')
          .Required(True)
          .Schema(TTipoPgm)
        .&End
        .AddResponse(200, 'Ok')
          .Schema(TTipoPgm)
        .&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
    .&End
  .&End
  .BasePath('v1')
    .Path('tipoPgm/{id}')
      .Tag('TipoPgm')
      .GET('Obtem um(a) TipoPgm')
        .AddParamPath('id', 'Id do(a) TipoPgm para buscar')
          .Required(True)
          .Schema(SWAG_INTEGER)
        .&End
        .AddResponse(200, 'Operação bem Sucedida')
          .Schema(TTipoPgm)
        .&End
        .AddResponse(404, 'TipoPgm não encontrado(a)').&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
      .DELETE('Apagar um(a) TipoPgm')
        .AddParamPath('id', 'id do(a) TipoPgm para deletar')
          .Required(True)
          .Schema(SWAG_INTEGER)
        .&End
        .AddResponse(404, 'TipoPgm não encontrado(a)').&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
    .&End
  .&End

end.
