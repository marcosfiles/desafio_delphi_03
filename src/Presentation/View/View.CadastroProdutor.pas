unit View.CadastroProdutor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, View.CadastroBase, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Grids, Vcl.Mask, App.Container,
  Core.Services.Produtor.Intf, Core.Services.Credito.Intf,
  Core.Services.Distribuidor.Intf, Core.Services.Negociacao.Intf,
  Domain.Produtor, Domain.CreditoProdutorDistribuidor,
  Domain.Distribuidor, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList,
  Vcl.BaseImageCollection, Vcl.ImageCollection;

type
  TfrmProdutor = class(TfrmCadastroBase)
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
    edtNome: TEdit;
    Label3: TLabel;
    edtCpfCnpj: TMaskEdit;
    Label4: TLabel;
    chbAtivo: TCheckBox;
    GroupBox2: TGroupBox;
    grdProdutores: TStringGrid;
    GroupBox3: TGroupBox;
    pnlLimiteCredito: TPanel;
    Label5: TLabel;
    cmbDistribuidor: TComboBox;
    Label6: TLabel;
    edtLimiteCredito: TEdit;
    btnNovoLimite: TButton;
    btnEditarLimite: TButton;
    btnSalvarLimite: TButton;
    btnCancelarLimite: TButton;
    grdCreditos: TStringGrid;
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnNovoLimiteClick(Sender: TObject);
    procedure btnEditarLimiteClick(Sender: TObject);
    procedure btnSalvarLimiteClick(Sender: TObject);
    procedure btnCancelarLimiteClick(Sender: TObject);
  private
    FContainer: TAppContainer;
    FProdutorService: IProdutorService;
    FCreditoService: ICreditoService;
    FDistribuidorService: IDistribuidorService;
    FNegociacaoService: INegociacaoService;
    FDistribuidores: TObjectList<TDistribuidor>;
    FIdProdutorAntesOperacao: Integer;
    FIdCreditoAntesOperacao: Integer;
    FModoCredito: TModoCadastro;

    procedure ConfigurarTela;
    procedure ConfigurarGrid;
    procedure ConfigurarGridCreditos;
    procedure CarregarCombosDistribuidor;
    procedure CarregarLimitesProdutor(AIdProdutor: Integer);
    procedure LimparGridCreditos;
    procedure LimparCamposCredito;
    procedure HabilitarCamposCredito(AHabilitar: Boolean);
    procedure HabilitarBotoesCredito;
    procedure CarregarProdutorSelecionado;
    procedure CarregarCreditoSelecionado;
    procedure SelecionarProdutorNaGrid(AIdProdutor: Integer);
    procedure SelecionarCreditoNaGrid(AIdCredito: Integer);
    procedure SelecionarDistribuidorCombo(AIdDistribuidor: Integer);
    procedure grdProdutoresDblClick(Sender: TObject);
    procedure grdProdutoresSelectCell(
      Sender: TObject;
      ACol: Longint;
      ARow: Longint;
      var CanSelect: Boolean
    );
    procedure grdCreditosDblClick(Sender: TObject);
    procedure grdCreditosSelectCell(
      Sender: TObject;
      ACol: Longint;
      ARow: Longint;
      var CanSelect: Boolean
    );
    procedure NovoCredito;
    procedure EditarCredito;
    procedure SalvarCredito;
    procedure CancelarCredito;
    procedure ValidarCamposCredito;
    procedure PersistirCredito;
    function CriarProdutorDaTela: TProdutor;
    function CriarCreditoDaTela: TCreditoProdutorDistribuidor;
    function IdSelecionado: Integer;
    function IdCreditoSelecionado: Integer;
    function IdDistribuidorSelecionado: Integer;
    function LinhaSelecionadaValida: Boolean;
    function LinhaCreditoSelecionadaValida: Boolean;
    function LimiteCreditoInformado: Currency;
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
  frmProdutor: TfrmProdutor;

implementation

{$R *.dfm}

function SomenteDigitos(const AValor: string): string;
var
  I: Integer;
