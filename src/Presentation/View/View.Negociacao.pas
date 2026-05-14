unit View.Negociacao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, View.CadastroBase, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Grids, App.Container, App.Types,
  Core.Services.Negociacao.Intf, Core.Services.Produtor.Intf,
  Core.Services.Distribuidor.Intf, Core.Services.Produto.Intf,
  Domain.Negociacao, Domain.NegociacaoItem, Domain.Produtor,
  Domain.Distribuidor, Domain.Produto, System.ImageList, Vcl.ImgList,
  Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection;

type
  TfrmNegociacao = class(TfrmCadastroBase)
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
    edtStatus: TEdit;
    Label5: TLabel;
    edtTotal: TEdit;
    GroupBox2: TGroupBox;
    Label6: TLabel;
    cmbProduto: TComboBox;
    Label7: TLabel;
    edtQuantidade: TEdit;
    Label8: TLabel;
    edtPrecoUnitario: TEdit;
    btnAdicionarItem: TButton;
    btnRemoverItem: TButton;
    GroupBox3: TGroupBox;
    grdItens: TStringGrid;
    GroupBox4: TGroupBox;
    grdNegociacoes: TStringGrid;
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnAdicionarItemClick(Sender: TObject);
    procedure btnRemoverItemClick(Sender: TObject);
    procedure cmbProdutoChange(Sender: TObject);
  private
    FContainer: TAppContainer;
    FNegociacaoService: INegociacaoService;
    FProdutorService: IProdutorService;
    FDistribuidorService: IDistribuidorService;
    FProdutoService: IProdutoService;
    FProdutores: TObjectList<TProdutor>;
    FDistribuidores: TObjectList<TDistribuidor>;
    FProdutos: TObjectList<TProduto>;
    FItens: TObjectList<TNegociacaoItem>;
    FIdNegociacaoAntesOperacao: Integer;
    FStatusAtual: TStatusNegociacao;

    procedure ConfigurarTela;
    procedure ConfigurarGridItens;
    procedure ConfigurarGridNegociacoes;
    procedure CarregarCombos;
    procedure CarregarNegociacaoSelecionada;
    procedure PreencherTelaNegociacao(ANegociacao: TNegociacao);
    procedure SelecionarNegociacaoNaGrid(AIdNegociacao: Integer);
    procedure SelecionarProdutorCombo(AIdProdutor: Integer);
    procedure SelecionarDistribuidorCombo(AIdDistribuidor: Integer);
    procedure SelecionarProdutoCombo(AIdProduto: Integer);
    procedure AtualizarGridItens;
    procedure AtualizarTotal;
    procedure LimparCamposItem;
    procedure grdItensSelectCell(
      Sender: TObject;
      ACol: Longint;
      ARow: Longint;
      var CanSelect: Boolean
    );
    procedure grdNegociacoesDblClick(Sender: TObject);
    procedure grdNegociacoesSelectCell(
      Sender: TObject;
      ACol: Longint;
      ARow: Longint;
      var CanSelect: Boolean
    );
    function CriarNegociacaoDaTela: TNegociacao;
    function CriarItemDaTela: TNegociacaoItem;
    function CopiarItem(AItem: TNegociacaoItem): TNegociacaoItem;
    function IdNegociacaoInformado: Integer;
    function IdProdutorSelecionado: Integer;
    function IdDistribuidorSelecionado: Integer;
    function IdProdutoSelecionado: Integer;
    function ProdutoSelecionado: TProduto;
    function ProdutoJaIncluido(AIdProduto: Integer): Boolean;
    function LinhaItemSelecionadaValida: Boolean;
    function LinhaNegociacaoSelecionadaValida: Boolean;
    function IdNegociacaoSelecionadaGrid: Integer;
    function QuantidadeInformada: Currency;
    function PrecoUnitarioInformado: Currency;
    function TotalItens: Currency;
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
  frmNegociacao: TfrmNegociacao;

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
    if (LQuantidadeSeparadores = 1) and (LCasasDecimais > 3) then
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

