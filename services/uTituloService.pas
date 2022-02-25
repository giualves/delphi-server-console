unit uTituloService;

interface

uses
  ACBrBoleto, ACBrBoletoFCFortesFr, ACBrUtil,
  uConexao, JSON, uFuncoesStr, ACBrBoletoConversao, DataSet.Serialize,
  System.SysUtils, System.Classes, uTituloProvider, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Math;

type
  TTituloService = class(TConexao)
    qryCobConf: TFDQuery;
    qryTitulo: TFDMemTable;
    procedure DataModuleCreate(Sender: TObject);
  private
    Titulo: TACBrTitulo;
    Boleto: TACBrBoleto;
    ACBrBoletoReport: TACBrBoletoFCFortes;
    Beneficiario   : TACBrCedente;
    Banco          : TACBrBanco;
    WebService     : TACBrWebService;
    BeneficiarioWS : TACBrCedenteWS;
    CobAnterior    : TACBrTipoCobranca;
    procedure InicializarCobranca(CobConfId: integer);
    procedure InicializarTitulo(jsonTitulo: TJSONOBject);
  public
    function GetTitulo(TituloId: integer): TFDQuery;
    function GerarBoleto(nCobConfId: integer; jsonTitulo: TJSONOBject): String;
  end;

var
  TituloService: TTituloService;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TdmTituloService }
procedure TTituloService.DataModuleCreate(Sender: TObject);
begin
  inherited;
  Boleto := TACBrBoleto.Create(nil);

  ACBrBoletoReport := TACBrBoletoFCFortes.Create(nil);
  ACBrBoletoReport.DirLogo := ExtractFileDir(ParamStr(0)) + '\Imagens\';
  ACBrBoletoReport.NomeArquivo := 'tempboleto.dat';
  Boleto.ACBrBoletoFC := ACBrBoletoReport;
end;

function TTituloService.GerarBoleto(nCobConfId: integer;
  jsonTitulo: TJSONOBject): String;
begin


  WriteLn(jsonTitulo.ToJSON);
  InicializarCobranca(nCobConfId);
  InicializarTitulo(jsonTitulo);
  Boleto.GerarPDF;
  Result := jsonTitulo.ToJSON;


end;

function TTituloService.GetTitulo(TituloId: integer): TFDQuery;
begin
  //qryTitulo.Close;
  //qryTitulo.Params.ParamByName('ID').AsInteger := TituloId;
  //qryTitulo.Open();
  //Result := qryTitulo;
end;

