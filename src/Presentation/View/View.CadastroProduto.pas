unit View.CadastroProduto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, View.CadastroBase, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Grids, App.Container,
  Core.Services.Produto.Intf, Domain.Produto, System.ImageList, Vcl.ImgList,
  Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection;

type
  TfrmProduto = class(TfrmCadastroBase)
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
    edtPrecoVenda: TEdit;
    GroupBox2: TGroupBox;
    grdProdutos: TStringGrid;
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  private
    FContainer: TAppContainer;
    FProdutoService: IProdutoService;
    FIdProdutoAntesOperacao: Integer;

    procedure ConfigurarTela;
    procedure ConfigurarGrid;
    procedure CarregarProdutoSelecionado;
    procedure SelecionarProdutoNaGrid(AIdProduto: Integer);
    procedure grdProdutosDblClick(Sender: TObject);
    procedure grdProdutosSelectCell(
      Sender: TObject;
      ACol: Longint;
      ARow: Longint;
      var CanSelect: Boolean
    );
    function CriarProdutoDaTela: TProduto;
    function IdSelecionado: Integer;
    function LinhaSelecionadaValida: Boolean;
    function PrecoVendaInformado: Currency;
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
  frmProduto: TfrmProduto;

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

function FormatarPreco(const AValor: Currency): string;
begin
  Result := FormatCurr('R$ #,##0.00', AValor);
end;

{ TfrmProduto }

constructor TfrmProduto.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FIdProdutoAntesOperacao := 0;

  ConfigurarTela;

  if csDesigning in ComponentState then
    Exit;

  FContainer := TAppContainer.Create;
  FProdutoService := FContainer.ProdutoService;

  CarregarLista;
  Modo := mcNavegacao;
end;

destructor TfrmProduto.Destroy;
begin
  FProdutoService := nil;
  FContainer.Free;

  inherited Destroy;
end;

procedure TfrmProduto.ConfigurarTela;
begin
  Caption := 'Cadastro de Produto';

  Panel1.Caption := '';
  pnlBotoes.Caption := '';

  edtCodigo.ReadOnly := True;
  edtCodigo.TabStop := False;
  edtNome.MaxLength := 255;

  ConfigurarGrid;
  LimparCampos;
end;

procedure TfrmProduto.ConfigurarGrid;
begin
  grdProdutos.FixedCols := 0;
  grdProdutos.FixedRows := 1;
  grdProdutos.ColCount := 3;
  grdProdutos.RowCount := 2;
  grdProdutos.DefaultRowHeight := 24;
  grdProdutos.Options := grdProdutos.Options + [goRowSelect] - [goEditing];
  grdProdutos.OnDblClick := grdProdutosDblClick;
  grdProdutos.OnSelectCell := grdProdutosSelectCell;

  grdProdutos.Cells[0, 0] := 'Codigo';
  grdProdutos.Cells[1, 0] := 'Nome do produto';
  grdProdutos.Cells[2, 0] := 'Preco de venda';

  grdProdutos.ColWidths[0] := 80;
  grdProdutos.ColWidths[1] := 430;
  grdProdutos.ColWidths[2] := 180;
end;

procedure TfrmProduto.CarregarLista;
var
  LProdutos: TObjectList<TProduto>;
  I: Integer;
  LRow: Integer;
  LCol: Integer;
begin
  if not Assigned(FProdutoService) then
    Exit;

  LProdutos := FProdutoService.ListarTodos;
  try
    if LProdutos.Count = 0 then
      grdProdutos.RowCount := 2
    else
      grdProdutos.RowCount := LProdutos.Count + 1;

    grdProdutos.Cells[0, 0] := 'Codigo';
    grdProdutos.Cells[1, 0] := 'Nome do produto';
    grdProdutos.Cells[2, 0] := 'Preco de venda';

    for LRow := 1 to grdProdutos.RowCount - 1 do
      for LCol := 0 to grdProdutos.ColCount - 1 do
        grdProdutos.Cells[LCol, LRow] := '';

    for I := 0 to LProdutos.Count - 1 do
    begin
      grdProdutos.Cells[0, I + 1] := IntToStr(LProdutos[I].Id);
      grdProdutos.Cells[1, I + 1] := LProdutos[I].Nome;
      grdProdutos.Cells[2, I + 1] := FormatarPreco(LProdutos[I].PrecoVenda);
    end;

    if grdProdutos.RowCount > 1 then
      grdProdutos.Row := 1;
  finally
    LProdutos.Free;
  end;

  HabilitarBotoes;
end;

procedure TfrmProduto.LimparCampos;
begin
  edtCodigo.Text := '0';
  edtNome.Clear;
  edtPrecoVenda.Text := '0,00';
end;

procedure TfrmProduto.HabilitarCampos(AHabilitar: Boolean);
begin
  edtCodigo.Enabled := False;
  edtNome.Enabled := AHabilitar;
  edtPrecoVenda.Enabled := AHabilitar;
  grdProdutos.Enabled := not AHabilitar;
end;

procedure TfrmProduto.HabilitarBotoes;
begin
  btnNovo.Enabled := Modo = mcNavegacao;
  btnEditar.Enabled := (Modo = mcNavegacao) and LinhaSelecionadaValida;
  btnSalvar.Enabled := Modo in [mcInclusao, mcEdicao];
  btnCancelar.Enabled := Modo in [mcInclusao, mcEdicao];
