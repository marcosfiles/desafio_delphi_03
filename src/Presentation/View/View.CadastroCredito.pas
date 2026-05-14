unit View.CadastroCredito;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, View.CadastroBase, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Grids, App.Container,
  Core.Services.Credito.Intf, Core.Services.Produtor.Intf,
  Core.Services.Distribuidor.Intf, Core.Services.Negociacao.Intf,
  Domain.CreditoProdutorDistribuidor, Domain.Produtor, Domain.Distribuidor,
  System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection;

type
  TfrmCredito = class(TfrmCadastroBase)
    pnlCabecalho: TPanel;
    pnlBotoes: TFlowPanel;
    btnNovo: TSpeedButton;
    btnEditar: TSpeedButton;
    btnSalvar: TSpeedButton;
    btnCancelar: TSpeedButton;
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edtCodigo: TEdit;
    Label2: TLabel;
    cmbProdutor: TComboBox;
    Label3: TLabel;
    cmbDistribuidor: TComboBox;
    Label4: TLabel;
    edtLimiteCredito: TEdit;
    GroupBox2: TGroupBox;
    grdCreditos: TStringGrid;
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  private
    FContainer: TAppContainer;
    FCreditoService: ICreditoService;
    FProdutorService: IProdutorService;
    FDistribuidorService: IDistribuidorService;
    FNegociacaoService: INegociacaoService;
    FProdutores: TObjectList<TProdutor>;
    FDistribuidores: TObjectList<TDistribuidor>;
    FIdCreditoAntesOperacao: Integer;

    procedure ConfigurarTela;
    procedure ConfigurarGrid;
    procedure CarregarCombos;
    procedure CarregarCreditoSelecionado;
    procedure SelecionarCreditoNaGrid(AIdCredito: Integer);
    procedure SelecionarProdutorCombo(AIdProdutor: Integer);
    procedure SelecionarDistribuidorCombo(AIdDistribuidor: Integer);
    procedure grdCreditosDblClick(Sender: TObject);
    procedure grdCreditosSelectCell(
      Sender: TObject;
      ACol: Longint;
      ARow: Longint;
      var CanSelect: Boolean
    );
    function CriarCreditoDaTela: TCreditoProdutorDistribuidor;
    function IdSelecionado: Integer;
    function IdProdutorSelecionado: Integer;
    function IdDistribuidorSelecionado: Integer;
    function LinhaSelecionadaValida: Boolean;
    function LimiteCreditoInformado: Currency;
    function NomeProdutorPorId(AIdProdutor: Integer): string;
    function NomeDistribuidorPorId(AIdDistribuidor: Integer): string;
    function TextoCreditoDisponivel(
      ACredito: TCreditoProdutorDistribuidor
    ): string;
  protected
    procedure Novo; override;
    procedure Editar; override;
    procedure Cancelar; override;
    procedure CarregarLista; override;
    procedure LimparCampos; override;
    procedure HabilitarCampos(AHabilitar: Boolean); override;
    procedure HabilitarBotoes; override;
    procedure ValidarCampos; override;
    procedure PersistirDados; override;
    function PodeSalvar: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmCredito: TfrmCredito;

implementation

{$R *.dfm}

function TextoParaCurrency(const AValor: string; out AResultado: Currency): Boolean;
var
  LTexto: string;
  LNormalizado: string;
  LCasasDecimais: Integer;
  LSeparadorDecimal: Integer;
  LQuantidadeSeparadores: Integer;
  LFormatSettings: TFormatSettings;
  I: Integer;
