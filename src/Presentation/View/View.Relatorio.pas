unit View.Relatorio;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections, System.Types, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.Printers,
  App.Container, App.Types, Core.Services.Negociacao.Intf,
  Core.Services.Produtor.Intf, Core.Services.Distribuidor.Intf,
  Domain.Negociacao, Domain.Produtor, Domain.Distribuidor;

type
  TfrmRelatorio = class(TForm)
    pnlCabecalho: TPanel;
    Panel1: TPanel;
    grpFiltros: TGroupBox;
    Label1: TLabel;
    cmbFiltroProdutor: TComboBox;
    Label2: TLabel;
    cmbFiltroDistribuidor: TComboBox;
    btnFiltrar: TButton;
    btnLimpar: TButton;
    btnImprimir: TButton;
    grpNegociacoes: TGroupBox;
    grdNegociacoes: TStringGrid;
    dlgImpressao: TPrintDialog;
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
  private
    FContainer: TAppContainer;
    FNegociacaoService: INegociacaoService;
    FProdutorService: IProdutorService;
    FDistribuidorService: IDistribuidorService;
    FProdutores: TObjectList<TProdutor>;
    FDistribuidores: TObjectList<TDistribuidor>;
    FNegociacoesFiltradas: TObjectList<TNegociacao>;

    procedure ConfigurarTela;
    procedure ConfigurarGridNegociacoes;
    procedure CarregarCombosFiltro;
    procedure CarregarLista;
    procedure LimparFiltros;
    procedure HabilitarBotoes;
    procedure ImprimirRelatorio;

    function IdProdutorFiltroSelecionado: Integer;
    function IdDistribuidorFiltroSelecionado: Integer;
    function NegociacaoAtendeFiltros(ANegociacao: TNegociacao): Boolean;
    function DescricaoFiltrosRelatorio: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  frmRelatorio: TfrmRelatorio;

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

{ TfrmRelatorio }

constructor TfrmRelatorio.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FNegociacoesFiltradas := TObjectList<TNegociacao>.Create(True);

  ConfigurarTela;

  if csDesigning in ComponentState then
    Exit;

  FContainer := TAppContainer.Create;
  FNegociacaoService := FContainer.NegociacaoService;
  FProdutorService := FContainer.ProdutorService;
  FDistribuidorService := FContainer.DistribuidorService;

  CarregarCombosFiltro;
  CarregarLista;
end;

destructor TfrmRelatorio.Destroy;
begin
  FNegociacoesFiltradas.Free;
  FProdutores.Free;
  FDistribuidores.Free;
  FNegociacaoService := nil;
  FProdutorService := nil;
  FDistribuidorService := nil;
  FContainer.Free;

  inherited Destroy;
end;

procedure TfrmRelatorio.ConfigurarTela;
begin
  Caption := 'Relatorio de Negociacoes';

  pnlCabecalho.Caption := 'Relatorio de Negociacoes';
  Panel1.Caption := '';
  cmbFiltroProdutor.Style := csDropDownList;
  cmbFiltroDistribuidor.Style := csDropDownList;
  btnImprimir.Enabled := False;

  ConfigurarGridNegociacoes;
end;

procedure TfrmRelatorio.ConfigurarGridNegociacoes;
begin
  grdNegociacoes.FixedCols := 0;
  grdNegociacoes.FixedRows := 1;
  grdNegociacoes.ColCount := 9;
  grdNegociacoes.RowCount := 2;
  grdNegociacoes.DefaultRowHeight := 24;
  grdNegociacoes.Options := grdNegociacoes.Options + [goRowSelect] - [goEditing];

  grdNegociacoes.Cells[0, 0] := 'Contrato';
  grdNegociacoes.Cells[1, 0] := 'Cadastro';
  grdNegociacoes.Cells[2, 0] := 'Aprovacao';
  grdNegociacoes.Cells[3, 0] := 'Conclusao';
  grdNegociacoes.Cells[4, 0] := 'Cancelamento';
  grdNegociacoes.Cells[5, 0] := 'Produtor';
  grdNegociacoes.Cells[6, 0] := 'Distribuidor';
  grdNegociacoes.Cells[7, 0] := 'Status';
  grdNegociacoes.Cells[8, 0] := 'Total';

  grdNegociacoes.ColWidths[0] := 80;
  grdNegociacoes.ColWidths[1] := 120;
  grdNegociacoes.ColWidths[2] := 120;
  grdNegociacoes.ColWidths[3] := 120;
  grdNegociacoes.ColWidths[4] := 120;
  grdNegociacoes.ColWidths[5] := 190;
  grdNegociacoes.ColWidths[6] := 190;
  grdNegociacoes.ColWidths[7] := 90;
  grdNegociacoes.ColWidths[8] := 110;
