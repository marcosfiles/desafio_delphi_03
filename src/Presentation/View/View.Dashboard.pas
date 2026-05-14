unit View.Dashboard;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
  App.Container, App.Types, Core.Services.Negociacao.Intf,
  Domain.Negociacao;

type
  TfrmDashboard = class(TForm)
    pnlCabecalho: TPanel;
    pnlResumo: TPanel;
    pnlPendentes: TPanel;
    lblTituloPendentes: TLabel;
    lblTotalPendentes: TLabel;
    pnlAprovadas: TPanel;
    lblTituloAprovadas: TLabel;
    lblTotalAprovadas: TLabel;
    pnlConcluidas: TPanel;
    lblTituloConcluidas: TLabel;
    lblTotalConcluidas: TLabel;
    pnlCanceladas: TPanel;
    lblTituloCanceladas: TLabel;
    lblTotalCanceladas: TLabel;
    grpNegociacoes: TGroupBox;
    grdNegociacoes: TStringGrid;
  private
    FContainer: TAppContainer;
    FNegociacaoService: INegociacaoService;

    procedure ConfigurarTela;
    procedure ConfigurarCard(APanel: TPanel; ATitulo: TLabel; ATotal: TLabel;
      const ACor: TColor);
    procedure ConfigurarGrid;
    procedure CarregarDados;
    procedure LimparGrid;
    procedure ZerarTotais;
    function StatusDescricao(AStatus: TStatusNegociacao): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmDashboard: TfrmDashboard;

implementation

{$R *.dfm}

function FormatarValor(const AValor: Currency): string;
begin
  Result := FormatCurr('R$ #,##0.00', AValor);
end;

function FormatarData(const AValor: TDateTime): string;
begin
  if AValor <= 0 then
    Exit('');

  Result := FormatDateTime('dd/mm/yyyy hh:nn', AValor);
end;

{ TfrmDashboard }

constructor TfrmDashboard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ConfigurarTela;

  if csDesigning in ComponentState then
    Exit;

  try
    FContainer := TAppContainer.Create;
    FNegociacaoService := FContainer.NegociacaoService;
    CarregarDados;
  except
    on E: Exception do
    begin
      ZerarTotais;
      LimparGrid;
      grdNegociacoes.Cells[1, 1] :=
        'Nao foi possivel carregar as negociacoes: ' + E.Message;
    end;
  end;
end;

destructor TfrmDashboard.Destroy;
begin
  FNegociacaoService := nil;
  FContainer.Free;

  inherited Destroy;
end;

procedure TfrmDashboard.ConfigurarTela;
begin
  Caption := 'Dashboard';

  pnlCabecalho.Caption := 'Dashboard';
  pnlCabecalho.Font.Style := [fsBold];

  ConfigurarCard(pnlPendentes, lblTituloPendentes, lblTotalPendentes,
    clOlive);
  ConfigurarCard(pnlAprovadas, lblTituloAprovadas, lblTotalAprovadas,
    clGreen);
  ConfigurarCard(pnlConcluidas, lblTituloConcluidas, lblTotalConcluidas,
    clNavy);
  ConfigurarCard(pnlCanceladas, lblTituloCanceladas, lblTotalCanceladas,
    clRed);

  ConfigurarGrid;
  ZerarTotais;
  LimparGrid;
end;

procedure TfrmDashboard.ConfigurarCard(APanel: TPanel; ATitulo: TLabel;
  ATotal: TLabel; const ACor: TColor);
begin
  APanel.ParentBackground := False;
  APanel.Color := clWhite;
  APanel.BevelOuter := bvLowered;

  ATitulo.Font.Color := ACor;
  ATitulo.Font.Style := [fsBold];

  ATotal.Font.Color := ACor;
  ATotal.Font.Style := [fsBold];
end;

