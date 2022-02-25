unit uTituloController;

interface

procedure Registry;

implementation

uses Horse, System.JSON, uTituloService, DataSet.Serialize, SysUtils, Ragna;


procedure DoGetTitulos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Titulos: TTituloService;
  TituloId: integer;
begin

  Titulos := TTituloService.Create;
  try
    TituloId := Req.Params.Items['titulo_id'].ToInteger;
    Res.Send(Titulos.GetTitulo(tituloId).ToJSONArray());
  finally
    Titulos.Free;
  end;

end;

procedure DoPostTitulo(Req: THorseRequest; Resp: THorseResponse; Next: TProc);
var
  tituloService: TTituloService;
  cobConfID: integer;
begin
  tituloService := TTituloService.Create;
  try
    cobConfId := Req.Params['cobconf_id'].ToInteger;
    Resp.Send(tituloService.GerarBoleto(cobConfId, Req.Body<TJSONObject>)).Status(THTTPStatus.Created);
  finally
    tituloService.Free;
  end;
end;


procedure Registry;
begin
  THorse.Get('/titulos/:titulo_id', DoGetTitulos);
  THorse.Post('/titulos/boletoGerar/:cobconf_id', DoPostTitulo);
end;

end.