end;

procedure TfrmRelatorio.CarregarCombosFiltro;
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

  cmbFiltroProdutor.Items.BeginUpdate;
  try
    cmbFiltroProdutor.Clear;
    cmbFiltroProdutor.Items.Add('Todos');

    for I := 0 to FProdutores.Count - 1 do
      cmbFiltroProdutor.Items.Add(FProdutores[I].Nome);

    cmbFiltroProdutor.ItemIndex := 0;
  finally
    cmbFiltroProdutor.Items.EndUpdate;
  end;

  cmbFiltroDistribuidor.Items.BeginUpdate;
  try
    cmbFiltroDistribuidor.Clear;
    cmbFiltroDistribuidor.Items.Add('Todos');

    for I := 0 to FDistribuidores.Count - 1 do
      cmbFiltroDistribuidor.Items.Add(FDistribuidores[I].Nome);

    cmbFiltroDistribuidor.ItemIndex := 0;
  finally
    cmbFiltroDistribuidor.Items.EndUpdate;
  end;
end;

procedure TfrmRelatorio.CarregarLista;
var
  I: Integer;
  LRow: Integer;
  LCol: Integer;
begin
  if not Assigned(FNegociacaoService) then
    Exit;

  FreeAndNil(FNegociacoesFiltradas);
  FNegociacoesFiltradas := FNegociacaoService.ListarTodos;

  for I := FNegociacoesFiltradas.Count - 1 downto 0 do
    if not NegociacaoAtendeFiltros(FNegociacoesFiltradas[I]) then
      FNegociacoesFiltradas.Delete(I);

  if FNegociacoesFiltradas.Count = 0 then
    grdNegociacoes.RowCount := 2
  else
    grdNegociacoes.RowCount := FNegociacoesFiltradas.Count + 1;

  grdNegociacoes.Cells[0, 0] := 'Contrato';
  grdNegociacoes.Cells[1, 0] := 'Cadastro';
  grdNegociacoes.Cells[2, 0] := 'Aprovacao';
  grdNegociacoes.Cells[3, 0] := 'Conclusao';
  grdNegociacoes.Cells[4, 0] := 'Cancelamento';
  grdNegociacoes.Cells[5, 0] := 'Produtor';
  grdNegociacoes.Cells[6, 0] := 'Distribuidor';
  grdNegociacoes.Cells[7, 0] := 'Status';
  grdNegociacoes.Cells[8, 0] := 'Total';

  for LRow := 1 to grdNegociacoes.RowCount - 1 do
    for LCol := 0 to grdNegociacoes.ColCount - 1 do
      grdNegociacoes.Cells[LCol, LRow] := '';

  for I := 0 to FNegociacoesFiltradas.Count - 1 do
  begin
    grdNegociacoes.Cells[0, I + 1] :=
      IntToStr(FNegociacoesFiltradas[I].Id);
    grdNegociacoes.Cells[1, I + 1] :=
      FormatarData(FNegociacoesFiltradas[I].DataCadastro);
    grdNegociacoes.Cells[2, I + 1] :=
      FormatarData(FNegociacoesFiltradas[I].DataAprovacao);
    grdNegociacoes.Cells[3, I + 1] :=
      FormatarData(FNegociacoesFiltradas[I].DataConclusao);
    grdNegociacoes.Cells[4, I + 1] :=
      FormatarData(FNegociacoesFiltradas[I].DataCancelamento);
    grdNegociacoes.Cells[5, I + 1] := FNegociacoesFiltradas[I].ProdutorNome;
    grdNegociacoes.Cells[6, I + 1] :=
      FNegociacoesFiltradas[I].DistribuidorNome;
    grdNegociacoes.Cells[7, I + 1] :=
      StatusNegociacaoToString(FNegociacoesFiltradas[I].Status);
    grdNegociacoes.Cells[8, I + 1] :=
      FormatarValor(FNegociacoesFiltradas[I].ValorTotal);
  end;

  if FNegociacoesFiltradas.Count > 0 then
    grdNegociacoes.Row := 1;

  HabilitarBotoes;