begin
  AResultado := 0;
  LTexto := Trim(AValor);
  LTexto := StringReplace(LTexto, 'R$', '', [rfReplaceAll, rfIgnoreCase]);
  LTexto := StringReplace(LTexto, ' ', '', [rfReplaceAll]);

  if LTexto = '' then
    Exit(False);

  LSeparadorDecimal := LastDelimiter(',.', LTexto);

  if LSeparadorDecimal > 0 then
  begin
    LQuantidadeSeparadores := 0;
    for I := 1 to Length(LTexto) do
      if CharInSet(LTexto[I], ['.', ',']) then
        Inc(LQuantidadeSeparadores);

    LCasasDecimais := Length(LTexto) - LSeparadorDecimal;
    if (LQuantidadeSeparadores = 1) and (LCasasDecimais > 2) then
      LCasasDecimais := 0;

    LNormalizado := '';

    for I := 1 to Length(LTexto) do
      if CharInSet(LTexto[I], ['0'..'9']) or
        ((LTexto[I] = '-') and (I = 1)) then
        LNormalizado := LNormalizado + LTexto[I];

    if LCasasDecimais > 0 then
      Insert('.', LNormalizado, Length(LNormalizado) - LCasasDecimais + 1);
  end
  else
    LNormalizado := LTexto;

  LFormatSettings := TFormatSettings.Create;
  LFormatSettings.DecimalSeparator := '.';
  LFormatSettings.ThousandSeparator := ',';

  Result := TryStrToCurr(LNormalizado, AResultado, LFormatSettings);
end;

function FormatarValor(const AValor: Currency): string;
begin
  Result := FormatCurr('R$ #,##0.00', AValor);
end;

{ TfrmCredito }

constructor TfrmCredito.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FIdCreditoAntesOperacao := 0;

  ConfigurarTela;

  if csDesigning in ComponentState then
    Exit;

  FContainer := TAppContainer.Create;
  FCreditoService := FContainer.CreditoService;
  FProdutorService := FContainer.ProdutorService;
  FDistribuidorService := FContainer.DistribuidorService;
  FNegociacaoService := FContainer.NegociacaoService;

  CarregarCombos;
  CarregarLista;
  Modo := mcNavegacao;
end;

destructor TfrmCredito.Destroy;
begin
  FCreditoService := nil;
  FProdutorService := nil;
  FDistribuidorService := nil;
  FNegociacaoService := nil;
  FProdutores.Free;
  FDistribuidores.Free;
  FContainer.Free;

  inherited Destroy;
end;

procedure TfrmCredito.ConfigurarTela;
begin
  Caption := 'Limites de Credito';

  Panel1.Caption := '';
  pnlBotoes.Caption := '';

  edtCodigo.ReadOnly := True;
  edtCodigo.TabStop := False;
  cmbProdutor.Style := csDropDownList;
  cmbDistribuidor.Style := csDropDownList;

  ConfigurarGrid;
  LimparCampos;
end;

procedure TfrmCredito.ConfigurarGrid;
begin
  grdCreditos.FixedCols := 0;
  grdCreditos.FixedRows := 1;
  grdCreditos.ColCount := 5;
  grdCreditos.RowCount := 2;
  grdCreditos.DefaultRowHeight := 24;
  grdCreditos.Options := grdCreditos.Options + [goRowSelect] - [goEditing];
  grdCreditos.OnDblClick := grdCreditosDblClick;
  grdCreditos.OnSelectCell := grdCreditosSelectCell;

  grdCreditos.Cells[0, 0] := 'Codigo';
  grdCreditos.Cells[1, 0] := 'Produtor';
  grdCreditos.Cells[2, 0] := 'Distribuidor';
  grdCreditos.Cells[3, 0] := 'Limite de credito';
  grdCreditos.Cells[4, 0] := 'Credito disponivel';

  grdCreditos.ColWidths[0] := 80;
  grdCreditos.ColWidths[1] := 220;
  grdCreditos.ColWidths[2] := 220;
  grdCreditos.ColWidths[3] := 130;
  grdCreditos.ColWidths[4] := 130;
end;

procedure TfrmCredito.CarregarCombos;
var
  I: Integer;