procedure TfrmDashboard.ConfigurarGrid;
begin
  grdNegociacoes.FixedCols := 0;
  grdNegociacoes.FixedRows := 1;
  grdNegociacoes.ColCount := 6;
  grdNegociacoes.RowCount := 2;
  grdNegociacoes.DefaultRowHeight := 24;
  grdNegociacoes.Options :=
    grdNegociacoes.Options + [goRowSelect] - [goEditing];

  grdNegociacoes.Cells[0, 0] := 'Codigo';
  grdNegociacoes.Cells[1, 0] := 'Data';
  grdNegociacoes.Cells[2, 0] := 'Produtor';
  grdNegociacoes.Cells[3, 0] := 'Distribuidor';
  grdNegociacoes.Cells[4, 0] := 'Status';
  grdNegociacoes.Cells[5, 0] := 'Valor Total';

  grdNegociacoes.ColWidths[0] := 60;
  grdNegociacoes.ColWidths[1] := 110;
  grdNegociacoes.ColWidths[2] := 190;
  grdNegociacoes.ColWidths[3] := 190;
  grdNegociacoes.ColWidths[4] := 90;
  grdNegociacoes.ColWidths[5] := 110;
end;

procedure TfrmDashboard.CarregarDados;
var
  LNegociacoes: TObjectList<TNegociacao>;
  LNegociacao: TNegociacao;
  LPendentes: Integer;
  LAprovadas: Integer;
  LConcluidas: Integer;
  LCanceladas: Integer;
  LRow: Integer;
begin
  if not Assigned(FNegociacaoService) then
    Exit;

  LNegociacoes := FNegociacaoService.ListarTodos;
  try
    LPendentes := 0;
    LAprovadas := 0;
    LConcluidas := 0;
    LCanceladas := 0;

    if LNegociacoes.Count = 0 then
      grdNegociacoes.RowCount := 2
    else
      grdNegociacoes.RowCount := LNegociacoes.Count + 1;

    LimparGrid;
    LRow := 1;

    for LNegociacao in LNegociacoes do
    begin
      case LNegociacao.Status of
        snPendente:
          Inc(LPendentes);
        snAprovada:
          Inc(LAprovadas);
        snConcluida:
          Inc(LConcluidas);
        snCancelada:
          Inc(LCanceladas);
      end;

      grdNegociacoes.Cells[0, LRow] := IntToStr(LNegociacao.Id);
      grdNegociacoes.Cells[1, LRow] := FormatarData(
        LNegociacao.DataCadastro);
      grdNegociacoes.Cells[2, LRow] := LNegociacao.ProdutorNome;
      grdNegociacoes.Cells[3, LRow] := LNegociacao.DistribuidorNome;
      grdNegociacoes.Cells[4, LRow] := StatusDescricao(
        LNegociacao.Status);
      grdNegociacoes.Cells[5, LRow] := FormatarValor(
        LNegociacao.ValorTotal);

      Inc(LRow);
    end;

    lblTotalPendentes.Caption := IntToStr(LPendentes);
    lblTotalAprovadas.Caption := IntToStr(LAprovadas);
    lblTotalConcluidas.Caption := IntToStr(LConcluidas);
    lblTotalCanceladas.Caption := IntToStr(LCanceladas);

    if LNegociacoes.Count = 0 then
      grdNegociacoes.Cells[1, 1] := 'Nenhuma negociacao encontrada.';
  finally
    LNegociacoes.Free;
  end;
end;

procedure TfrmDashboard.LimparGrid;
var
  LCol: Integer;
  LRow: Integer;
begin
  grdNegociacoes.Cells[0, 0] := 'Codigo';
  grdNegociacoes.Cells[1, 0] := 'Data';
  grdNegociacoes.Cells[2, 0] := 'Produtor';
  grdNegociacoes.Cells[3, 0] := 'Distribuidor';
  grdNegociacoes.Cells[4, 0] := 'Status';
  grdNegociacoes.Cells[5, 0] := 'Valor Total';

  for LRow := 1 to grdNegociacoes.RowCount - 1 do
    for LCol := 0 to grdNegociacoes.ColCount - 1 do
      grdNegociacoes.Cells[LCol, LRow] := '';
end;

procedure TfrmDashboard.ZerarTotais;
begin
  lblTotalPendentes.Caption := '0';
  lblTotalAprovadas.Caption := '0';
  lblTotalConcluidas.Caption := '0';
  lblTotalCanceladas.Caption := '0';
end;

function TfrmDashboard.StatusDescricao(AStatus: TStatusNegociacao): string;
begin
  case AStatus of
    snPendente:
      Result := 'Pendente';
    snAprovada:
      Result := 'Aprovada';
    snConcluida:
      Result := 'Concluida';
    snCancelada:
      Result := 'Cancelada';
  else
    Result := '';
  end;
end;

end.