end;

procedure TfrmRelatorio.LimparFiltros;
begin
  if cmbFiltroProdutor.Items.Count > 0 then
    cmbFiltroProdutor.ItemIndex := 0;

  if cmbFiltroDistribuidor.Items.Count > 0 then
    cmbFiltroDistribuidor.ItemIndex := 0;
end;

procedure TfrmRelatorio.HabilitarBotoes;
begin
  btnImprimir.Enabled :=
    Assigned(FNegociacoesFiltradas) and (FNegociacoesFiltradas.Count > 0);
end;

function TfrmRelatorio.IdProdutorFiltroSelecionado: Integer;
begin
  Result := 0;

  if (not Assigned(FProdutores)) or (cmbFiltroProdutor.ItemIndex <= 0) then
    Exit;

  if (cmbFiltroProdutor.ItemIndex - 1) < FProdutores.Count then
    Result := FProdutores[cmbFiltroProdutor.ItemIndex - 1].Id;
end;

function TfrmRelatorio.IdDistribuidorFiltroSelecionado: Integer;
begin
  Result := 0;

  if (not Assigned(FDistribuidores)) or
    (cmbFiltroDistribuidor.ItemIndex <= 0) then
    Exit;

  if (cmbFiltroDistribuidor.ItemIndex - 1) < FDistribuidores.Count then
    Result := FDistribuidores[cmbFiltroDistribuidor.ItemIndex - 1].Id;
end;

function TfrmRelatorio.NegociacaoAtendeFiltros(
  ANegociacao: TNegociacao): Boolean;
var
  LIdProdutor: Integer;
  LIdDistribuidor: Integer;
begin
  Result := False;

  if not Assigned(ANegociacao) then
    Exit;

  LIdProdutor := IdProdutorFiltroSelecionado;
  LIdDistribuidor := IdDistribuidorFiltroSelecionado;

  if (LIdProdutor > 0) and (ANegociacao.IdProdutor <> LIdProdutor) then
    Exit;

  if (LIdDistribuidor > 0) and
    (ANegociacao.IdDistribuidor <> LIdDistribuidor) then
    Exit;

  Result := True;
end;

function TfrmRelatorio.DescricaoFiltrosRelatorio: string;
var
  LProdutor: string;
  LDistribuidor: string;
begin
  LProdutor := 'Todos';
  LDistribuidor := 'Todos';

  if cmbFiltroProdutor.ItemIndex > 0 then
    LProdutor := cmbFiltroProdutor.Text;

  if cmbFiltroDistribuidor.ItemIndex > 0 then
    LDistribuidor := cmbFiltroDistribuidor.Text;

  Result := Format('Produtor: %s | Distribuidor: %s',
    [LProdutor, LDistribuidor]);
end;

