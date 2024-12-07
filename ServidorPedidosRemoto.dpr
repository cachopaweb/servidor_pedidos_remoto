program ServidorPedidosRemoto;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Json,
  Horse,
  Horse.CORS,
  Horse.Jhonson,
  Horse.GBSwagger,
  UnitItensPedido.Model in 'Modulos\ItensPedido\UnitItensPedido.Model.pas',
  UnitPedidos.Model in 'Modulos\Pedidos\UnitPedidos.Model.pas',
  UnitClientes.Model in 'Modulos\Clientes\UnitClientes.Model.pas',
  UnitPedidos.Controller in 'Modulos\Pedidos\UnitPedidos.Controller.pas',
  UnitDatabase in 'Database\UnitDatabase.pas',
  UnitConstants in 'Utils\UnitConstants.pas',
  UnitFunctions in 'Utils\UnitFunctions.pas',
  UnitProdutos.Model in 'Modulos\Produtos\UnitProdutos.Model.pas',
  UnitProdutos.Controller in 'Modulos\Produtos\UnitProdutos.Controller.pas',
  UnitCatalogo.Model in 'Modulos\Catalogo\UnitCatalogo.Model.pas',
  UnitCatalogo.Controller in 'Modulos\Catalogo\UnitCatalogo.Controller.pas',
  UnitUsuarios.Model in 'Modulos\Usuarios\UnitUsuarios.Model.pas',
  UnitUsuarios.Controller in 'Modulos\Usuarios\UnitUsuarios.Controller.pas',
  UnitUnidadeMed.Model in 'Modulos\UnidadeMed\UnitUnidadeMed.Model.pas',
  UnitLogin.Controller in 'Modulos\Login\UnitLogin.Controller.pas',
  UnitItensPedido.Controller in 'Modulos\ItensPedido\UnitItensPedido.Controller.pas',
  UnitClientes.Controller in 'Modulos\Clientes\UnitClientes.Controller.pas',
  UnitTipoPgm.Model in 'Modulos\TipoPgm\UnitTipoPgm.Model.pas',
  UnitTipoPgm.Controller in 'Modulos\TipoPgm\UnitTipoPgm.Controller.pas';

begin
	//middlewares
  THorse.Use(CORS)
  			.Use(Jhonson)
        .Use(HorseSwagger); // Access http://localhost:3333/swagger/doc/html
  //documentation
  Swagger
    .Info
      .Title('Pedidos Remotos')
      .Description('Projeto para realizar pedidos remotos')
      .Contact
        .Name('Portal.com')
        .Email('portalsoft.com@gmail.com.br')
        .URL('https://www.portalsoft.net.br')
      .&End
    .&End;

  //controllers  
  TPedidosController.Router;
  TItensPedidoController.Router;
  TCatalogoController.Router;
  TProdutosController.Router;
  TUsuariosController.Router;
  TLoginController.Router; 
  TClientesController.Router;
  TTipoPgmController.Router;
   

  //start server      
  THorse.Listen(3333, 
  procedure 
  begin 
  	Writeln('Server is running on port '+THorse.Port.ToString);
  end);  
end.