function FormatarQuantidade(const AValor: Currency): string;
begin
  Result := FormatCurr('#,##0.###', AValor);
end;

function FormatarData(const AValor: TDateTime): string;
begin
  if AValor <= 0 then
    Exit('');

  Result := FormatDateTime('dd/mm/yyyy hh:nn', AValor);
end;

{ TfrmNegociacao }

constructor TfrmNegociacao.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FItens := TObjectList<TNegociacaoItem>.Create(True);
  FIdNegociacaoAntesOperacao := 0;
  FStatusAtual := snPendente;

  ConfigurarTela;

  if csDesigning in ComponentState then
    Exit;

  FContainer := TAppContainer.Create;
  FNegociacaoService := FContainer.NegociacaoService;
  FProdutorService := FContainer.ProdutorService;
  FDistribuidorService := FContainer.DistribuidorService;
  FProdutoService := FContainer.ProdutoService;

  CarregarCombos;
  CarregarLista;
  Modo := mcNavegacao;
end;

destructor TfrmNegociacao.Destroy;
begin
  FNegociacaoService := nil;
  FProdutorService := nil;
  FDistribuidorService := nil;
  FProdutoService := nil;
  FItens.Free;
  FProdutores.Free;
  FDistribuidores.Free;
  FProdutos.Free;
  FContainer.Free;

  inherited Destroy;
end;

procedure TfrmNegociacao.ConfigurarTela;
begin
  Caption := 'Manutencao de Negociacao';

  Panel1.Caption := '';
  pnlBotoes.Caption := '';

  edtStatus.ReadOnly := True;
  edtStatus.TabStop := False;
  edtTotal.ReadOnly := True;
  edtTotal.TabStop := False;
  cmbProdutor.Style := csDropDownList;
  cmbDistribuidor.Style := csDropDownList;
  cmbProduto.Style := csDropDownList;
  cmbProduto.OnChange := cmbProdutoChange;
  grdItens.OnSelectCell := grdItensSelectCell;

  ConfigurarGridItens;
  ConfigurarGridNegociacoes;
  LimparCampos;
end;

procedure TfrmNegociacao.ConfigurarGridItens;
begin
  grdItens.FixedCols := 0;
  grdItens.FixedRows := 1;
  grdItens.ColCount := 5;
  grdItens.RowCount := 2;
  grdItens.DefaultRowHeight := 24;
  grdItens.Options := grdItens.Options + [goRowSelect] - [goEditing];

  grdItens.Cells[0, 0] := 'Codigo';
  grdItens.Cells[1, 0] := 'Produto';
  grdItens.Cells[2, 0] := 'Quantidade';
  grdItens.Cells[3, 0] := 'Preco unitario';
  grdItens.Cells[4, 0] := 'Total';

  grdItens.ColWidths[0] := 70;
  grdItens.ColWidths[1] := 310;
  grdItens.ColWidths[2] := 110;
  grdItens.ColWidths[3] := 120;
  grdItens.ColWidths[4] := 120;
end;

procedure TfrmNegociacao.ConfigurarGridNegociacoes;
begin
  grdNegociacoes.FixedCols := 0;
  grdNegociacoes.FixedRows := 1;
  grdNegociacoes.ColCount := 6;
  grdNegociacoes.RowCount := 2;
  grdNegociacoes.DefaultRowHeight := 24;
  grdNegociacoes.Options := grdNegociacoes.Options + [goRowSelect] - [goEditing];
  grdNegociacoes.OnDblClick := grdNegociacoesDblClick;
  grdNegociacoes.OnSelectCell := grdNegociacoesSelectCell;

  grdNegociacoes.Cells[0, 0] := 'Codigo';
  grdNegociacoes.Cells[1, 0] := 'Data';
  grdNegociacoes.Cells[2, 0] := 'Produtor';
  grdNegociacoes.Cells[3, 0] := 'Distribuidor';
  grdNegociacoes.Cells[4, 0] := 'Status';
  grdNegociacoes.Cells[5, 0] := 'Total';

  grdNegociacoes.ColWidths[0] := 70;
  grdNegociacoes.ColWidths[1] := 120;
  grdNegociacoes.ColWidths[2] := 210;
  grdNegociacoes.ColWidths[3] := 210;
  grdNegociacoes.ColWidths[4] := 90;
  grdNegociacoes.ColWidths[5] := 110;
