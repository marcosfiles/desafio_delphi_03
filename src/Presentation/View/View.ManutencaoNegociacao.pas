unit View.ManutencaoNegociacao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
  App.Container, App.Types, Core.Services.Negociacao.Intf,
  Domain.Negociacao, Domain.NegociacaoItem;

type
  TfrmManutencaoNegociacao = class(TForm)
    pnlCabecalho: TPanel;
    Panel1: TPanel;
    grpLocalizar: TGroupBox;
    Label1: TLabel;
    edtCodigo: TEdit;
    btnBuscar: TButton;
    btnLimpar: TButton;
    grpDados: TGroupBox;
    Label2: TLabel;
    edtProdutor: TEdit;
    Label3: TLabel;
    edtDistribuidor: TEdit;
    Label4: TLabel;
    edtStatus: TEdit;
    Label5: TLabel;
    edtTotal: TEdit;
    Label6: TLabel;
    edtDataCadastro: TEdit;
    Label7: TLabel;
    edtDataAprovacao: TEdit;
    Label8: TLabel;
    edtDataConclusao: TEdit;
    Label9: TLabel;
    edtDataCancelamento: TEdit;
    Label10: TLabel;
    edtCreditoDisponivel: TEdit;
    grpAcoes: TGroupBox;
    btnAprovar: TButton;
    btnConcluir: TButton;
    btnCancelarNegociacao: TButton;
    grpItens: TGroupBox;
    grdItens: TStringGrid;
    grpNegociacoes: TGroupBox;
    grdNegociacoes: TStringGrid;
    procedure btnBuscarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure btnAprovarClick(Sender: TObject);
    procedure btnConcluirClick(Sender: TObject);
    procedure btnCancelarNegociacaoClick(Sender: TObject);
  private
    FContainer: TAppContainer;
    FNegociacaoService: INegociacaoService;
    FNegociacaoAtual: TNegociacao;

    procedure ConfigurarTela;
    procedure ConfigurarGridItens;
    procedure ConfigurarGridNegociacoes;
    procedure CarregarLista;
    procedure CarregarNegociacao(AIdNegociacao: Integer);
    procedure PreencherTela(ANegociacao: TNegociacao);
    procedure LimparCampos;
    procedure LimparGridItens;
    procedure HabilitarAcoes;
    procedure SelecionarNegociacaoNaGrid(AIdNegociacao: Integer);
    procedure ExecutarAcaoNegociacao(const AMensagemConfirmacao: string;
      AAcao: TProc<Integer>);
    procedure grdNegociacoesDblClick(Sender: TObject);
    procedure grdNegociacoesSelectCell(Sender: TObject; ACol: Longint;
      ARow: Longint; var CanSelect: Boolean);

    function IdNegociacaoInformado: Integer;
    function IdNegociacaoSelecionadaGrid: Integer;
    function LinhaNegociacaoSelecionadaValida: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmManutencaoNegociacao: TfrmManutencaoNegociacao;

implementation

{$R *.dfm}

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

{ TfrmManutencaoNegociacao }

constructor TfrmManutencaoNegociacao.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ConfigurarTela;

  if csDesigning in ComponentState then
    Exit;

  FContainer := TAppContainer.Create;
  FNegociacaoService := FContainer.NegociacaoService;

  CarregarLista;
  LimparCampos;
end;

destructor TfrmManutencaoNegociacao.Destroy;
begin
  FreeAndNil(FNegociacaoAtual);
  FNegociacaoService := nil;
  FContainer.Free;

  inherited Destroy;
end;

procedure TfrmManutencaoNegociacao.ConfigurarTela;
begin
  Caption := 'Manutencao de Status da Negociacao';

  pnlCabecalho.Caption := 'Manutencao de Status da Negociacao';
  Panel1.Caption := '';

  edtProdutor.ReadOnly := True;
  edtDistribuidor.ReadOnly := True;
  edtStatus.ReadOnly := True;
  edtTotal.ReadOnly := True;
  edtDataCadastro.ReadOnly := True;
  edtDataAprovacao.ReadOnly := True;
  edtDataConclusao.ReadOnly := True;
  edtDataCancelamento.ReadOnly := True;
  edtCreditoDisponivel.ReadOnly := True;

  ConfigurarGridItens;
  ConfigurarGridNegociacoes;
end;

procedure TfrmManutencaoNegociacao.ConfigurarGridItens;
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
  grdItens.ColWidths[1] := 320;
  grdItens.ColWidths[2] := 110;
  grdItens.ColWidths[3] := 120;
  grdItens.ColWidths[4] := 120;
end;

procedure TfrmManutencaoNegociacao.ConfigurarGridNegociacoes;
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