begin
  if (not Assigned(FProdutorService)) or
    (not Assigned(FDistribuidorService)) then
    Exit;

  FreeAndNil(FProdutores);
  FreeAndNil(FDistribuidores);

  FProdutores := FProdutorService.ListarTodos;
  FDistribuidores := FDistribuidorService.ListarTodos;

  cmbProdutor.Items.BeginUpdate;
  try
    cmbProdutor.Clear;
    for I := 0 to FProdutores.Count - 1 do
      cmbProdutor.Items.Add(FProdutores[I].Nome);
  finally
    cmbProdutor.Items.EndUpdate;
  end;

  cmbDistribuidor.Items.BeginUpdate;
  try
    cmbDistribuidor.Clear;
    for I := 0 to FDistribuidores.Count - 1 do
      cmbDistribuidor.Items.Add(FDistribuidores[I].Nome);
  finally
    cmbDistribuidor.Items.EndUpdate;
  end;
end;

procedure TfrmCredito.CarregarLista;
var
  LCreditos: TObjectList<TCreditoProdutorDistribuidor>;
  I: Integer;
  LRow: Integer;
  LCol: Integer;
begin
  if not Assigned(FCreditoService) then
    Exit;

  LCreditos := FCreditoService.ListarTodos;
  try
    if LCreditos.Count = 0 then
      grdCreditos.RowCount := 2
    else
      grdCreditos.RowCount := LCreditos.Count + 1;

    grdCreditos.Cells[0, 0] := 'Codigo';
    grdCreditos.Cells[1, 0] := 'Produtor';
    grdCreditos.Cells[2, 0] := 'Distribuidor';
    grdCreditos.Cells[3, 0] := 'Limite de credito';
    grdCreditos.Cells[4, 0] := 'Credito disponivel';

    for LRow := 1 to grdCreditos.RowCount - 1 do
      for LCol := 0 to grdCreditos.ColCount - 1 do
        grdCreditos.Cells[LCol, LRow] := '';

    for I := 0 to LCreditos.Count - 1 do
    begin
      grdCreditos.Cells[0, I + 1] := IntToStr(LCreditos[I].Id);
      grdCreditos.Cells[1, I + 1] := NomeProdutorPorId(LCreditos[I].IdProdutor);
      grdCreditos.Cells[2, I + 1] :=
        NomeDistribuidorPorId(LCreditos[I].IdDistribuidor);
      grdCreditos.Cells[3, I + 1] := FormatarValor(LCreditos[I].LimiteCredito);
      grdCreditos.Cells[4, I + 1] := TextoCreditoDisponivel(LCreditos[I]);
    end;

    if grdCreditos.RowCount > 1 then
      grdCreditos.Row := 1;
  finally
    LCreditos.Free;
  end;

  HabilitarBotoes;
end;

procedure TfrmCredito.LimparCampos;
begin
  edtCodigo.Text := '0';
  cmbProdutor.ItemIndex := -1;
  cmbDistribuidor.ItemIndex := -1;
  edtLimiteCredito.Text := '0,00';
end;

procedure TfrmCredito.HabilitarCampos(AHabilitar: Boolean);
begin
  edtCodigo.Enabled := False;
  cmbProdutor.Enabled := AHabilitar;
  cmbDistribuidor.Enabled := AHabilitar;
  edtLimiteCredito.Enabled := AHabilitar;
  grdCreditos.Enabled := not AHabilitar;
end;

procedure TfrmCredito.HabilitarBotoes;
begin
  btnNovo.Enabled := Modo = mcNavegacao;
  btnEditar.Enabled := (Modo = mcNavegacao) and LinhaSelecionadaValida;
  btnSalvar.Enabled := Modo in [mcInclusao, mcEdicao];
  btnCancelar.Enabled := Modo in [mcInclusao, mcEdicao];
end;

function TfrmCredito.PodeSalvar: Boolean;
begin
  Result := inherited PodeSalvar and (Modo in [mcInclusao, mcEdicao]);
end;

procedure TfrmCredito.ValidarCampos;
var
  LLimiteCredito: Currency;
