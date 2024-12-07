unit UnitLogin.Controller;

interface
uses
  Horse,
  Horse.Commons,
  Classes,
  SysUtils,
  System.Json,
  FireDAC.Comp.Client, UnitConnection.Model.Interfaces;

type
  TLoginController = class
  private
  public
    class procedure Router;
		class procedure Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
  end;

implementation

{ TLoginController }

uses
  UnitFunctions,
  UnitDatabase;

class procedure TLoginController.Post(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  oJson: TJSONObject;
  LoginJson: TJSONObject;
  Query: iQuery;
begin
  LoginJson := Req.Body<TJSONObject>;
  Query := TDatabase.Query;
  Query.Clear;
  Query.Add('SELECT USU_CODIGO, USU_LOGIN, FUN_CODIGO, FUN_NOME FROM USUARIOS ');
  Query.Add('JOIN FUNCIONARIOS ON USU_FUN = FUN_CODIGO WHERE USU_LOGIN = :LOGIN AND USU_SENHA = :SENHA');
  Query.AddParam('LOGIN', LoginJson.GetValue<string>('login'));
	Query.AddParam('SENHA', EnDecryptString(LoginJson.GetValue<string>('senha'), 236));
  Query.Open;
  if not Query.DataSet.IsEmpty then
  begin
    oJson := TJSONObject.Create;
    oJson.AddPair('codigo', TJSONNumber.Create(Query.DataSet.FieldByName('USU_CODIGO').AsInteger));
    oJson.AddPair('login', Query.DataSet.FieldByName('USU_LOGIN').AsString);
    oJson.AddPair('fun_codigo', TJSONNumber.Create(Query.DataSet.FieldByName('FUN_CODIGO').AsInteger));
    oJson.AddPair('nome', Query.DataSet.FieldByName('FUN_NOME').AsString);
    Res.Send<TJSONObject>(oJson);
  end else
    Res.Send<TJSONObject>(TJSONObject.Create.AddPair('error', 'usu�rio n�o autorizado'))
       .Status(THTTPStatus.Unauthorized);
end;

class procedure TLoginController.Router;
begin
  THorse
    .Group
    .Prefix('/v1')
		.Route('login')
			.Post(Post)
		.&End
end;

end.

