unit View.CadastroDistribuidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, View.CadastroBase, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Grids, Vcl.Mask, App.Container,
  Core.Services.Distribuidor.Intf, Domain.Distribuidor, System.ImageList,
  Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection;

type
  TfrmDistribuidor = class(TfrmCadastroBase)
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
    edtCnpj: TMaskEdit;
    GroupBox2: TGroupBox;
    grdDistribuidores: TStringGrid;
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  private
    FContainer: TAppContainer;
    FDistribuidorService: IDistribuidorService;
    FIdDistribuidorAntesOperacao: Integer;

    procedure ConfigurarTela;
    procedure ConfigurarGrid;
    procedure CarregarDistribuidorSelecionado;
    procedure SelecionarDistribuidorNaGrid(AIdDistribuidor: Integer);
    procedure grdDistribuidoresDblClick(Sender: TObject);
    procedure grdDistribuidoresSelectCell(
      Sender: TObject;
      ACol: Longint;
      ARow: Longint;
      var CanSelect: Boolean
    );
    function CriarDistribuidorDaTela: TDistribuidor;
    function IdSelecionado: Integer;
    function LinhaSelecionadaValida: Boolean;
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
  frmDistribuidor: TfrmDistribuidor;

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

function FormatarCnpj(const AValor: string): string;
var
  LDigitos: string;
begin
  LDigitos := SomenteDigitos(AValor);

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

{ TfrmDistribuidor }

constructor TfrmDistribuidor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FIdDistribuidorAntesOperacao := 0;

  ConfigurarTela;

  if csDesigning in ComponentState then
    Exit;

  FContainer := TAppContainer.Create;
  FDistribuidorService := FContainer.DistribuidorService;

  CarregarLista;
  Modo := mcNavegacao;
end;

destructor TfrmDistribuidor.Destroy;
begin
  FDistribuidorService := nil;
  FContainer.Free;

  inherited Destroy;
end;

procedure TfrmDistribuidor.ConfigurarTela;
begin
  Caption := 'Cadastro de Distribuidor';

  Panel1.Caption := '';
  pnlBotoes.Caption := '';

  edtCodigo.ReadOnly := True;
  edtCodigo.TabStop := False;
  edtNome.MaxLength := 255;
  edtCnpj.EditMask := '';
  edtCnpj.MaxLength := 18;

  ConfigurarGrid;
  LimparCampos;
end;

procedure TfrmDistribuidor.ConfigurarGrid;
begin
  grdDistribuidores.FixedCols := 0;
  grdDistribuidores.FixedRows := 1;
  grdDistribuidores.ColCount := 3;
  grdDistribuidores.RowCount := 2;
  grdDistribuidores.DefaultRowHeight := 24;
  grdDistribuidores.Options := grdDistribuidores.Options + [goRowSelect] - [goEditing];
  grdDistribuidores.OnDblClick := grdDistribuidoresDblClick;
  grdDistribuidores.OnSelectCell := grdDistribuidoresSelectCell;

  grdDistribuidores.Cells[0, 0] := 'Codigo';
  grdDistribuidores.Cells[1, 0] := 'Nome do distribuidor';
  grdDistribuidores.Cells[2, 0] := 'CNPJ';

  grdDistribuidores.ColWidths[0] := 80;
  grdDistribuidores.ColWidths[1] := 430;
  grdDistribuidores.ColWidths[2] := 180;
end;

procedure TfrmDistribuidor.CarregarLista;
var
  LDistribuidores: TObjectList<TDistribuidor>;
  I: Integer;
  LRow: Integer;
  LCol: Integer;
begin
  if not Assigned(FDistribuidorService) then
    Exit;

  LDistribuidores := FDistribuidorService.ListarTodos;
  try
    if LDistribuidores.Count = 0 then
      grdDistribuidores.RowCount := 2
    else
      grdDistribuidores.RowCount := LDistribuidores.Count + 1;

    grdDistribuidores.Cells[0, 0] := 'Codigo';
    grdDistribuidores.Cells[1, 0] := 'Nome do distribuidor';
    grdDistribuidores.Cells[2, 0] := 'CNPJ';

    for LRow := 1 to grdDistribuidores.RowCount - 1 do
      for LCol := 0 to grdDistribuidores.ColCount - 1 do
        grdDistribuidores.Cells[LCol, LRow] := '';

    for I := 0 to LDistribuidores.Count - 1 do
    begin
      grdDistribuidores.Cells[0, I + 1] := IntToStr(LDistribuidores[I].Id);
      grdDistribuidores.Cells[1, I + 1] := LDistribuidores[I].Nome;
      grdDistribuidores.Cells[2, I + 1] := FormatarCnpj(LDistribuidores[I].Cnpj);
    end;

    if grdDistribuidores.RowCount > 1 then
      grdDistribuidores.Row := 1;
  finally
    LDistribuidores.Free;
  end;

  HabilitarBotoes;
end;

procedure TfrmDistribuidor.LimparCampos;
begin
  edtCodigo.Text := '0';
  edtNome.Clear;
  edtCnpj.Clear;
end;

procedure TfrmDistribuidor.HabilitarCampos(AHabilitar: Boolean);
begin
  edtCodigo.Enabled := False;
  edtNome.Enabled := AHabilitar;
  edtCnpj.Enabled := AHabilitar;
  grdDistribuidores.Enabled := not AHabilitar;
end;

procedure TfrmDistribuidor.HabilitarBotoes;
begin
  btnNovo.Enabled := Modo = mcNavegacao;
  btnEditar.Enabled := (Modo = mcNavegacao) and LinhaSelecionadaValida;
  btnSalvar.Enabled := Modo in [mcInclusao, mcEdicao];
  btnCancelar.Enabled := Modo in [mcInclusao, mcEdicao];