end;

procedure TfrmNegociacao.CarregarCombos;
var
  I: Integer;
begin
  if (not Assigned(FProdutorService)) or
    (not Assigned(FDistribuidorService)) or
    (not Assigned(FProdutoService)) then
    Exit;

  FreeAndNil(FProdutores);
  FreeAndNil(FDistribuidores);
  FreeAndNil(FProdutos);

  FProdutores := FProdutorService.ListarTodos;
  FDistribuidores := FDistribuidorService.ListarTodos;
  FProdutos := FProdutoService.ListarTodos;

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

  cmbProduto.Items.BeginUpdate;
  try
    cmbProduto.Clear;
    for I := 0 to FProdutos.Count - 1 do
      cmbProduto.Items.Add(FProdutos[I].Nome);
  finally
    cmbProduto.Items.EndUpdate;
  end;
end;

procedure TfrmNegociacao.CarregarLista;
var
  LNegociacoes: TObjectList<TNegociacao>;
  I: Integer;
  LRow: Integer;
  LCol: Integer;
  LIdNegociacaoAtual: Integer;
begin
  if not Assigned(FNegociacaoService) then
    Exit;

  LIdNegociacaoAtual := IdNegociacaoInformado;

  LNegociacoes := FNegociacaoService.ListarTodos;
  try
    if LNegociacoes.Count = 0 then
      grdNegociacoes.RowCount := 2
    else
      grdNegociacoes.RowCount := LNegociacoes.Count + 1;

    grdNegociacoes.Cells[0, 0] := 'Codigo';
    grdNegociacoes.Cells[1, 0] := 'Data';
    grdNegociacoes.Cells[2, 0] := 'Produtor';
    grdNegociacoes.Cells[3, 0] := 'Distribuidor';
    grdNegociacoes.Cells[4, 0] := 'Status';
    grdNegociacoes.Cells[5, 0] := 'Total';

    for LRow := 1 to grdNegociacoes.RowCount - 1 do
      for LCol := 0 to grdNegociacoes.ColCount - 1 do
        grdNegociacoes.Cells[LCol, LRow] := '';

    for I := 0 to LNegociacoes.Count - 1 do
    begin
      grdNegociacoes.Cells[0, I + 1] := IntToStr(LNegociacoes[I].Id);
      grdNegociacoes.Cells[1, I + 1] := FormatarData(LNegociacoes[I].DataCadastro);
      grdNegociacoes.Cells[2, I + 1] := LNegociacoes[I].ProdutorNome;
      grdNegociacoes.Cells[3, I + 1] := LNegociacoes[I].DistribuidorNome;
      grdNegociacoes.Cells[4, I + 1] :=
        StatusNegociacaoToString(LNegociacoes[I].Status);
      grdNegociacoes.Cells[5, I + 1] :=
        FormatarValor(LNegociacoes[I].ValorTotal);
    end;

    if LIdNegociacaoAtual > 0 then
      SelecionarNegociacaoNaGrid(LIdNegociacaoAtual)
    else if LNegociacoes.Count > 0 then
      grdNegociacoes.Row := 1;
  finally
    LNegociacoes.Free;
  end;

  HabilitarBotoes;
end;

procedure TfrmNegociacao.LimparCampos;
begin
  edtCodigo.Text := '0';
  cmbProdutor.ItemIndex := -1;
  cmbDistribuidor.ItemIndex := -1;
  FStatusAtual := snPendente;
  edtStatus.Text := StatusNegociacaoToString(FStatusAtual);
  FItens.Clear;
  LimparCamposItem;
  AtualizarGridItens;
  AtualizarTotal;
end;

procedure TfrmNegociacao.LimparCamposItem;
begin
  cmbProduto.ItemIndex := -1;
  edtQuantidade.Text := '0,000';
  edtPrecoUnitario.Text := '0,00';
end;