begin
  if IdProdutorSelecionado <= 0 then
  begin
    cmbProdutor.SetFocus;
    raise Exception.Create('Informe o produtor do limite de credito.');
  end;

  if IdDistribuidorSelecionado <= 0 then
  begin
    cmbDistribuidor.SetFocus;
    raise Exception.Create('Informe o distribuidor do limite de credito.');
  end;

  if Trim(edtLimiteCredito.Text) = '' then
  begin
    edtLimiteCredito.SetFocus;
    raise Exception.Create('Informe o limite de credito.');
  end;

  if not TextoParaCurrency(edtLimiteCredito.Text, LLimiteCredito) then
  begin
    edtLimiteCredito.SetFocus;
    raise Exception.Create('Limite de credito invalido.');
  end;

  if LLimiteCredito < 0 then
  begin
    edtLimiteCredito.SetFocus;
    raise Exception.Create('Limite de credito nao pode ser negativo.');
  end;
end;

function TfrmCredito.LimiteCreditoInformado: Currency;
begin
  if not TextoParaCurrency(edtLimiteCredito.Text, Result) then
    raise Exception.Create('Limite de credito invalido.');
end;

function TfrmCredito.CriarCreditoDaTela: TCreditoProdutorDistribuidor;
begin
  Result := TCreditoProdutorDistribuidor.Create;
  try
    if Modo = mcEdicao then
      Result.Id := StrToIntDef(edtCodigo.Text, 0);

    Result.IdProdutor := IdProdutorSelecionado;
    Result.IdDistribuidor := IdDistribuidorSelecionado;
    Result.LimiteCredito := LimiteCreditoInformado;
  except
    Result.Free;
    raise;
  end;
end;

procedure TfrmCredito.PersistirDados;
var
  LCredito: TCreditoProdutorDistribuidor;
begin
  LCredito := CriarCreditoDaTela;
  try
    FCreditoService.Salvar(LCredito);
  finally
    LCredito.Free;
  end;
end;

procedure TfrmCredito.Novo;
begin
  FIdCreditoAntesOperacao := IdSelecionado;
  inherited Novo;
  cmbProdutor.SetFocus;
end;

procedure TfrmCredito.Editar;
begin
  if not LinhaSelecionadaValida then
  begin
    MessageDlg('Selecione um limite de credito para editar.', mtInformation, [mbOK], 0);
    Exit;
  end;

  FIdCreditoAntesOperacao := IdSelecionado;
  CarregarCreditoSelecionado;
  inherited Editar;
  cmbProdutor.SetFocus;
end;

procedure TfrmCredito.Cancelar;
var
  LIdCreditoRestaurar: Integer;
begin
  LIdCreditoRestaurar := FIdCreditoAntesOperacao;

  LimparCampos;
  Modo := mcNavegacao;
  CarregarLista;
  SelecionarCreditoNaGrid(LIdCreditoRestaurar);
  HabilitarCampos(False);
  HabilitarBotoes;

  FIdCreditoAntesOperacao := 0;
end;

function TfrmCredito.LinhaSelecionadaValida: Boolean;
begin
  Result :=
    (grdCreditos.Row > 0) and
    (grdCreditos.Row < grdCreditos.RowCount) and
    (Trim(grdCreditos.Cells[0, grdCreditos.Row]) <> '');
end;

function TfrmCredito.IdSelecionado: Integer;
begin
  if not LinhaSelecionadaValida then
    Exit(0);

  Result := StrToIntDef(grdCreditos.Cells[0, grdCreditos.Row], 0);
end;

function TfrmCredito.IdProdutorSelecionado: Integer;
begin
  Result := 0;

  if not Assigned(FProdutores) then
    Exit;

  if (cmbProdutor.ItemIndex < 0) or
    (cmbProdutor.ItemIndex >= FProdutores.Count) then
    Exit;

  Result := FProdutores[cmbProdutor.ItemIndex].Id;
end;

function TfrmCredito.IdDistribuidorSelecionado: Integer;
begin
  Result := 0;

  if not Assigned(FDistribuidores) then
    Exit;

  if (cmbDistribuidor.ItemIndex < 0) or
    (cmbDistribuidor.ItemIndex >= FDistribuidores.Count) then
    Exit;

  Result := FDistribuidores[cmbDistribuidor.ItemIndex].Id;
end;

procedure TfrmCredito.CarregarCreditoSelecionado;
var
  LCredito: TCreditoProdutorDistribuidor;
  LIdCredito: Integer;
