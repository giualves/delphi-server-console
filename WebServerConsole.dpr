program WebServerConsole;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Horse.Jhonson,
  uTituloController in 'controllers\uTituloController.pas',
  uTituloProvider in 'providers\uTituloProvider.pas' {DataModule1: TDataModule},
  uTituloService in 'services\uTituloService.pas' {dmTituloService: TDataModule},
  uConexao in 'providers\uConexao.pas' {Conexao: TDataModule};

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    //THorse.Get('/ping',
    //  procedure (Req: THorseRequest; Res: THorseResponse; Next: TProc)
    //  begin
    //    Res.Send('pong 2');
    //  end);

    ReportMemoryLeaksOnShutdown := True;

    THorse.Use(Jhonson);

    uTituloController.Registry;

    THorse.Listen(9000,
      procedure(Horse: THorse)
      begin
        WriteLn('Server rodando na porta: ' + THorse.Port.ToString);
        ReadLn;
        THorse.StopListen;
      end);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