procedure TfrmNegociacao.HabilitarCampos(AHabilitar: Boolean);
begin
  edtCodigo.Enabled := Modo = mcNavegacao;
  cmbProdutor.Enabled := AHabilitar;
  cmbDistribuidor.Enabled := AHabilitar;
  cmbProduto.Enabled := AHabilitar;
  edtQuantidade.Enabled := AHabilitar;
  edtPrecoUnitario.Enabled := AHabilitar;
  grdItens.Enabled := AHabilitar;
  grdNegociacoes.Enabled := not AHabilitar;
  edtStatus.Enabled := False;
  edtTotal.Enabled := False;
end;

procedure TfrmNegociacao.HabilitarBotoes;
begin
  btnNovo.Enabled := Modo = mcNavegacao;
  btnEditar.Enabled := Modo = mcNavegacao;
  btnSalvar.Enabled := Modo in [mcInclusao, mcEdicao];
  btnCancelar.Enabled := Modo in [mcInclusao, mcEdicao];
  btnAdicionarItem.Enabled := Modo in [mcInclusao, mcEdicao];
  btnRemoverItem.Enabled :=
    (Modo in [mcInclusao, mcEdicao]) and LinhaItemSelecionadaValida;
end;

function TfrmNegociacao.PodeSalvar: Boolean;
begin
  Result := inherited PodeSalvar and (Modo in [mcInclusao, mcEdicao]);
end;

procedure TfrmNegociacao.ValidarCampos;
begin
  if IdProdutorSelecionado <= 0 then
  begin
    cmbProdutor.SetFocus;
    raise Exception.Create('Informe o produtor da negociacao.');
  end;

  if IdDistribuidorSelecionado <= 0 then
  begin
    cmbDistribuidor.SetFocus;
    raise Exception.Create('Informe o distribuidor da negociacao.');
  end;

  if FItens.Count = 0 then
  begin
    cmbProduto.SetFocus;
    raise Exception.Create('Informe ao menos um item na negociacao.');
  end;

  if TotalItens <= 0 then
    raise Exception.Create('Valor total da negociacao deve ser maior que zero.');
end;

function TfrmNegociacao.CriarNegociacaoDaTela: TNegociacao;
var
  LItem: TNegociacaoItem;
begin
  Result := TNegociacao.Create;
  try
    if Modo = mcEdicao then
      Result.Id := IdNegociacaoInformado;

    Result.IdProdutor := IdProdutorSelecionado;
    Result.IdDistribuidor := IdDistribuidorSelecionado;
    Result.Status := snPendente;

    for LItem in FItens do
      Result.AdicionarItem(CopiarItem(LItem));
  except
    Result.Free;
    raise;
  end;
end;

procedure TfrmNegociacao.PersistirDados;
var
  LNegociacao: TNegociacao;
begin
  LNegociacao := CriarNegociacaoDaTela;
  try
    FNegociacaoService.Salvar(LNegociacao);
    edtCodigo.Text := IntToStr(LNegociacao.Id);
  finally
    LNegociacao.Free;
  end;
end;

procedure TfrmNegociacao.Novo;
begin
  FIdNegociacaoAntesOperacao := IdNegociacaoInformado;
  inherited Novo;
  edtStatus.Text := StatusNegociacaoToString(snPendente);
  cmbProdutor.SetFocus;
end;

procedure TfrmNegociacao.Editar;
begin
  if IdNegociacaoInformado <= 0 then
  begin
    MessageDlg('Informe o codigo da negociacao para editar.', mtInformation, [mbOK], 0);
    Exit;
  end;

  FIdNegociacaoAntesOperacao := IdNegociacaoInformado;
  CarregarNegociacaoSelecionada;

  if FStatusAtual <> snPendente then
  begin
    MessageDlg(
      'Somente negociacoes pendentes podem ser alteradas.',
      mtInformation,
      [mbOK],
      0
    );
    Exit;
  end;

  inherited Editar;
  cmbProdutor.SetFocus;
end;

procedure TfrmNegociacao.Cancelar;
var
  LIdNegociacaoRestaurar: Integer;
