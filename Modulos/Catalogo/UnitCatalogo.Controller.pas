unit UnitCatalogo.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  System.Json, Horse.GBSwagger;

type
  TCatalogoController = class
    class procedure Router;
    class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  private
    class procedure GetForUserID(Req: THorseRequest; Res: THorseResponse;
      Next: TProc); static;
  end;

implementation

{ TCatalogoController }

uses
  UnitConnection.Model.Interfaces,
  UnitDatabase,
  UnitFunctions,
  UnitCatalogo.Model,
  UnitTabela.Helper.Json, UnitConstants, System.Generics.Collections;

class procedure TCatalogoController.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Catalogo: TCatalogo;
  id: Integer;
begin
  try
    id := Req.Params.Items['id'].ToInteger();
    Catalogo := TCatalogo.Create(TDatabase.Connection);
    Catalogo.Apagar(id);
    Res.Send('').Status(THTTPStatus.NoContent);
  finally
    Catalogo.DisposeOf;
  end;
end;

class procedure TCatalogoController.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Catalogo: TCatalogo;
    aJson: TJSONArray;
    Query: iQuery;
begin
  aJson := TJSONArray.Create;
  Query := TDatabase.Query;
  try
    Catalogo := TCatalogo.Create(TDatabase.Connection);
    try
      Catalogo.BuscaDadosTabela(GeraCodigo('CATALOGO', 'CAT_CODIGO')-1);
    except
      Catalogo.BuscaDadosTabela(1);
    end;
    Query.Open('SELECT CAT_CODIGO FROM CATALOGO ORDER BY CAT_CODIGO');
    Query.Dataset.First;
    while not Query.Dataset.Eof do
    begin
      Catalogo.BuscaDadosTabela(Query.Dataset.FieldByName('CAT_CODIGO').AsInteger);
      aJson.Add(Catalogo.ToJsonObject);
      Query.Dataset.Next;
    end;
    Res.Send<TJSONArray>(aJson);
  finally
    Catalogo.DisposeOf;
  end;
end;

class procedure TCatalogoController.GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Catalogo: TCatalogo;
    aJson: TJSONArray;
    id: Integer;
begin
  aJson := TJSONArray.Create;
  id := Req.Params.Items['id'].ToInteger();
  try
    Catalogo := TCatalogo.Create(TDatabase.Connection);
    Catalogo.BuscaDadosTabela(id);
    Res.Send<TJSONObject>(Catalogo.ToJsonObject);
  finally
    Catalogo.DisposeOf;
  end;
end;

class procedure TCatalogoController.GetForUserID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var aJson: TJSONArray;
    id: Integer;
    ListaCatalogo: TList<TCatalogo>;
    Catalogo: TCatalogo;
begin
  aJson := TJSONArray.Create;
  id := Req.Params.Items['id'].ToInteger();
  ListaCatalogo := TCatalogo.Create(TDatabase.Connection).PreencheListaWhere<TCatalogo>(Format('CAT_USU = %d', [id]));
  try
    aJson := TJSONArray.Create;
    for Catalogo in ListaCatalogo do
    begin
    	aJson.AddElement(Catalogo.ToJsonObject);
    end;
    Res.Send<TJSONArray>(aJson);
  finally
    ListaCatalogo.DisposeOf;
  end;
end;

class procedure TCatalogoController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Catalogo: TCatalogo;
begin
  try
    Catalogo := TCatalogo.Create(TDatabase.Connection).fromJson<TCatalogo>(Req.Body);
    Catalogo.SalvaNoBanco(1);
    Res.Send<TJSONObject>(Catalogo.ToJsonObject);
  finally
    Catalogo.DisposeOf;
  end;
end;

class procedure TCatalogoController.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Catalogo: TCatalogo;
begin
  try
    Catalogo := TCatalogo.Create(TDatabase.Connection).fromJson<TCatalogo>(Req.Body);
    Catalogo.SalvaNoBanco(1);
    Res.Send<TJSONObject>(Catalogo.ToJsonObject);
  finally
    Catalogo.DisposeOf;
  end;
end;

class procedure TCatalogoController.Router;
begin
  THorse.Group
        .Prefix('/v1')
        .Route('/catalogo')
          .Get(Get)
          .Post(Post)
          .Put(Put)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/catalogo/:id')
          .Get(GetForID)
          .Delete(Delete)
        .&End
        .Group
        .Prefix('/v1')
        .Route('/catalogo/usuario/:id')
          .Get(GetForUserID)
        .&End
end;

initialization
    Swagger
	.BasePath('v1')
    .Path('catalogo')
      .Tag('Catalogos')
      .GET('Lista Todas', 'Listagem do Catalogo')
        .AddResponse(200, 'Operação bem Sucedida')
          .Schema(TCatalogo)
          .IsArray(True)
        .&End
        .AddResponse(400).&End
        .AddResponse(500).&End
      .&End
      .POST('Criar Catalogo', 'Cria um novo Catalogo')
        .AddParamBody('Dados da Catalogo', 'Catalogo')
          .Required(True)
          .Schema(TCatalogo)
        .&End
        .AddResponse(201, 'Created')
          .Schema(TCatalogo)
        .&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
      .PUT('Atualiza Catalogo', 'Atualiza os dados de um Catalogo')
        .AddParamBody('Dados da Catalogo', 'Catalogo')
          .Required(True)
          .Schema(TCatalogo)
        .&End
        .AddResponse(200, 'Ok')
          .Schema(TCatalogo)
        .&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
    .&End
  .&End
  .BasePath('v1')
    .Path('catalogo/{id}')
      .Tag('Catalogos')
      .GET('Obtem um Catalogo')
        .AddParamPath('id', 'Id do Catalogo para buscar')
          .Required(True)
          .Schema(SWAG_INTEGER)
        .&End
        .AddResponse(200, 'Operação bem Sucedida')
          .Schema(TCatalogo)
        .&End
        .AddResponse(404, 'Catalogo não encontrado').&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
      .DELETE('Apagar uma Catalogo')
        .AddParamPath('id', 'id do Catalogo para deletar')
          .Required(True)
          .Schema(SWAG_INTEGER)
        .&End
        .AddResponse(404, 'Catalogo não encontrado').&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End
      .&End
    .&End
  .&End
  .BasePath('v1')
    .Path('catalogo/usuario/{id}')
      .Tag('Catalogos')
      .GET('Obtem o Catalogo do usuario')
        .AddParamPath('id', 'Id do usuario para buscar')
          .Required(True)
          .Schema(SWAG_INTEGER)
        .&End
        .AddResponse(200, 'Operação bem Sucedida')
          .Schema(TCatalogo)
          .IsArray(true)
        .&End
        .AddResponse(404, 'Catalogos não encontrados').&End
        .AddResponse(400, 'BadRequest')
          .Schema(TAPIError)
        .&End
        .AddResponse(500).&End      
      .&End
    .&End
  .&End

end.