begin
  Result := '';

  for I := 1 to Length(AValor) do
    if CharInSet(AValor[I], ['0'..'9']) then
      Result := Result + AValor[I];
end;

function FormatarCpfCnpj(const AValor: string): string;
var
  LDigitos: string;
begin
  LDigitos := SomenteDigitos(AValor);

  if Length(LDigitos) = 11 then
    Exit(Format(
      '%s.%s.%s-%s',
      [
        Copy(LDigitos, 1, 3),
        Copy(LDigitos, 4, 3),
        Copy(LDigitos, 7, 3),
        Copy(LDigitos, 10, 2)
      ]
    ));

  if Length(LDigitos) = 14 then
    Exit(Format(
      '%s.%s.%s/%s-%s',
      [
        Copy(LDigitos, 1, 2),
        Copy(LDigitos, 3, 3),
        Copy(LDigitos, 6, 3),
        Copy(LDigitos, 9, 4),
        Copy(LDigitos, 13, 2)
      ]
    ));

  Result := AValor;
end;

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

{ TfrmProdutor }

constructor TfrmProdutor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FIdProdutorAntesOperacao := 0;
  FIdCreditoAntesOperacao := 0;
  FModoCredito := mcNavegacao;

  ConfigurarTela;

  if csDesigning in ComponentState then
    Exit;

  FContainer := TAppContainer.Create;
  FProdutorService := FContainer.ProdutorService;
  FCreditoService := FContainer.CreditoService;
  FDistribuidorService := FContainer.DistribuidorService;
  FNegociacaoService := FContainer.NegociacaoService;

  CarregarCombosDistribuidor;
  CarregarLista;
  Modo := mcNavegacao;
  HabilitarBotoesCredito;
end;

destructor TfrmProdutor.Destroy;
begin
  FProdutorService := nil;
  FCreditoService := nil;
  FDistribuidorService := nil;
  FNegociacaoService := nil;
  FDistribuidores.Free;
  FContainer.Free;

  inherited Destroy;
end;

procedure TfrmProdutor.ConfigurarTela;
begin
  Caption := 'Cadastro de Produtor';

  Panel1.Caption := '';
  pnlBotoes.Caption := '';

  edtCodigo.ReadOnly := True;
  edtCodigo.TabStop := False;
  edtNome.MaxLength := 255;
  edtCpfCnpj.EditMask := '';
  edtCpfCnpj.MaxLength := 18;

  ConfigurarGrid;
  ConfigurarGridCreditos;
  LimparCampos;
  LimparCamposCredito;
  HabilitarCamposCredito(False);
end;

procedure TfrmProdutor.ConfigurarGrid;
begin
  grdProdutores.FixedCols := 0;
  grdProdutores.FixedRows := 1;
  grdProdutores.ColCount := 4;
  grdProdutores.RowCount := 2;
  grdProdutores.DefaultRowHeight := 24;
  grdProdutores.Options := grdProdutores.Options + [goRowSelect] - [goEditing];
  grdProdutores.OnDblClick := grdProdutoresDblClick;
  grdProdutores.OnSelectCell := grdProdutoresSelectCell;

  grdProdutores.Cells[0, 0] := 'Codigo';
  grdProdutores.Cells[1, 0] := 'Nome do produtor';
  grdProdutores.Cells[2, 0] := 'CPF/CNPJ';
  grdProdutores.Cells[3, 0] := 'Ativo';

  grdProdutores.ColWidths[0] := 80;
  grdProdutores.ColWidths[1] := 360;
  grdProdutores.ColWidths[2] := 170;
  grdProdutores.ColWidths[3] := 80;
end;