procedure TfrmManutencaoNegociacao.CarregarLista;
var
  LNegociacoes: TObjectList<TNegociacao>;
  I: Integer;
  LRow: Integer;
  LCol: Integer;
begin
  if not Assigned(FNegociacaoService) then
    Exit;

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

    if LNegociacoes.Count > 0 then
      grdNegociacoes.Row := 1;
  finally
    LNegociacoes.Free;
  end;
end;

procedure TfrmManutencaoNegociacao.CarregarNegociacao(AIdNegociacao: Integer);
var
  LNegociacao: TNegociacao;
begin
  if AIdNegociacao <= 0 then
    raise Exception.Create('Informe o codigo da negociacao.');

  LNegociacao := FNegociacaoService.BuscarPorId(AIdNegociacao);
  try
    if not Assigned(LNegociacao) then
      raise Exception.Create('Negociacao nao encontrada.');

    FreeAndNil(FNegociacaoAtual);
    FNegociacaoAtual := LNegociacao;
    LNegociacao := nil;
  finally
    LNegociacao.Free;
  end;

  PreencherTela(FNegociacaoAtual);
  SelecionarNegociacaoNaGrid(FNegociacaoAtual.Id);
  HabilitarAcoes;
end;

procedure TfrmManutencaoNegociacao.PreencherTela(ANegociacao: TNegociacao);
var
  LItem: TNegociacaoItem;
  LRow: Integer;
  LCol: Integer;
begin
  edtCodigo.Text := IntToStr(ANegociacao.Id);
  edtProdutor.Text := ANegociacao.ProdutorNome;
  edtDistribuidor.Text := ANegociacao.DistribuidorNome;
  edtStatus.Text := StatusNegociacaoToString(ANegociacao.Status);
  edtTotal.Text := FormatarValor(ANegociacao.ValorTotal);
  edtDataCadastro.Text := FormatarData(ANegociacao.DataCadastro);
  edtDataAprovacao.Text := FormatarData(ANegociacao.DataAprovacao);
  edtDataConclusao.Text := FormatarData(ANegociacao.DataConclusao);
  edtDataCancelamento.Text := FormatarData(ANegociacao.DataCancelamento);

  try
    edtCreditoDisponivel.Text := FormatarValor(
      FNegociacaoService.ObterCreditoDisponivel(
        ANegociacao.IdProdutor,
        ANegociacao.IdDistribuidor
      )
    );
  except
    edtCreditoDisponivel.Text := 'Nao informado';
  end;

  if ANegociacao.Itens.Count = 0 then
    grdItens.RowCount := 2
  else
    grdItens.RowCount := ANegociacao.Itens.Count + 1;

  grdItens.Cells[0, 0] := 'Codigo';
  grdItens.Cells[1, 0] := 'Produto';
  grdItens.Cells[2, 0] := 'Quantidade';
  grdItens.Cells[3, 0] := 'Preco unitario';
  grdItens.Cells[4, 0] := 'Total';

  for LRow := 1 to grdItens.RowCount - 1 do
    for LCol := 0 to grdItens.ColCount - 1 do
      grdItens.Cells[LCol, LRow] := '';

  for LRow := 0 to ANegociacao.Itens.Count - 1 do
  begin
    LItem := ANegociacao.Itens[LRow];
    grdItens.Cells[0, LRow + 1] := IntToStr(LItem.IdProduto);
    grdItens.Cells[1, LRow + 1] := LItem.ProdutoNome;
    grdItens.Cells[2, LRow + 1] := FormatarQuantidade(LItem.Quantidade);
    grdItens.Cells[3, LRow + 1] := FormatarValor(LItem.PrecoUnitario);
    grdItens.Cells[4, LRow + 1] := FormatarValor(LItem.ValorTotal);
  end;
end;

procedure TfrmManutencaoNegociacao.LimparCampos;
begin
  FreeAndNil(FNegociacaoAtual);

  edtCodigo.Clear;
  edtProdutor.Clear;
  edtDistribuidor.Clear;
  edtStatus.Clear;
  edtTotal.Clear;
  edtDataCadastro.Clear;
  edtDataAprovacao.Clear;
  edtDataConclusao.Clear;
  edtDataCancelamento.Clear;
  edtCreditoDisponivel.Clear;

  LimparGridItens;
  HabilitarAcoes;
end;

procedure TfrmManutencaoNegociacao.LimparGridItens;
var
  LRow: Integer;
  LCol: Integer;
begin
  grdItens.RowCount := 2;
  grdItens.Cells[0, 0] := 'Codigo';
  grdItens.Cells[1, 0] := 'Produto';
  grdItens.Cells[2, 0] := 'Quantidade';
  grdItens.Cells[3, 0] := 'Preco unitario';
  grdItens.Cells[4, 0] := 'Total';

  for LRow := 1 to grdItens.RowCount - 1 do
    for LCol := 0 to grdItens.ColCount - 1 do
      grdItens.Cells[LCol, LRow] := '';