begin
  LIdNegociacaoRestaurar := FIdNegociacaoAntesOperacao;

  Modo := mcNavegacao;

  if LIdNegociacaoRestaurar > 0 then
  begin
    edtCodigo.Text := IntToStr(LIdNegociacaoRestaurar);
    try
      CarregarNegociacaoSelecionada;
    except
      LimparCampos;
    end;
  end
  else
    LimparCampos;

  HabilitarCampos(False);
  HabilitarBotoes;
  FIdNegociacaoAntesOperacao := 0;
end;

procedure TfrmNegociacao.CarregarNegociacaoSelecionada;
var
  LNegociacao: TNegociacao;
  LIdNegociacao: Integer;
begin
  LIdNegociacao := IdNegociacaoInformado;

  if LIdNegociacao <= 0 then
    raise Exception.Create('Negociacao selecionada invalida.');

  LNegociacao := FNegociacaoService.BuscarPorId(LIdNegociacao);
  try
    if not Assigned(LNegociacao) then
      raise Exception.Create('Negociacao nao encontrada.');

    PreencherTelaNegociacao(LNegociacao);
  finally
    LNegociacao.Free;
  end;
end;

procedure TfrmNegociacao.PreencherTelaNegociacao(ANegociacao: TNegociacao);
var
  LItem: TNegociacaoItem;
begin
  edtCodigo.Text := IntToStr(ANegociacao.Id);
  SelecionarProdutorCombo(ANegociacao.IdProdutor);
  SelecionarDistribuidorCombo(ANegociacao.IdDistribuidor);
  FStatusAtual := ANegociacao.Status;
  edtStatus.Text := StatusNegociacaoToString(FStatusAtual);

  FItens.Clear;
  for LItem in ANegociacao.Itens do
    FItens.Add(CopiarItem(LItem));

  LimparCamposItem;
  AtualizarGridItens;
  AtualizarTotal;
end;

procedure TfrmNegociacao.SelecionarProdutorCombo(AIdProdutor: Integer);
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

procedure TfrmNegociacao.SelecionarDistribuidorCombo(AIdDistribuidor: Integer);
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

procedure TfrmNegociacao.SelecionarProdutoCombo(AIdProduto: Integer);
var
  I: Integer;
begin
  cmbProduto.ItemIndex := -1;

  if not Assigned(FProdutos) then
    Exit;

  for I := 0 to FProdutos.Count - 1 do
    if FProdutos[I].Id = AIdProduto then
    begin
      cmbProduto.ItemIndex := I;
      Break;
    end;
end;

procedure TfrmNegociacao.SelecionarNegociacaoNaGrid(AIdNegociacao: Integer);
var
  LRow: Integer;
begin
  if AIdNegociacao <= 0 then
    Exit;

  for LRow := 1 to grdNegociacoes.RowCount - 1 do
  begin
    if StrToIntDef(grdNegociacoes.Cells[0, LRow], 0) = AIdNegociacao then
    begin
      grdNegociacoes.Row := LRow;
      Break;
    end;
  end;
end;

procedure TfrmNegociacao.AtualizarGridItens;
var
  I: Integer;
  LRow: Integer;
  LCol: Integer;
begin
  if FItens.Count = 0 then
    grdItens.RowCount := 2
  else
    grdItens.RowCount := FItens.Count + 1;

  grdItens.Cells[0, 0] := 'Codigo';
  grdItens.Cells[1, 0] := 'Produto';
  grdItens.Cells[2, 0] := 'Quantidade';
  grdItens.Cells[3, 0] := 'Preco unitario';
  grdItens.Cells[4, 0] := 'Total';

  for LRow := 1 to grdItens.RowCount - 1 do
    for LCol := 0 to grdItens.ColCount - 1 do
      grdItens.Cells[LCol, LRow] := '';

  for I := 0 to FItens.Count - 1 do
  begin
    grdItens.Cells[0, I + 1] := IntToStr(FItens[I].IdProduto);
    grdItens.Cells[1, I + 1] := FItens[I].ProdutoNome;
    grdItens.Cells[2, I + 1] := FormatarQuantidade(FItens[I].Quantidade);
    grdItens.Cells[3, I + 1] := FormatarValor(FItens[I].PrecoUnitario);
    grdItens.Cells[4, I + 1] := FormatarValor(FItens[I].ValorTotal);
  end;

  if (FItens.Count > 0) and (grdItens.Row = 0) then
    grdItens.Row := 1;

  AtualizarTotal;
  HabilitarBotoes;