procedure TfrmProdutor.ConfigurarGridCreditos;
begin
  grdCreditos.FixedCols := 0;
  grdCreditos.FixedRows := 1;
  grdCreditos.ColCount := 4;
  grdCreditos.RowCount := 2;
  grdCreditos.DefaultRowHeight := 24;
  grdCreditos.Options := grdCreditos.Options + [goRowSelect] - [goEditing];
  grdCreditos.OnDblClick := grdCreditosDblClick;
  grdCreditos.OnSelectCell := grdCreditosSelectCell;

  grdCreditos.Cells[0, 0] := 'Codigo';
  grdCreditos.Cells[1, 0] := 'Distribuidor';
  grdCreditos.Cells[2, 0] := 'Limite de credito';
  grdCreditos.Cells[3, 0] := 'Credito disponivel';

  grdCreditos.ColWidths[0] := 70;
  grdCreditos.ColWidths[1] := 220;
  grdCreditos.ColWidths[2] := 120;
  grdCreditos.ColWidths[3] := 120;
end;

procedure TfrmProdutor.CarregarCombosDistribuidor;
var
  I: Integer;
begin
  if not Assigned(FDistribuidorService) then
    Exit;

  FreeAndNil(FDistribuidores);
  FDistribuidores := FDistribuidorService.ListarTodos;

  cmbDistribuidor.Items.BeginUpdate;
  try
    cmbDistribuidor.Clear;
    for I := 0 to FDistribuidores.Count - 1 do
      cmbDistribuidor.Items.Add(FDistribuidores[I].Nome);
  finally
    cmbDistribuidor.Items.EndUpdate;
  end;
end;

procedure TfrmProdutor.CarregarLista;
var
  LProdutores: TObjectList<TProdutor>;
  I: Integer;
  LRow: Integer;
  LCol: Integer;
begin
  if not Assigned(FProdutorService) then
    Exit;

  LProdutores := FProdutorService.ListarTodos;
  try
    if LProdutores.Count = 0 then
      grdProdutores.RowCount := 2
    else
      grdProdutores.RowCount := LProdutores.Count + 1;

    grdProdutores.Cells[0, 0] := 'Codigo';
    grdProdutores.Cells[1, 0] := 'Nome do produtor';
    grdProdutores.Cells[2, 0] := 'CPF/CNPJ';
    grdProdutores.Cells[3, 0] := 'Ativo';

    for LRow := 1 to grdProdutores.RowCount - 1 do
      for LCol := 0 to grdProdutores.ColCount - 1 do
        grdProdutores.Cells[LCol, LRow] := '';

    for I := 0 to LProdutores.Count - 1 do
    begin
      grdProdutores.Cells[0, I + 1] := IntToStr(LProdutores[I].Id);
      grdProdutores.Cells[1, I + 1] := LProdutores[I].Nome;
      grdProdutores.Cells[2, I + 1] := FormatarCpfCnpj(LProdutores[I].CpfCnpj);
      if LProdutores[I].Ativo then
        grdProdutores.Cells[3, I + 1] := 'Sim'
      else
        grdProdutores.Cells[3, I + 1] := 'Nao';
    end;

    if LProdutores.Count > 0 then
    begin
      grdProdutores.Row := 1;
      CarregarLimitesProdutor(IdSelecionado);
    end
    else
      LimparGridCreditos;
  finally
    LProdutores.Free;
  end;

  HabilitarBotoes;
  HabilitarBotoesCredito;
end;

procedure TfrmProdutor.CarregarLimitesProdutor(AIdProdutor: Integer);
var
  LCreditos: TObjectList<TCreditoProdutorDistribuidor>;
  LCredito: TCreditoProdutorDistribuidor;
  LRow: Integer;
begin
  LimparGridCreditos;

  if (AIdProdutor <= 0) or (not Assigned(FCreditoService)) then
  begin
    HabilitarBotoesCredito;
    Exit;
  end;

  LCreditos := FCreditoService.ListarTodos;
  try
    LRow := 1;

    for LCredito in LCreditos do
    begin
      if LCredito.IdProdutor <> AIdProdutor then
        Continue;

      if LRow >= grdCreditos.RowCount then
        grdCreditos.RowCount := LRow + 1;

      grdCreditos.Cells[0, LRow] := IntToStr(LCredito.Id);
      grdCreditos.Cells[1, LRow] :=
        NomeDistribuidorPorId(LCredito.IdDistribuidor);
      grdCreditos.Cells[2, LRow] := FormatarValor(LCredito.LimiteCredito);
      grdCreditos.Cells[3, LRow] := TextoCreditoDisponivel(LCredito);

      Inc(LRow);
    end;

    if LRow = 1 then
      grdCreditos.Cells[1, 1] := 'Nenhum limite cadastrado para este produtor.'
    else
      grdCreditos.Row := 1;
  finally
    LCreditos.Free;
  end;

  HabilitarBotoesCredito;
