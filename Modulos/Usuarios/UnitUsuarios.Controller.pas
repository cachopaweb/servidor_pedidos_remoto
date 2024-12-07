unit UnitUsuarios.Controller;

interface

uses
	Horse,
	Horse.Commons,
	Classes,
	SysUtils,
	System.Json,
	Horse.GBSwagger, UnitProdutos.Model, UnitCatalogo.Model;

type
	TUsuariosController = class
		class procedure Router;
		class procedure Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
		class procedure GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
		class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
		class procedure Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
		class procedure Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
	end;

implementation

{ TUsuariosController }

uses
	UnitConnection.Model.Interfaces,
	UnitDatabase,
	UnitFunctions,
	UnitUsuarios.Model,
	UnitTabela.Helper.Json, UnitConstants, System.Generics.Collections;

class procedure TUsuariosController.Delete(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
	Usuarios: TUsuarios;
	id      : Integer;
begin
	try
		id       := Req.Params.Items['id'].ToInteger();
		Usuarios := TUsuarios.Create(TDatabase.Connection);
		Usuarios.Apagar(id);
		Res.Send('').Status(THTTPStatus.NoContent);
	finally
		Usuarios.DisposeOf;
	end;
end;

class procedure TUsuariosController.Get(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
	Usuarios: TUsuarios;
	aJson   : TJSONArray;
	Query   : iQuery;
begin
	aJson := TJSONArray.Create;
	Query := TDatabase.Query;
	try
		Usuarios := TUsuarios.Create(TDatabase.Connection);
		try
			Usuarios.BuscaDadosTabela(GeraCodigo('USUARIOS', 'USU_CODIGO') - 1);
		except
			Usuarios.BuscaDadosTabela(1);
		end;
		Query.Open('SELECT USU_CODIGO FROM USUARIOS ORDER BY USU_CODIGO');
		Query.Dataset.First;
		while not Query.Dataset.Eof do
		begin
			Usuarios.BuscaDadosTabela(Query.Dataset.FieldByName('USU_CODIGO').AsInteger);
			aJson.Add(Usuarios.ToJsonObject);
			Query.Dataset.Next;
		end;
		Res.Send<TJSONArray>(aJson);
	finally
		Usuarios.DisposeOf;
	end;
end;

class procedure TUsuariosController.GetForID(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
	Usuarios: TUsuarios;
	aJson   : TJSONArray;
	id      : Integer;
begin
	aJson := TJSONArray.Create;
	id    := Req.Params.Items['id'].ToInteger();
	try
		Usuarios := TUsuarios.Create(TDatabase.Connection);
		Usuarios.BuscaDadosTabela(id);
		Res.Send<TJSONObject>(Usuarios.ToJsonObject);
	finally
		Usuarios.DisposeOf;
	end;
end;

class procedure TUsuariosController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
	Usuarios     : TUsuarios;
	ListaProdutos: TList<TProdutos>;
	prod         : TProdutos;
	Catalogo     : TCatalogo;
begin
	try
		Usuarios := TUsuarios.Create(TDatabase.Connection).fromJson<TUsuarios>(Req.Body);
		Usuarios.SalvaNoBanco(1);
		// vincula o novo usuario aos produtos no catalogo
		ListaProdutos := TProdutos.Create(TDatabase.Connection).PreencheListaWhere<TProdutos>('PRO_ESTADO = ''ATIVO'' AND PRO_TIPO_ITEM = ''00''');
		try
			for prod in ListaProdutos do
			begin
				// cria novo catalogo
				try
					Catalogo               := TCatalogo.Create(TDatabase.Connection);
					Catalogo.Codigo        := GeraCodigo('CATALOGO', 'CAT_CODIGO');
					Catalogo.CodUsuario    := Usuarios.Codigo;
					Catalogo.CodProduto    := prod.Codigo;
					Catalogo.PrecoVenda    := prod.Valorv;
					Catalogo.DataCadastro  := Now;
					Catalogo.DataAlteracao := Now;
					Catalogo.FunCadastrou  := 1;
					Catalogo.SalvaNoBanco();
				finally
					Catalogo.DisposeOf;
				end;
			end;
		finally
			ListaProdutos.DisposeOf;
		end;
		Res.Send<TJSONObject>(Usuarios.ToJsonObject);
	finally
		Usuarios.DisposeOf;
	end;
end;

class procedure TUsuariosController.Put(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
	Usuarios: TUsuarios;
begin
	try
		Usuarios := TUsuarios.Create(TDatabase.Connection).fromJson<TUsuarios>(Req.Body);
		Usuarios.SalvaNoBanco(1);
		Res.Send<TJSONObject>(Usuarios.ToJsonObject);
	finally
		Usuarios.DisposeOf;
	end;
end;

class procedure TUsuariosController.Router;
begin
	THorse.Group.Prefix('/v1').Route('/usuarios').Get(Get).Post(Post).Put(Put).&End.Group.Prefix('/v1').Route('/usuarios/:id').Get(GetForID).Delete(Delete).&End
end;

initialization

Swagger.BasePath('v1').Path('usuarios').Tag('Usuarios').Get('Lista Todas', 'Lista todos os Usuarios').AddResponse(200, 'Operação bem Sucedida').Schema(TUsuarios).IsArray(True).&End.AddResponse(400).&End.AddResponse(500).&End.&End.Post('Criar Usuario', 'Cria um novo Usuario').AddParamBody('Dados da Usuario', 'Usuario').Required(True).Schema(TUsuarios).&End.AddResponse(201, 'Created').Schema(TUsuarios).&End.AddResponse(400, 'BadRequest').Schema(TAPIError).&End.AddResponse(500).&End.&End.Put('Atualiza Usuario', 'Atualiza os dados de um Usuario').AddParamBody('Dados da Usuario', 'Usuario').Required(True).Schema(TUsuarios).&End.AddResponse(200, 'Ok').Schema(TUsuarios).&End.AddResponse(400, 'BadRequest').Schema(TAPIError).&End.AddResponse(500).&End.&End.&End.&End.BasePath('v1')
	.Path('usuarios/{id}').Tag('Usuarios').Get('Obtem uma Usuario').AddParamPath('id', 'Id do Usuario para buscar').Required(True).Schema(SWAG_INTEGER).&End.AddResponse(200, 'Operação bem Sucedida').Schema(TUsuarios).&End.AddResponse(404, 'Usuario não encontrada').&End.AddResponse(400, 'BadRequest').Schema(TAPIError).&End.AddResponse(500).&End.&End.Delete('Apagar uma Usuario').AddParamPath('id', 'id do Usuario para deletar').Required(True).Schema(SWAG_INTEGER).&End.AddResponse(404, 'Usuario não encontrada').&End.AddResponse(400, 'BadRequest').Schema(TAPIError).&End.AddResponse(500).&End.&End.&End.&End

end.