procedure TfrmRelatorio.ImprimirRelatorio;
var
  LMargemEsquerda: Integer;
  LMargemDireita: Integer;
  LTopo: Integer;
  LRodape: Integer;
  LArea: Integer;
  LY: Integer;
  LAlturaLinha: Integer;
  LPagina: Integer;
  I: Integer;
  LColunas: array[0..8] of Integer;
  LNegociacao: TNegociacao;
  LOrientacaoAnterior: TPrinterOrientation;
  LDocumentoIniciado: Boolean;
  LTotalRelatorio: Currency;

  procedure CalcularColunas;
  begin
    LArea := LMargemDireita - LMargemEsquerda;
    LColunas[0] := LMargemEsquerda;
    LColunas[1] := LColunas[0] + MulDiv(LArea, 8, 100);
    LColunas[2] := LColunas[1] + MulDiv(LArea, 18, 100);
    LColunas[3] := LColunas[2] + MulDiv(LArea, 18, 100);
    LColunas[4] := LColunas[3] + MulDiv(LArea, 12, 100);
    LColunas[5] := LColunas[4] + MulDiv(LArea, 12, 100);
    LColunas[6] := LColunas[5] + MulDiv(LArea, 12, 100);
    LColunas[7] := LColunas[6] + MulDiv(LArea, 12, 100);
    LColunas[8] := LMargemDireita;
  end;

  procedure ImprimirTexto(const ATexto: string; const ARect: TRect;
    AAlinhamento: Cardinal);
  var
    LRect: TRect;
    LTexto: string;
  begin
    LRect := ARect;
    InflateRect(LRect, -4, -2);
    LTexto := ATexto;

    DrawText(
      Printer.Canvas.Handle,
      PChar(LTexto),
      Length(LTexto),
      LRect,
      DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS or AAlinhamento
    );
  end;

  procedure ImprimirCelula(const ATexto: string; AColuna: Integer;
    ATopo: Integer; ABaixo: Integer; AAlinhamento: Cardinal);
  var
    LRect: TRect;
  begin
    LRect := Rect(LColunas[AColuna], ATopo, LColunas[AColuna + 1], ABaixo);
    Printer.Canvas.Rectangle(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom);
    ImprimirTexto(ATexto, LRect, AAlinhamento);
  end;

  procedure ImprimirCabecalhoTabela;
  begin
    Printer.Canvas.Brush.Color := $00F2F2F2;
    Printer.Canvas.Font.Style := [fsBold];

    ImprimirCelula('Contrato', 0, LY, LY + LAlturaLinha, DT_LEFT);
    ImprimirCelula('Produtor', 1, LY, LY + LAlturaLinha, DT_LEFT);
    ImprimirCelula('Distribuidor', 2, LY, LY + LAlturaLinha, DT_LEFT);
    ImprimirCelula('Cadastro', 3, LY, LY + LAlturaLinha, DT_LEFT);
    ImprimirCelula('Aprovacao', 4, LY, LY + LAlturaLinha, DT_LEFT);
    ImprimirCelula('Conclusao', 5, LY, LY + LAlturaLinha, DT_LEFT);
    ImprimirCelula('Cancelamento', 6, LY, LY + LAlturaLinha, DT_LEFT);
    ImprimirCelula('Valor', 7, LY, LY + LAlturaLinha, DT_RIGHT);

    Printer.Canvas.Font.Style := [];
    Printer.Canvas.Brush.Color := clWhite;
    Inc(LY, LAlturaLinha);
  end;

  procedure ImprimirCabecalhoPagina;
  var
    LPaginaTexto: string;
  begin
    Printer.Canvas.Font.Name := 'Segoe UI';
    Printer.Canvas.Font.Color := clBlack;
    Printer.Canvas.Brush.Color := clWhite;
    Printer.Canvas.Font.Size := 12;
    Printer.Canvas.Font.Style := [fsBold];

    LY := LTopo;
    Printer.Canvas.TextOut(LMargemEsquerda, LY, 'Relatorio de negociacoes');

    LPaginaTexto := Format('Pagina %d', [LPagina]);
    Printer.Canvas.TextOut(
      LMargemDireita - Printer.Canvas.TextWidth(LPaginaTexto),
      LY,
      LPaginaTexto
    );

    Inc(LY, Printer.Canvas.TextHeight('Ag') + 8);
    Printer.Canvas.Font.Size := 8;
    Printer.Canvas.Font.Style := [];
    Printer.Canvas.TextOut(LMargemEsquerda, LY, DescricaoFiltrosRelatorio);

    Inc(LY, Printer.Canvas.TextHeight('Ag') + 6);
    Printer.Canvas.TextOut(
      LMargemEsquerda,
      LY,
      Format('Emitido em %s', [FormatDateTime('dd/mm/yyyy hh:nn', Now)])
    );

    Inc(LY, Printer.Canvas.TextHeight('Ag') + 10);
    Printer.Canvas.MoveTo(LMargemEsquerda, LY);
    Printer.Canvas.LineTo(LMargemDireita, LY);
    Inc(LY, 8);

    Printer.Canvas.Font.Size := 8;
    LAlturaLinha := Printer.Canvas.TextHeight('Ag') + 12;
    ImprimirCabecalhoTabela;
  end;