end;

procedure TfrmProdutor.LimparGridCreditos;
var
  LCol: Integer;
  LRow: Integer;
begin
  grdCreditos.RowCount := 2;
  grdCreditos.Cells[0, 0] := 'Codigo';
  grdCreditos.Cells[1, 0] := 'Distribuidor';
  grdCreditos.Cells[2, 0] := 'Limite de credito';
  grdCreditos.Cells[3, 0] := 'Credito disponivel';

  for LRow := 1 to grdCreditos.RowCount - 1 do
    for LCol := 0 to grdCreditos.ColCount - 1 do
      grdCreditos.Cells[LCol, LRow] := '';
end;

procedure TfrmProdutor.LimparCampos;
begin
  edtCodigo.Text := '0';
  edtNome.Clear;
  edtCpfCnpj.Clear;
  chbAtivo.Checked := True;
end;

procedure TfrmProdutor.LimparCamposCredito;
begin
  edtLimiteCredito.Text := '0,00';
  cmbDistribuidor.ItemIndex := -1;
end;

procedure TfrmProdutor.HabilitarCampos(AHabilitar: Boolean);
begin
  edtCodigo.Enabled := False;
  edtNome.Enabled := AHabilitar;
  edtCpfCnpj.Enabled := AHabilitar;
  chbAtivo.Enabled := AHabilitar;
  grdProdutores.Enabled := not AHabilitar;
  grdCreditos.Enabled := (not AHabilitar) and (FModoCredito = mcNavegacao);

  if AHabilitar then
  begin
    FModoCredito := mcNavegacao;
    LimparCamposCredito;
    HabilitarCamposCredito(False);
  end;
end;

procedure TfrmProdutor.HabilitarCamposCredito(AHabilitar: Boolean);
begin
  cmbDistribuidor.Enabled := AHabilitar;
  edtLimiteCredito.Enabled := AHabilitar;
  grdCreditos.Enabled := (not AHabilitar) and (Modo = mcNavegacao);
  grdProdutores.Enabled := (not AHabilitar) and (Modo = mcNavegacao);
end;

procedure TfrmProdutor.HabilitarBotoes;
begin
  btnNovo.Enabled := Modo = mcNavegacao;
  btnEditar.Enabled := (Modo = mcNavegacao) and LinhaSelecionadaValida;
  btnSalvar.Enabled := Modo in [mcInclusao, mcEdicao];
  btnCancelar.Enabled := Modo in [mcInclusao, mcEdicao];
  HabilitarBotoesCredito;
end;

procedure TfrmProdutor.HabilitarBotoesCredito;
var
  LPodeEditarCredito: Boolean;
begin
  LPodeEditarCredito :=
    (Modo = mcNavegacao) and (FModoCredito = mcNavegacao) and
    (IdSelecionado > 0);

  btnNovoLimite.Enabled := LPodeEditarCredito;
  btnEditarLimite.Enabled := LPodeEditarCredito and LinhaCreditoSelecionadaValida;
  btnSalvarLimite.Enabled := FModoCredito in [mcInclusao, mcEdicao];
  btnCancelarLimite.Enabled := FModoCredito in [mcInclusao, mcEdicao];

  HabilitarCamposCredito(FModoCredito in [mcInclusao, mcEdicao]);
end;

function TfrmProdutor.PodeSalvar: Boolean;
begin
  Result := inherited PodeSalvar and (Modo in [mcInclusao, mcEdicao]);