end;

procedure TfrmNegociacao.AtualizarTotal;
begin
  edtTotal.Text := FormatarValor(TotalItens);
end;

function TfrmNegociacao.TotalItens: Currency;
var
  LItem: TNegociacaoItem;
begin
  Result := 0;

  for LItem in FItens do
    Result := Result + LItem.ValorTotal;
end;

function TfrmNegociacao.IdNegociacaoInformado: Integer;
begin
  Result := StrToIntDef(Trim(edtCodigo.Text), 0);
end;

function TfrmNegociacao.IdProdutorSelecionado: Integer;
begin
  Result := 0;

  if not Assigned(FProdutores) then
    Exit;

  if (cmbProdutor.ItemIndex < 0) or
    (cmbProdutor.ItemIndex >= FProdutores.Count) then
    Exit;

  Result := FProdutores[cmbProdutor.ItemIndex].Id;
end;

function TfrmNegociacao.IdDistribuidorSelecionado: Integer;
begin
  Result := 0;

  if not Assigned(FDistribuidores) then
    Exit;

  if (cmbDistribuidor.ItemIndex < 0) or
    (cmbDistribuidor.ItemIndex >= FDistribuidores.Count) then
    Exit;

  Result := FDistribuidores[cmbDistribuidor.ItemIndex].Id;
end;

function TfrmNegociacao.IdProdutoSelecionado: Integer;
var
  LProduto: TProduto;
begin
  LProduto := ProdutoSelecionado;

  if not Assigned(LProduto) then
    Exit(0);

  Result := LProduto.Id;
end;

function TfrmNegociacao.ProdutoSelecionado: TProduto;
begin
  Result := nil;

  if not Assigned(FProdutos) then
    Exit;

  if (cmbProduto.ItemIndex < 0) or
    (cmbProduto.ItemIndex >= FProdutos.Count) then
    Exit;

  Result := FProdutos[cmbProduto.ItemIndex];
end;

function TfrmNegociacao.ProdutoJaIncluido(AIdProduto: Integer): Boolean;
var
  LItem: TNegociacaoItem;
begin
  Result := False;

  for LItem in FItens do
    if LItem.IdProduto = AIdProduto then
      Exit(True);
end;

function TfrmNegociacao.LinhaItemSelecionadaValida: Boolean;
begin
  Result :=
    (grdItens.Row > 0) and
    (grdItens.Row < grdItens.RowCount) and
    (Trim(grdItens.Cells[0, grdItens.Row]) <> '');
end;

function TfrmNegociacao.LinhaNegociacaoSelecionadaValida: Boolean;
begin
  Result :=
    (grdNegociacoes.Row > 0) and
    (grdNegociacoes.Row < grdNegociacoes.RowCount) and
    (Trim(grdNegociacoes.Cells[0, grdNegociacoes.Row]) <> '');
end;

function TfrmNegociacao.IdNegociacaoSelecionadaGrid: Integer;
begin
  if not LinhaNegociacaoSelecionadaValida then
    Exit(0);

  Result := StrToIntDef(grdNegociacoes.Cells[0, grdNegociacoes.Row], 0);
end;

function TfrmNegociacao.QuantidadeInformada: Currency;
begin
  if not TextoParaCurrency(edtQuantidade.Text, Result) then
    raise Exception.Create('Quantidade invalida.');
end;

function TfrmNegociacao.PrecoUnitarioInformado: Currency;
begin
  if not TextoParaCurrency(edtPrecoUnitario.Text, Result) then
    raise Exception.Create('Preco unitario invalido.');
end;

function TfrmNegociacao.CriarItemDaTela: TNegociacaoItem;
var
  LProduto: TProduto;