end;

function TfrmProduto.PodeSalvar: Boolean;
begin
  Result := inherited PodeSalvar and (Modo in [mcInclusao, mcEdicao]);
end;

procedure TfrmProduto.ValidarCampos;
var
  LPrecoVenda: Currency;
begin
  if Trim(edtNome.Text) = '' then
  begin
    edtNome.SetFocus;
    raise Exception.Create('Informe o nome do produto.');
  end;

  if Trim(edtPrecoVenda.Text) = '' then
  begin
    edtPrecoVenda.SetFocus;
    raise Exception.Create('Informe o preco de venda do produto.');
  end;

  if not TextoParaCurrency(edtPrecoVenda.Text, LPrecoVenda) then
  begin
    edtPrecoVenda.SetFocus;
    raise Exception.Create('Preco de venda invalido.');
  end;

  if LPrecoVenda < 0 then
  begin
    edtPrecoVenda.SetFocus;
    raise Exception.Create('Preco de venda nao pode ser negativo.');
  end;
end;

function TfrmProduto.PrecoVendaInformado: Currency;
begin
  if not TextoParaCurrency(edtPrecoVenda.Text, Result) then
    raise Exception.Create('Preco de venda invalido.');
end;

function TfrmProduto.CriarProdutoDaTela: TProduto;
begin
  Result := TProduto.Create;
  try
    if Modo = mcEdicao then
      Result.Id := StrToIntDef(edtCodigo.Text, 0);

    Result.Nome := edtNome.Text;
    Result.PrecoVenda := PrecoVendaInformado;
    Result.Ativo := True;
  except
    Result.Free;
    raise;
  end;
end;

procedure TfrmProduto.PersistirDados;
var
  LProduto: TProduto;
begin
  LProduto := CriarProdutoDaTela;
  try
    FProdutoService.Salvar(LProduto);
  finally
    LProduto.Free;
  end;
end;

procedure TfrmProduto.Novo;
begin
  FIdProdutoAntesOperacao := IdSelecionado;
  inherited Novo;
  edtNome.SetFocus;
end;

procedure TfrmProduto.Editar;
begin
  if not LinhaSelecionadaValida then
  begin
    MessageDlg('Selecione um produto para editar.', mtInformation, [mbOK], 0);
    Exit;
  end;

  FIdProdutoAntesOperacao := IdSelecionado;
  CarregarProdutoSelecionado;
  inherited Editar;
  edtNome.SetFocus;
end;

procedure TfrmProduto.Cancelar;
var
  LIdProdutoRestaurar: Integer;
begin
  LIdProdutoRestaurar := FIdProdutoAntesOperacao;

  LimparCampos;
  Modo := mcNavegacao;
  CarregarLista;
  SelecionarProdutoNaGrid(LIdProdutoRestaurar);
  HabilitarCampos(False);
  HabilitarBotoes;

  FIdProdutoAntesOperacao := 0;
end;

function TfrmProduto.LinhaSelecionadaValida: Boolean;
begin
  Result :=
    (grdProdutos.Row > 0) and
    (grdProdutos.Row < grdProdutos.RowCount) and
    (Trim(grdProdutos.Cells[0, grdProdutos.Row]) <> '');
end;

function TfrmProduto.IdSelecionado: Integer;
begin
  if not LinhaSelecionadaValida then
    Exit(0);

  Result := StrToIntDef(grdProdutos.Cells[0, grdProdutos.Row], 0);
end;

procedure TfrmProduto.CarregarProdutoSelecionado;
var
  LProduto: TProduto;
  LIdProduto: Integer;
begin
  LIdProduto := IdSelecionado;

  if LIdProduto <= 0 then
    raise Exception.Create('Produto selecionado invalido.');

  LProduto := FProdutoService.BuscarPorId(LIdProduto);
  try
    if not Assigned(LProduto) then
      raise Exception.Create('Produto nao encontrado.');

    edtCodigo.Text := IntToStr(LProduto.Id);
    edtNome.Text := LProduto.Nome;
    edtPrecoVenda.Text := FormatCurr('#,##0.00', LProduto.PrecoVenda);
  finally
    LProduto.Free;
  end;
end;

procedure TfrmProduto.SelecionarProdutoNaGrid(AIdProduto: Integer);
var
  LRow: Integer;
begin
  if AIdProduto <= 0 then
    Exit;

  for LRow := 1 to grdProdutos.RowCount - 1 do
  begin
    if StrToIntDef(grdProdutos.Cells[0, LRow], 0) = AIdProduto then
    begin
      grdProdutos.Row := LRow;
      Break;
    end;
  end;
end;

procedure TfrmProduto.grdProdutosDblClick(Sender: TObject);
begin
  Editar;
end;

procedure TfrmProduto.grdProdutosSelectCell(
  Sender: TObject;
  ACol: Longint;
  ARow: Longint;
  var CanSelect: Boolean);
begin
  CanSelect := True;
  HabilitarBotoes;
end;

procedure TfrmProduto.btnCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TfrmProduto.btnEditarClick(Sender: TObject);
begin
  Editar;
end;

procedure TfrmProduto.btnNovoClick(Sender: TObject);
begin
  Novo;
end;

procedure TfrmProduto.btnSalvarClick(Sender: TObject);
begin
  try
    Salvar;
    MessageDlg('Produto salvo com sucesso.', mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
  end;
end;

end.