end;

procedure TfrmProdutor.ValidarCampos;
var
  LCpfCnpj: string;
begin
  if Trim(edtNome.Text) = '' then
  begin
    edtNome.SetFocus;
    raise Exception.Create('Informe o nome do produtor.');
  end;

  LCpfCnpj := SomenteDigitos(edtCpfCnpj.Text);

  if LCpfCnpj = '' then
  begin
    edtCpfCnpj.SetFocus;
    raise Exception.Create('Informe o CPF/CNPJ do produtor.');
  end;

  if not (Length(LCpfCnpj) in [11, 14]) then
  begin
    edtCpfCnpj.SetFocus;
    raise Exception.Create('CPF/CNPJ do produtor deve conter 11 ou 14 digitos.');
  end;
end;

function TfrmProdutor.CriarProdutorDaTela: TProdutor;
begin
  Result := TProdutor.Create;
  try
    if Modo = mcEdicao then
      Result.Id := StrToIntDef(edtCodigo.Text, 0);

    Result.Nome := edtNome.Text;
    Result.CpfCnpj := SomenteDigitos(edtCpfCnpj.Text);
    Result.Ativo := chbAtivo.Checked;
  except
    Result.Free;
    raise;
  end;
end;

procedure TfrmProdutor.PersistirDados;
var
  LProdutor: TProdutor;
begin
  LProdutor := CriarProdutorDaTela;
  try
    FProdutorService.Salvar(LProdutor);
  finally
    LProdutor.Free;
  end;
end;

procedure TfrmProdutor.ValidarCamposCredito;
var
  LLimiteCredito: Currency;
begin
  if IdSelecionado <= 0 then
    raise Exception.Create('Selecione um produtor para informar o limite de credito.');

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

function TfrmProdutor.LimiteCreditoInformado: Currency;
begin
  if not TextoParaCurrency(edtLimiteCredito.Text, Result) then
    raise Exception.Create('Limite de credito invalido.');
end;

function TfrmProdutor.CriarCreditoDaTela: TCreditoProdutorDistribuidor;
begin
  Result := TCreditoProdutorDistribuidor.Create;
  try
    if FModoCredito = mcEdicao then
      Result.Id := StrToIntDef(grdCreditos.Cells[0, grdCreditos.Row], 0);

    Result.IdProdutor := IdSelecionado;
    Result.IdDistribuidor := IdDistribuidorSelecionado;
    Result.LimiteCredito := LimiteCreditoInformado;
  except
    Result.Free;
    raise;
  end;
end;

procedure TfrmProdutor.PersistirCredito;
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