begin
  LProduto := ProdutoSelecionado;

  if not Assigned(LProduto) then
  begin
    cmbProduto.SetFocus;
    raise Exception.Create('Informe o produto do item.');
  end;

  if ProdutoJaIncluido(LProduto.Id) then
  begin
    cmbProduto.SetFocus;
    raise Exception.Create('Produto ja incluido na negociacao.');
  end;

  Result := TNegociacaoItem.Create;
  try
    Result.IdProduto := LProduto.Id;
    Result.ProdutoNome := LProduto.Nome;
    Result.Quantidade := QuantidadeInformada;
    Result.PrecoUnitario := PrecoUnitarioInformado;
    Result.Validar;
  except
    Result.Free;
    raise;
  end;
end;

function TfrmNegociacao.CopiarItem(AItem: TNegociacaoItem): TNegociacaoItem;
begin
  Result := TNegociacaoItem.Create;
  try
    Result.Id := AItem.Id;
    Result.IdNegociacao := AItem.IdNegociacao;
    Result.IdProduto := AItem.IdProduto;
    Result.ProdutoNome := AItem.ProdutoNome;
    Result.Quantidade := AItem.Quantidade;
    Result.PrecoUnitario := AItem.PrecoUnitario;
  except
    Result.Free;
    raise;
  end;
end;

procedure TfrmNegociacao.btnAdicionarItemClick(Sender: TObject);
var
  LItem: TNegociacaoItem;
begin
  try
    LItem := CriarItemDaTela;
    FItens.Add(LItem);
    LimparCamposItem;
    AtualizarGridItens;
    cmbProduto.SetFocus;
  except
    on E: Exception do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
  end;
end;

procedure TfrmNegociacao.btnRemoverItemClick(Sender: TObject);
var
  LIndex: Integer;
begin
  if not LinhaItemSelecionadaValida then
  begin
    MessageDlg('Selecione um item para remover.', mtInformation, [mbOK], 0);
    Exit;
  end;

  LIndex := grdItens.Row - 1;

  if (LIndex >= 0) and (LIndex < FItens.Count) then
  begin
    FItens.Delete(LIndex);
    AtualizarGridItens;
  end;
end;

procedure TfrmNegociacao.cmbProdutoChange(Sender: TObject);
var
  LProduto: TProduto;
begin
  LProduto := ProdutoSelecionado;

  if Assigned(LProduto) then
    edtPrecoUnitario.Text := FormatCurr('#,##0.00', LProduto.PrecoVenda);
end;

procedure TfrmNegociacao.grdItensSelectCell(
  Sender: TObject;
  ACol: Longint;
  ARow: Longint;
  var CanSelect: Boolean);
begin
  CanSelect := True;
  HabilitarBotoes;
end;

procedure TfrmNegociacao.grdNegociacoesDblClick(Sender: TObject);
var
  LIdNegociacao: Integer;
begin
  LIdNegociacao := IdNegociacaoSelecionadaGrid;

  if LIdNegociacao <= 0 then
    Exit;

  edtCodigo.Text := IntToStr(LIdNegociacao);
  Editar;
end;

procedure TfrmNegociacao.grdNegociacoesSelectCell(
  Sender: TObject;
  ACol: Longint;
  ARow: Longint;
  var CanSelect: Boolean);
begin
  CanSelect := True;

  if (Modo = mcNavegacao) and (ARow > 0) and
    (Trim(grdNegociacoes.Cells[0, ARow]) <> '') then
    edtCodigo.Text := grdNegociacoes.Cells[0, ARow];

  HabilitarBotoes;
end;

procedure TfrmNegociacao.btnCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TfrmNegociacao.btnEditarClick(Sender: TObject);
begin
  Editar;
end;

procedure TfrmNegociacao.btnNovoClick(Sender: TObject);
begin
  Novo;
end;

procedure TfrmNegociacao.btnSalvarClick(Sender: TObject);
begin
  try
    Salvar;
    MessageDlg('Negociacao salva com sucesso.', mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
  end;
end;

end.
