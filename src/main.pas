unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Vcl.ImageCollection;

type
  TfrmMain = class(TForm)
    pnlLateral: TPanel;
    btnProdutores: TSpeedButton;
    btnDistribuidores: TSpeedButton;
    btnProdutos: TSpeedButton;
    btnCreditos: TSpeedButton;
    btnNegociacoes: TSpeedButton;
    btnManutencaoNegociacao: TSpeedButton;
    pnlConteudo: TPanel;
    ImageCollection1: TImageCollection;
    VirtualImageList1: TVirtualImageList;
    btnRelatorios: TSpeedButton;
    btnDashboard: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure btnProdutoresClick(Sender: TObject);
    procedure btnDistribuidoresClick(Sender: TObject);
    procedure btnProdutosClick(Sender: TObject);
    procedure btnCreditosClick(Sender: TObject);
    procedure btnNegociacoesClick(Sender: TObject);
    procedure btnManutencaoNegociacaoClick(Sender: TObject);
    procedure btnDashboardClick(Sender: TObject);
    procedure btnRelatoriosClick(Sender: TObject);
  private
    FTelaAtual: TForm;
    procedure AbrirTela(AFormClass: TFormClass);
  public
    destructor Destroy; override;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  View.CadastroProdutor,
  View.CadastroDistribuidor,
  View.CadastroProduto,
  View.CadastroCredito,
  View.Negociacao,
  View.ManutencaoNegociacao,
  View.Relatorio,
  View.Dashboard;

{$R *.dfm}

{ TForm1 }

destructor TfrmMain.Destroy;
begin
  FreeAndNil(FTelaAtual);
  inherited Destroy;
end;

procedure TfrmMain.AbrirTela(AFormClass: TFormClass);
begin
  FreeAndNil(FTelaAtual);

  FTelaAtual := AFormClass.Create(Self);
  FTelaAtual.BorderStyle := bsNone;
  FTelaAtual.Position := poDesigned;
  FTelaAtual.Parent := pnlConteudo;
  FTelaAtual.Align := alClient;
  FTelaAtual.Show;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  AbrirTela(TfrmDashboard);
end;

procedure TfrmMain.btnProdutoresClick(Sender: TObject);
begin
  AbrirTela(TfrmProdutor);
end;

procedure TfrmMain.btnDashboardClick(Sender: TObject);
begin
   AbrirTela(TfrmDashboard);
end;

procedure TfrmMain.btnDistribuidoresClick(Sender: TObject);
begin
  AbrirTela(TfrmDistribuidor);
end;

procedure TfrmMain.btnProdutosClick(Sender: TObject);
begin
  AbrirTela(TfrmProduto);
end;

procedure TfrmMain.btnCreditosClick(Sender: TObject);
begin
  AbrirTela(TfrmCredito);
end;

procedure TfrmMain.btnNegociacoesClick(Sender: TObject);
begin
  AbrirTela(TfrmNegociacao);
end;

procedure TfrmMain.btnManutencaoNegociacaoClick(Sender: TObject);
begin
  AbrirTela(TfrmManutencaoNegociacao);
end;

procedure TfrmMain.btnRelatoriosClick(Sender: TObject);
begin
  AbrirTela(TfrmRelatorio);
end;

end.