end;

function TfrmDistribuidor.PodeSalvar: Boolean;
begin
  Result := inherited PodeSalvar and (Modo in [mcInclusao, mcEdicao]);
end;

procedure TfrmDistribuidor.ValidarCampos;
var
  LCnpj: string;
begin
  if Trim(edtNome.Text) = '' then
  begin
    edtNome.SetFocus;
    raise Exception.Create('Informe o nome do distribuidor.');
  end;

  LCnpj := SomenteDigitos(edtCnpj.Text);

  if LCnpj = '' then
  begin
    edtCnpj.SetFocus;
    raise Exception.Create('Informe o CNPJ do distribuidor.');
  end;

  if Length(LCnpj) <> 14 then
  begin
    edtCnpj.SetFocus;
    raise Exception.Create('CNPJ deve conter 14 digitos.');
  end;
end;

function TfrmDistribuidor.CriarDistribuidorDaTela: TDistribuidor;
begin
  Result := TDistribuidor.Create;
  try
    if Modo = mcEdicao then
      Result.Id := StrToIntDef(edtCodigo.Text, 0);

    Result.Nome := edtNome.Text;
    Result.Cnpj := SomenteDigitos(edtCnpj.Text);
    Result.Ativo := True;
  except
    Result.Free;
    raise;
  end;
end;

procedure TfrmDistribuidor.PersistirDados;
var
  LDistribuidor: TDistribuidor;
begin
  LDistribuidor := CriarDistribuidorDaTela;
  try
    FDistribuidorService.Salvar(LDistribuidor);
  finally
    LDistribuidor.Free;
  end;
end;

procedure TfrmDistribuidor.Novo;
begin
  FIdDistribuidorAntesOperacao := IdSelecionado;
  inherited Novo;
  edtNome.SetFocus;
end;

procedure TfrmDistribuidor.Editar;
begin
  if not LinhaSelecionadaValida then
  begin
    MessageDlg('Selecione um distribuidor para editar.', mtInformation, [mbOK], 0);
    Exit;
  end;

  FIdDistribuidorAntesOperacao := IdSelecionado;
  CarregarDistribuidorSelecionado;
  inherited Editar;
  edtNome.SetFocus;
end;

procedure TfrmDistribuidor.Cancelar;
var
  LIdDistribuidorRestaurar: Integer;
begin
  LIdDistribuidorRestaurar := FIdDistribuidorAntesOperacao;

  LimparCampos;
  Modo := mcNavegacao;
  CarregarLista;
  SelecionarDistribuidorNaGrid(LIdDistribuidorRestaurar);
  HabilitarCampos(False);
  HabilitarBotoes;

  FIdDistribuidorAntesOperacao := 0;
end;

function TfrmDistribuidor.LinhaSelecionadaValida: Boolean;
begin
  Result :=
    (grdDistribuidores.Row > 0) and
    (grdDistribuidores.Row < grdDistribuidores.RowCount) and
    (Trim(grdDistribuidores.Cells[0, grdDistribuidores.Row]) <> '');
end;

function TfrmDistribuidor.IdSelecionado: Integer;
begin
  if not LinhaSelecionadaValida then
    Exit(0);

  Result := StrToIntDef(grdDistribuidores.Cells[0, grdDistribuidores.Row], 0);
end;

procedure TfrmDistribuidor.CarregarDistribuidorSelecionado;
var
  LDistribuidor: TDistribuidor;
  LIdDistribuidor: Integer;
begin
  LIdDistribuidor := IdSelecionado;

  if LIdDistribuidor <= 0 then
    raise Exception.Create('Distribuidor selecionado invalido.');

  LDistribuidor := FDistribuidorService.BuscarPorId(LIdDistribuidor);
  try
    if not Assigned(LDistribuidor) then
      raise Exception.Create('Distribuidor nao encontrado.');

    edtCodigo.Text := IntToStr(LDistribuidor.Id);
    edtNome.Text := LDistribuidor.Nome;
    edtCnpj.Text := FormatarCnpj(LDistribuidor.Cnpj);
  finally
    LDistribuidor.Free;
  end;
end;

procedure TfrmDistribuidor.SelecionarDistribuidorNaGrid(AIdDistribuidor: Integer);
var
  LRow: Integer;
begin
  if AIdDistribuidor <= 0 then
    Exit;

  for LRow := 1 to grdDistribuidores.RowCount - 1 do
  begin
    if StrToIntDef(grdDistribuidores.Cells[0, LRow], 0) = AIdDistribuidor then
    begin
      grdDistribuidores.Row := LRow;
      Break;
    end;
  end;
end;

procedure TfrmDistribuidor.grdDistribuidoresDblClick(Sender: TObject);
begin
  Editar;
end;

procedure TfrmDistribuidor.grdDistribuidoresSelectCell(
  Sender: TObject;
  ACol: Longint;
  ARow: Longint;
  var CanSelect: Boolean);
begin
  CanSelect := True;
  HabilitarBotoes;
end;

procedure TfrmDistribuidor.btnCancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TfrmDistribuidor.btnEditarClick(Sender: TObject);
begin
  Editar;
end;

procedure TfrmDistribuidor.btnNovoClick(Sender: TObject);
begin
  Novo;
end;

procedure TfrmDistribuidor.btnSalvarClick(Sender: TObject);
begin
  try
    Salvar;
    MessageDlg('Distribuidor salvo com sucesso.', mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
  end;
end;

end.