end;

procedure TfrmManutencaoNegociacao.HabilitarAcoes;
var
  LTemNegociacao: Boolean;
begin
  LTemNegociacao := Assigned(FNegociacaoAtual);

  btnAprovar.Enabled :=
    LTemNegociacao and (FNegociacaoAtual.Status = snPendente);
  btnConcluir.Enabled :=
    LTemNegociacao and (FNegociacaoAtual.Status = snAprovada);
  btnCancelarNegociacao.Enabled :=
    LTemNegociacao and
    (FNegociacaoAtual.Status in [snPendente, snAprovada]);
end;

procedure TfrmManutencaoNegociacao.SelecionarNegociacaoNaGrid(
  AIdNegociacao: Integer);
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

procedure TfrmManutencaoNegociacao.ExecutarAcaoNegociacao(
  const AMensagemConfirmacao: string; AAcao: TProc<Integer>);
var
  LIdNegociacao: Integer;
begin
  if not Assigned(FNegociacaoAtual) then
  begin
    MessageDlg('Busque uma negociacao antes de executar a acao.', mtInformation,
      [mbOK], 0);
    Exit;
  end;

  LIdNegociacao := FNegociacaoAtual.Id;

  if MessageDlg(AMensagemConfirmacao, mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  try
    AAcao(LIdNegociacao);
    CarregarLista;
    CarregarNegociacao(LIdNegociacao);
    MessageDlg('Status da negociacao atualizado com sucesso.', mtInformation,
      [mbOK], 0);
  except
    on E: Exception do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
  end;
end;

function TfrmManutencaoNegociacao.IdNegociacaoInformado: Integer;
begin
  Result := StrToIntDef(Trim(edtCodigo.Text), 0);
end;

function TfrmManutencaoNegociacao.LinhaNegociacaoSelecionadaValida: Boolean;
begin
  Result :=
    (grdNegociacoes.Row > 0) and
    (grdNegociacoes.Row < grdNegociacoes.RowCount) and
    (Trim(grdNegociacoes.Cells[0, grdNegociacoes.Row]) <> '');
end;

function TfrmManutencaoNegociacao.IdNegociacaoSelecionadaGrid: Integer;
begin
  if not LinhaNegociacaoSelecionadaValida then
    Exit(0);

  Result := StrToIntDef(grdNegociacoes.Cells[0, grdNegociacoes.Row], 0);
end;

procedure TfrmManutencaoNegociacao.grdNegociacoesDblClick(Sender: TObject);
var
  LIdNegociacao: Integer;
begin
  LIdNegociacao := IdNegociacaoSelecionadaGrid;

  if LIdNegociacao <= 0 then
    Exit;

  try
    CarregarNegociacao(LIdNegociacao);
  except
    on E: Exception do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
  end;
end;

procedure TfrmManutencaoNegociacao.grdNegociacoesSelectCell(Sender: TObject;
  ACol: Longint; ARow: Longint; var CanSelect: Boolean);
begin
  CanSelect := True;

  if (ARow > 0) and (Trim(grdNegociacoes.Cells[0, ARow]) <> '') then
    edtCodigo.Text := grdNegociacoes.Cells[0, ARow];
end;

procedure TfrmManutencaoNegociacao.btnBuscarClick(Sender: TObject);
begin
  try
    CarregarNegociacao(IdNegociacaoInformado);
  except
    on E: Exception do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
  end;
end;

procedure TfrmManutencaoNegociacao.btnLimparClick(Sender: TObject);
begin
  LimparCampos;
end;

procedure TfrmManutencaoNegociacao.btnAprovarClick(Sender: TObject);
begin
  ExecutarAcaoNegociacao(
    'Deseja aprovar esta negociacao?',
    procedure(AIdNegociacao: Integer)
    begin
      FNegociacaoService.Aprovar(AIdNegociacao);
    end
  );
end;

procedure TfrmManutencaoNegociacao.btnConcluirClick(Sender: TObject);
begin
  ExecutarAcaoNegociacao(
    'Deseja concluir esta negociacao?',
    procedure(AIdNegociacao: Integer)
    begin
      FNegociacaoService.Concluir(AIdNegociacao);
    end
  );
end;

procedure TfrmManutencaoNegociacao.btnCancelarNegociacaoClick(Sender: TObject);
begin
  ExecutarAcaoNegociacao(
    'Deseja cancelar esta negociacao?',
    procedure(AIdNegociacao: Integer)
    begin
      FNegociacaoService.Cancelar(AIdNegociacao);
    end
  );
end;

end.