begin
  LIdCredito := IdSelecionado;

  if LIdCredito <= 0 then
    raise Exception.Create('Limite de credito selecionado invalido.');

  LCredito := FCreditoService.BuscarPorId(LIdCredito);
  try
    if not Assigned(LCredito) then
      raise Exception.Create('Limite de credito nao encontrado.');

    edtCodigo.Text := IntToStr(LCredito.Id);
    SelecionarProdutorCombo(LCredito.IdProdutor);
    SelecionarDistribuidorCombo(LCredito.IdDistribuidor);
    edtLimiteCredito.Text := FormatCurr('#,##0.00', LCredito.LimiteCredito);
  finally
    LCredito.Free;
  end;
end;

procedure TfrmCredito.SelecionarCreditoNaGrid(AIdCredito: Integer);
var
  LRow: Integer;
begin
  if AIdCredito <= 0 then
    Exit;

  for LRow := 1 to grdCreditos.RowCount - 1 do
  begin
    if StrToIntDef(grdCreditos.Cells[0, LRow], 0) = AIdCredito then
    begin
      grdCreditos.Row := LRow;
      Break;
    end;
  end;
end;

procedure TfrmCredito.SelecionarProdutorCombo(AIdProdutor: Integer);
var
  I: Integer;
begin
  cmbProdutor.ItemIndex := -1;

  if not Assigned(FProdutores) then
    Exit;

  for I := 0 to FProdutores.Count - 1 do
    if FProdutores[I].Id = AIdProdutor then
    begin
      cmbProdutor.ItemIndex := I;
      Break;
    end;
end;

procedure TfrmCredito.SelecionarDistribuidorCombo(AIdDistribuidor: Integer);
var
  I: Integer;
begin
  cmbDistribuidor.ItemIndex := -1;

  if not Assigned(FDistribuidores) then
    Exit;

  for I := 0 to FDistribuidores.Count - 1 do
    if FDistribuidores[I].Id = AIdDistribuidor then
    begin
      cmbDistribuidor.ItemIndex := I;
      Break;
    end;
end;

function TfrmCredito.NomeProdutorPorId(AIdProdutor: Integer): string;
var
  I: Integer;
begin
  Result := Format('Produtor %d', [AIdProdutor]);

  if not Assigned(FProdutores) then
    Exit;

  for I := 0 to FProdutores.Count - 1 do
    if FProdutores[I].Id = AIdProdutor then
      Exit(FProdutores[I].Nome);
end;

function TfrmCredito.NomeDistribuidorPorId(AIdDistribuidor: Integer): string;
var
  I: Integer;
begin
  Result := Format('Distribuidor %d', [AIdDistribuidor]);

  if not Assigned(FDistribuidores) then
    Exit;

  for I := 0 to FDistribuidores.Count - 1 do
    if FDistribuidores[I].Id = AIdDistribuidor then
      Exit(FDistribuidores[I].Nome);
end;

function TfrmCredito.TextoCreditoDisponivel(
  ACredito: TCreditoProdutorDistribuidor): string;
begin
  if not Assigned(FNegociacaoService) then
    Exit('');

  try
    Result := FormatarValor(
      FNegociacaoService.ObterCreditoDisponivel(
        ACredito.IdProdutor,
        ACredito.IdDistribuidor
      )
    );
  except
    Result := 'Nao informado';
  end;
end;

procedure TfrmCredito.grdCreditosDblClick(Sender: TObject);
begin
  Editar;
end;

procedure TfrmCredito.grdCreditosSelectCell(
  Sender: TObject;
  ACol: Longint;
  ARow: Longint;
  var CanSelect: Boolean);
begin
  CanSelect := True;
  HabilitarBotoes;
end;

procedure TfrmCredito.btnCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TfrmCredito.btnEditarClick(Sender: TObject);
begin
  Editar;
end;

procedure TfrmCredito.btnNovoClick(Sender: TObject);
begin
  Novo;
end;

procedure TfrmCredito.btnSalvarClick(Sender: TObject);
begin
  try
    Salvar;
    MessageDlg('Limite de credito salvo com sucesso.', mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
  end;
end;

end.