procedure TTituloService.InicializarCobranca(CobConfId: integer);
begin

  qryCobConf.Close;
  qryCobConf.Params.ParamByName('COBCONF_ID').AsInteger := CobConfId;
  qryCobConf.Params.ParamByName('ESTAB_ID').AsInteger := 1;
  qryCobConf.Open();

  WebService := Boleto.Configuracoes.WebService;
  Boleto.ListadeBoletos.Clear;
  {
  Boleto.PrefixArqRemessa                  := edtPrefixRemessa.Text;
  Boleto.LayoutRemessa                     := TACBrLayoutRemessa(cbxCNAB.itemindex);
  Boleto.Homologacao                       := ckbEmHomologacao.Checked;

  Boleto.ImprimirMensagemPadrao            := ckbImprimirMensagemPadrao.Checked;
  Boleto.LeCedenteRetorno                  := ckbLerCedenteArquivoRetorno.Checked;
  Boleto.LerNossoNumeroCompleto            := ckbLerNossoNumeroCompleto.Checked;
  Boleto.RemoveAcentosArqRemessa           := ckbRemoverAcentuacaoRemessa.Checked;

       }

  Boleto.ACBrBoletoFC.LayOut := TACBrBolLayOut( qryCobConf.FieldByName('LAYOUTBOLETO').AsInteger );

  Beneficiario   := Boleto.Cedente;
  BeneficiarioWS := Beneficiario.CedenteWS;


  if (Pos('-',qryCobConf.FieldByName('AGENCIA').AsString) > 0) then
  begin
    Beneficiario.Agencia :=
      Copy(qryCobConf.FieldByName('AGENCIA').AsString,0,Pos('-',qryCobConf.FieldByName('AGENCIA').AsString)-1);
    Beneficiario.AgenciaDigito :=
      Copy(qryCobConf.FieldByName('AGENCIA').AsString,Pos('-',qryCobConf.FieldByName('AGENCIA').AsString)+1);
  end
  else
    Beneficiario.Agencia := qryCobConf.FieldByName('AGENCIA').AsString;

  Beneficiario.Conta                         := Copy(qryCobConf.FieldByName('CONTA').AsString,0,Pos('-',qryCobConf.FieldByName('CONTA').AsString)-1);
  Beneficiario.ContaDigito                   := Copy(qryCobConf.FieldByName('CONTA').AsString,Pos('-',qryCobConf.FieldByName('CONTA').AsString)+1);
  //Beneficiario.DigitoVerificadorAgenciaConta :=
  Beneficiario.Convenio                      := SoNumeros(qryCobConf.FieldByName('CONVENIO').AsString, True);
  Beneficiario.Modalidade                    := qryCobConf.FieldByName('MODCARTEIRA').AsString;

  {Definir Tipo de Opera��o para Registro de Cobran�a via WebService}
  //Beneficiario.Operacao                      := edtOperacao.Text;
  //Beneficiario.CodigoTransmissao             := edtCodigoTransmissao.Text;

  Beneficiario.CodigoCedente                 := Copy(qryCobConf.FieldByName('CONVENIO').AsString,0,Pos('-',  qryCobConf.FieldByName('CONVENIO').AsString)-1);
  Beneficiario.TipoInscricao                 := pJuridica ;
  Beneficiario.TipoDocumento                 := Tradicional; //TACBrTipoDocumento(cbxTipoDocumento.ItemIndex);

  Beneficiario.IdentDistribuicao             := tbClienteDistribui;//TACBrIdentDistribuicao(cbxTipoDistribuicao.itemIndex);
  Beneficiario.ResponEmissao                 := tbCliEmite;//TACBrResponEmissao(cbxResponsavelEmissao.ItemIndex);
  Beneficiario.CaracTitulo                   := tcSimples;//TACBrCaracTitulo(cbxCaracteristicaTitulo.itemIndex);

  Beneficiario.TipoCarteira                  := tctSimples; //TACBrTipoCarteira(cbxTipoCarteira.itemIndex);


  Beneficiario.CNPJCPF                       := qryCobConf.FieldByName('CNPJ').AsString;
  Beneficiario.Nome                          := qryCobConf.FieldByName('NOME').AsString;
  Beneficiario.FantasiaCedente               := qryCobConf.FieldByName('FANTASIA').AsString;
  Beneficiario.Logradouro                    := qryCobConf.FieldByName('LOGRADOURO').AsString;
  Beneficiario.NumeroRes                     := qryCobConf.FieldByName('NUMERO').AsString;
  //Beneficiario.Complemento                   := edtBenifComplemento.Text;
  Beneficiario.Bairro                        := qryCobConf.FieldByName('BAIRRO').AsString;
  Beneficiario.Cidade                        := qryCobConf.FieldByName('CIDADENOME').AsString;
  Beneficiario.UF                            := qryCobConf.FieldByName('SIGLA').AsString;
  Beneficiario.CEP                           := qryCobConf.FieldByName('CEP').AsString;
  Beneficiario.Telefone                      := qryCobConf.FieldByName('TELEFONE').AsString;


  Banco := Boleto.Banco;
  Banco.TipoCobranca        := TACBrTipoCobranca(qryCobConf.FieldByName('BANCO').AsInteger);
  Banco.TamanhoMaximoNossoNum := qryCobConf.FieldByName('DIGITOSNUMERO').AsInteger;
  Banco.Numero := qryCobConf.FieldByName('BANCO').AsInteger;
  //Banco.LayoutVersaoArquivo := StrToIntDef(edtCNABLVArquivo.Text,0);
  //Banco.LayoutVersaoLote    := StrToIntDef(edtCNABLVLote.Text,0);
  //Banco.CIP                 := edtCIP.Text;
  //Banco.DensidadeGravacao   := edtDensidadeGravacao.Text;

  //if (Banco.LocalPagamento <> edtLocalPag.Text) and (edtLocalPag.Text <> '') then
  //  Banco.LocalPagamento      := edtLocalPag.Text;

  //if edtLocalPag.Text = '' then
  //  edtLocalPag.Text := Banco.LocalPagamento;
  BeneficiarioWs.IndicadorPix := (qryCobConf.FieldByName('IS_UTILIZAPIX').AsString = 'S');
  if (BeneficiarioWs.IndicadorPix) and (qryCobConf.FieldByName('WSCLIENTID').AsString <> '') then
  begin
    BeneficiarioWS.ClientID     := qryCobConf.FieldByName('WSCLIENTID').AsString;
    BeneficiarioWS.ClientSecret := qryCobConf.FieldByName('WSCLIENTSECRET').AsString;
    //BeneficiarioWS.KeyUser      := edtKeyUser.Text;
    //WebService.Ambiente         := TpcnTipoAmbiente(Ord(ckbEmHomologacao.Checked));
  end;
end;

procedure TTituloService.InicializarTitulo(jsonTitulo: TJSONOBject);
var
  VQtdeCarcA, VQtdeCarcB, VQtdeCarcC :Integer;
  VLinha: string;
  i: Integer;