begin
  if (not Assigned(FNegociacoesFiltradas)) or
    (FNegociacoesFiltradas.Count = 0) then
    raise Exception.Create('Nao existem negociacoes para imprimir.');

  LOrientacaoAnterior := Printer.Orientation;
  LDocumentoIniciado := False;
  LTotalRelatorio := 0;

  try
    Printer.Orientation := poLandscape;
    Printer.Title := 'Relatorio de negociacoes';
    Printer.BeginDoc;
    LDocumentoIniciado := True;

    LMargemEsquerda := MulDiv(Printer.PageWidth, 4, 100);
    LMargemDireita := Printer.PageWidth - LMargemEsquerda;
    LTopo := MulDiv(Printer.PageHeight, 5, 100);
    LRodape := Printer.PageHeight - LTopo;
    LPagina := 1;
    CalcularColunas;
    ImprimirCabecalhoPagina;

    for I := 0 to FNegociacoesFiltradas.Count - 1 do
    begin
      if (LY + LAlturaLinha) > LRodape then
      begin
        Printer.NewPage;
        Inc(LPagina);
        ImprimirCabecalhoPagina;
      end;

      LNegociacao := FNegociacoesFiltradas[I];
      ImprimirCelula(IntToStr(LNegociacao.Id), 0, LY, LY + LAlturaLinha,
        DT_LEFT);
      ImprimirCelula(LNegociacao.ProdutorNome, 1, LY, LY + LAlturaLinha,
        DT_LEFT);
      ImprimirCelula(LNegociacao.DistribuidorNome, 2, LY, LY + LAlturaLinha,
        DT_LEFT);
      ImprimirCelula(FormatarData(LNegociacao.DataCadastro), 3, LY,
        LY + LAlturaLinha, DT_LEFT);
      ImprimirCelula(FormatarData(LNegociacao.DataAprovacao), 4, LY,
        LY + LAlturaLinha, DT_LEFT);
      ImprimirCelula(FormatarData(LNegociacao.DataConclusao), 5, LY,
        LY + LAlturaLinha, DT_LEFT);
      ImprimirCelula(FormatarData(LNegociacao.DataCancelamento), 6, LY,
        LY + LAlturaLinha, DT_LEFT);
      ImprimirCelula(FormatarValor(LNegociacao.ValorTotal), 7, LY,
        LY + LAlturaLinha, DT_RIGHT);

      LTotalRelatorio := LTotalRelatorio + LNegociacao.ValorTotal;
      Inc(LY, LAlturaLinha);
    end;

    Inc(LY, 10);

    if (LY + LAlturaLinha) > LRodape then
    begin
      Printer.NewPage;
      Inc(LPagina);
      ImprimirCabecalhoPagina;
    end;

    Printer.Canvas.Font.Style := [fsBold];
    Printer.Canvas.TextOut(
      LMargemEsquerda,
      LY,
      Format('Total de contratos: %d', [FNegociacoesFiltradas.Count])
    );
    Printer.Canvas.TextOut(
      LMargemDireita - Printer.Canvas.TextWidth(FormatarValor(LTotalRelatorio)),
      LY,
      FormatarValor(LTotalRelatorio)
    );
  finally
    if LDocumentoIniciado then
      Printer.EndDoc;

    Printer.Orientation := LOrientacaoAnterior;
  end;
end;

procedure TfrmRelatorio.btnFiltrarClick(Sender: TObject);
begin
  CarregarLista;
end;

procedure TfrmRelatorio.btnLimparClick(Sender: TObject);
begin
  LimparFiltros;
  CarregarLista;
end;

procedure TfrmRelatorio.btnImprimirClick(Sender: TObject);
begin
  try
    CarregarLista;

    if (not Assigned(FNegociacoesFiltradas)) or
      (FNegociacoesFiltradas.Count = 0) then
    begin
      MessageDlg('Nao existem negociacoes para imprimir.', mtInformation,
        [mbOK], 0);
      Exit;
    end;

    if not dlgImpressao.Execute then
      Exit;

    ImprimirRelatorio;
    MessageDlg('Relatorio enviado para a impressora.', mtInformation,
      [mbOK], 0);
  except
    on E: Exception do
      MessageDlg(E.Message, mtWarning, [mbOK], 0);
  end;
end;

end.
