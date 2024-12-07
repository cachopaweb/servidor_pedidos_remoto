unit UnitUsuarios.Model;

interface

uses
  {$IFDEF PORTALORM}
  UnitPortalORM.Model,
  {$ELSE}
  UnitBancoDeDados.Model,
  {$ENDIF}
  REST.Json.Types;

type
  [TRecursoServidor('/usuarios')]
  [TNomeTabela('USUARIOS', 'USU_CODIGO')]
  TUsuarios = class(TTabela)
  private
    { private declarations }
    FCodigo: integer;
    FLogin: string;
    FFun: integer;
    FSenha: string;
    FisAdmin: string;
  public
    { public declarations }
    [TCampo('USU_CODIGO', 'INTEGER NOT NULL PRIMARY KEY')]
    property Codigo: integer read FCodigo write FCodigo;
    [TCampo('USU_LOGIN', 'VARCHAR(20)')]
    property Login: string read FLogin write FLogin;
    [TCampo('USU_FUN', 'SMALLINT')]
    property Fun: integer read FFun write FFun;
    [JSONMarshalledAttribute(false)]
    [TCampo('USU_SENHA', 'VARCHAR(30)')]
    property Senha: string read FSenha write FSenha;
    [TCampo('USU_EH_ADM', 'CHAR(1)')]
    property isAdmin: string read FisAdmin write FisAdmin;
  end;

implementation

end.