procedure TfrmProdutor.NovoCredito;
begin
  if IdSelecionado <= 0 then
  begin
    MessageDlg('Selecione um produtor antes de informar o limite de credito.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  FIdCreditoAntesOperacao := IdCreditoSelecionado;
  FModoCredito := mcInclusao;
  LimparCamposCredito;
  HabilitarBotoesCredito;
  cmbDistribuidor.SetFocus;
end;

procedure TfrmProdutor.EditarCredito;
begin
  if not LinhaCreditoSelecionadaValida then
  begin
    MessageDlg('Selecione um limite de credito para editar.', mtInformation,
      [mbOK], 0);
    Exit;
  end;

  FIdCreditoAntesOperacao := IdCreditoSelecionado;
  CarregarCreditoSelecionado;
  FModoCredito := mcEdicao;
  HabilitarBotoesCredito;
  cmbDistribuidor.SetFocus;
end;

procedure TfrmProdutor.SalvarCredito;
var
  LIdProdutor: Integer;
begin
  if not (FModoCredito in [mcInclusao, mcEdicao]) then
    Exit;

  LIdProdutor := IdSelecionado;

  ValidarCamposCredito;
  PersistirCredito;

  FModoCredito := mcNavegacao;
  LimparCamposCredito;
  CarregarLimitesProdutor(LIdProdutor);
  SelecionarCreditoNaGrid(FIdCreditoAntesOperacao);
  FIdCreditoAntesOperacao := 0;

  MessageDlg('Limite de credito salvo com sucesso.', mtInformation, [mbOK], 0);
end;

procedure TfrmProdutor.CancelarCredito;
var
  LIdCreditoRestaurar: Integer;
begin
  LIdCreditoRestaurar := FIdCreditoAntesOperacao;

  FModoCredito := mcNavegacao;
  LimparCamposCredito;
  CarregarLimitesProdutor(IdSelecionado);
  SelecionarCreditoNaGrid(LIdCreditoRestaurar);
  FIdCreditoAntesOperacao := 0;
  HabilitarBotoesCredito;
end;

procedure TfrmProdutor.Novo;
begin
  FIdProdutorAntesOperacao := IdSelecionado;
  FModoCredito := mcNavegacao;
  LimparCamposCredito;
  inherited Novo;
  edtNome.SetFocus;
end;

procedure TfrmProdutor.Editar;
begin
  if not LinhaSelecionadaValida then
  begin
    MessageDlg('Selecione um produtor para editar.', mtInformation, [mbOK], 0);
    Exit;
  end;

  FIdProdutorAntesOperacao := IdSelecionado;
  FModoCredito := mcNavegacao;
  LimparCamposCredito;
  CarregarProdutorSelecionado;
  inherited Editar;
  edtNome.SetFocus;
end;

procedure TfrmProdutor.Cancelar;
var
  LIdProdutorRestaurar: Integer;
begin
  LIdProdutorRestaurar := FIdProdutorAntesOperacao;

  LimparCampos;
  LimparCamposCredito;
  Modo := mcNavegacao;
  CarregarLista;
  SelecionarProdutorNaGrid(LIdProdutorRestaurar);
  HabilitarCampos(False);
  HabilitarBotoes;
  HabilitarBotoesCredito;

  FIdProdutorAntesOperacao := 0;
end;

function TfrmProdutor.LinhaSelecionadaValida: Boolean;
begin
  Result :=
    (grdProdutores.Row > 0) and
    (grdProdutores.Row < grdProdutores.RowCount) and
    (Trim(grdProdutores.Cells[0, grdProdutores.Row]) <> '');
end;

function TfrmProdutor.IdSelecionado: Integer;
begin
  if not LinhaSelecionadaValida then
    Exit(0);

  Result := StrToIntDef(grdProdutores.Cells[0, grdProdutores.Row], 0);
end;

function TfrmProdutor.LinhaCreditoSelecionadaValida: Boolean;
begin
  Result :=
    (grdCreditos.Row > 0) and
    (grdCreditos.Row < grdCreditos.RowCount) and
    (Trim(grdCreditos.Cells[0, grdCreditos.Row]) <> '');
end;

function TfrmProdutor.IdCreditoSelecionado: Integer;
begin
  if not LinhaCreditoSelecionadaValida then
    Exit(0);

  Result := StrToIntDef(grdCreditos.Cells[0, grdCreditos.Row], 0);
end;

function TfrmProdutor.IdDistribuidorSelecionado: Integer;
begin
  Result := 0;

  if not Assigned(FDistribuidores) then
    Exit;

  if (cmbDistribuidor.ItemIndex < 0) or
    (cmbDistribuidor.ItemIndex >= FDistribuidores.Count) then
    Exit;

  Result := FDistribuidores[cmbDistribuidor.ItemIndex].Id;
end;

procedure TfrmProdutor.CarregarProdutorSelecionado;
var
  LProdutor: TProdutor;
  LIdProdutor: Integer;
begin
  LIdProdutor := IdSelecionado;

  if LIdProdutor <= 0 then
    raise Exception.Create('Produtor selecionado invalido.');

  LProdutor := FProdutorService.BuscarPorId(LIdProdutor);
  try
    if not Assigned(LProdutor) then
      raise Exception.Create('Produtor nao encontrado.');

    edtCodigo.Text := IntToStr(LProdutor.Id);
    edtNome.Text := LProdutor.Nome;
    edtCpfCnpj.Text := FormatarCpfCnpj(LProdutor.CpfCnpj);
    chbAtivo.Checked := LProdutor.Ativo;
    CarregarLimitesProdutor(LProdutor.Id);
  finally
    LProdutor.Free;
  end;
end;

procedure TfrmProdutor.CarregarCreditoSelecionado;
var
  LCredito: TCreditoProdutorDistribuidor;
  LIdCredito: Integer;
begin
  LIdCredito := IdCreditoSelecionado;

  if LIdCredito <= 0 then
    raise Exception.Create('Limite de credito selecionado invalido.');

  LCredito := FCreditoService.BuscarPorId(LIdCredito);
  try
    if not Assigned(LCredito) then
      raise Exception.Create('Limite de credito nao encontrado.');

    SelecionarDistribuidorCombo(LCredito.IdDistribuidor);
    edtLimiteCredito.Text := FormatCurr('#,##0.00', LCredito.LimiteCredito);
  finally
    LCredito.Free;
  end;
end;

procedure TfrmProdutor.SelecionarProdutorNaGrid(AIdProdutor: Integer);
var
  LRow: Integer;
begin
  if AIdProdutor <= 0 then
    Exit;

  for LRow := 1 to grdProdutores.RowCount - 1 do
  begin
    if StrToIntDef(grdProdutores.Cells[0, LRow], 0) = AIdProdutor then
    begin
      grdProdutores.Row := LRow;
      CarregarLimitesProdutor(AIdProdutor);
      Break;
    end;
  end;
end;

procedure TfrmProdutor.SelecionarCreditoNaGrid(AIdCredito: Integer);
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

procedure TfrmProdutor.SelecionarDistribuidorCombo(AIdDistribuidor: Integer);
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

function TfrmProdutor.NomeDistribuidorPorId(AIdDistribuidor: Integer): string;
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

function TfrmProdutor.TextoCreditoDisponivel(
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

procedure TfrmProdutor.grdProdutoresDblClick(Sender: TObject);
begin
  Editar;
end;

procedure TfrmProdutor.grdProdutoresSelectCell(
  Sender: TObject;
  ACol: Longint;
  ARow: Longint;
  var CanSelect: Boolean);
begin
  CanSelect := True;
  if (ARow > 0) and (Trim(grdProdutores.Cells[0, ARow]) <> '') then
  begin
    LimparCamposCredito;
    FModoCredito := mcNavegacao;
    CarregarLimitesProdutor(StrToIntDef(grdProdutores.Cells[0, ARow], 0));
  end;
  HabilitarBotoes;
end;

procedure TfrmProdutor.grdCreditosDblClick(Sender: TObject);
begin
  EditarCredito;
end;

procedure TfrmProdutor.grdCreditosSelectCell(
  Sender: TObject;
  ACol: Longint;
  ARow: Longint;
  var CanSelect: Boolean);
begin
  CanSelect := True;
  HabilitarBotoesCredito;
end;

procedure TfrmProdutor.btnCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TfrmProdutor.btnCancelarLimiteClick(Sender: TObject);
begin
  CancelarCredito;
end;

procedure TfrmProdutor.btnEditarClick(Sender: TObject);
begin
  Editar;
end;

procedure TfrmProdutor.btnEditarLimiteClick(Sender: TObject);
begin
  EditarCredito;
end;

procedure TfrmProdutor.btnNovoClick(Sender: TObject);
begin
  Novo;
end;

procedure TfrmProdutor.btnNovoLimiteClick(Sender: TObject);
begin
  NovoCredito;
end;

procedure TfrmProdutor.btnSalvarClick(Sender: TObject);
begin
  try
    Salvar;
    MessageDlg('Produtor salvo com sucesso.', mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
  end;
end;

procedure TfrmProdutor.btnSalvarLimiteClick(Sender: TObject);
begin
  try
    SalvarCredito;
  except
    on E: Exception do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
  end;
end;

end.