begin
  //qryTitulo.ClearFields;

  qryTitulo.LoadFromJSON(jsonTitulo.ToString);

  Titulo := Boleto.CriarTituloNaLista;

  Titulo.Vencimento        := StrToDate(qryTitulo.FieldByName('vencimento').AsString);
  Titulo.DataDocumento     := StrToDate(qryTitulo.FieldByName('datadoc').AsString);
  Titulo.NumeroDocumento   := qryTitulo.FieldByName('numerodoc').AsString;
  Titulo.EspecieDoc        := qryTitulo.FieldByName('especiedoc').AsString;

  if qryCobConf.FieldByName('ACEITEDOC').AsString = 'S' then
     Titulo.Aceite := atSim
  else
     Titulo.Aceite := atNao;

  Titulo.DataProcessamento := Now;

  Titulo.Carteira          := qryCobConf.FieldByName('CARTEIRA').AsString;
  Titulo.NossoNumero       := qryTitulo.FieldByName('nossonumero').AsString;
  Titulo.ValorDocumento    := qryTitulo.FieldByName('valordoc').AsCurrency;

  Titulo.Sacado.NomeSacado := qryTitulo.FieldByName('sacadonome').AsString;
  Titulo.Sacado.CNPJCPF    := OnlyNumber(qryTitulo.FieldByName('sacadocpfcpnj').AsString);
  Titulo.Sacado.Logradouro := qryTitulo.FieldByName('sacadologradouro').AsString;
  Titulo.Sacado.Numero     := qryTitulo.FieldByName('sacadonumero').AsString;
  Titulo.Sacado.Bairro     := qryTitulo.FieldByName('sacadobairro').AsString;
  Titulo.Sacado.Cidade     := qryTitulo.FieldByName('sacadocidade').AsString;
  Titulo.Sacado.UF         := qryTitulo.FieldByName('sacadouf').AsString;
  Titulo.Sacado.CEP        := OnlyNumber(qryTitulo.FieldByName('sacadocep').AsString);


  Titulo.ValorAbatimento   := 0;
  //objTitulo.LocalPagamento    := edtLocalPag.Text;
  Titulo.ValorMoraJuros    := RoundTo((Titulo.ValorDocumento * qryCobConf.FieldByName('PERCJUROS').AsCurrency / 100 / 30),-2);
//fValorDesconto := fValorDocumento * fPercDesconto / 100
  Titulo.ValorDesconto     := Titulo.ValorDocumento * qryCobConf.FieldByName('PERCDESCONTO').AsCurrency / 100;


  if (qryCobConf.FieldByName('DIASMULTA').AsInteger > 0) then
    Titulo.DataMoraJuros := Titulo.Vencimento + qryCobConf.FieldByName('DIASMULTA').AsInteger;

  Titulo.DataDesconto      := 0;
  Titulo.DataAbatimento    := 0;
  Titulo.DataProtesto      := Titulo.Vencimento + qryCobConf.FieldByName('DIASPRODEV').AsInteger;
  Titulo.PercentualMulta   := qryCobConf.FieldByName('PERCMULTA').AsCurrency;
  Titulo.CodigoMoraJuros   := cjIsento;
  //Mensagem.Text     := memMensagem.Text;
  Titulo.OcorrenciaOriginal.Tipo := toRemessaBaixar;
  Titulo.Instrucao1        := qryCobConf.FieldByName('CODINSTRUCAO1').AsString;
  Titulo.Instrucao2        := qryCobConf.FieldByName('CODINSTRUCAO2').AsString;

  Titulo.QtdePagamentoParcial   := 1;
  Titulo.TipoPagamento          := tpNao_Aceita_Valor_Divergente;
  Titulo.PercentualMinPagamento := 0;
  Titulo.PercentualMaxPagamento := 0;
  Titulo.ValorMinPagamento      := 0;
  Titulo.ValorMaxPagamento      := 0;
  //QrCode.emv := '00020101021226870014br.gov.bcb.pix2565qrcodepix-h.bb.com.br/pix/v2/22657e83-ecac-4631-a767-65e16fc56bff5204000053039865802BR5925EMPRORT AMBIENTAL        6008BRASILIA62070503***6304BD3D';

 // dm.ACBrBoleto.AdicionarMensagensPadroes(Titulo,Mensagem);

  if qryCobConf.FieldByName('LAYOUTBOLETO').AsInteger = 6 then
  begin
    for i:=0 to 3 do
    begin
      VLinha := '.';

      VQtdeCarcA := length('Descri��o Produto/Servi�o ' + IntToStr(I));
      VQtdeCarcB := Length('Valor:');
      VQtdeCarcC := 85 - (VQtdeCarcA + VQtdeCarcB);

      VLinha := PadLeft(VLinha,VQtdeCarcC,'.');

      Titulo.Detalhamento.Add('Descri��o Produto/Servi�o ' + IntToStr(I) + ' '+ VLinha + ' Valor:   '+  PadRight(FormatCurr('R$ ###,##0.00', Titulo.ValorDocumento * 0.25),18,' ') );
    end;
    Titulo.Detalhamento.Add('');
    Titulo.Detalhamento.Add('');
    Titulo.Detalhamento.Add('');
    Titulo.Detalhamento.Add('');
    Titulo.Detalhamento.Add('Desconto ........................................................................... Valor: R$ 0,00' );
  end;

  //if FileExists(SisConfig.LogoReport) then
  //  Titulo.ArquivoLogoEmp := SisConfig.LogoReport;

  //objTitulo.Verso := ((cbxImprimirVersoFatura.Checked) and ( cbxImprimirVersoFatura.Enabled = true ));

end;

end.
