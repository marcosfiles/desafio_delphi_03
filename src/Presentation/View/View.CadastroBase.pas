unit View.CadastroBase;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection;

type TModoCadastro = (mcNavegacao,mcInclusao,mcEdicao);

type
  TfrmCadastroBase = class(TForm)
    ImageCollection1: TImageCollection;
    VirtualImageList1: TVirtualImageList;
  private
    FModo: TModoCadastro;
    procedure SetModo(const AModo: TModoCadastro);
  protected
    procedure Novo; virtual;
    procedure Editar; virtual;
    procedure Salvar; virtual;
    procedure Cancelar; virtual;

    procedure CarregarLista; virtual;
    procedure LimparCampos; virtual;
    procedure HabilitarCampos(AHabilitar: Boolean); virtual;
    procedure HabilitarBotoes; virtual;
    procedure ValidarCampos; virtual;
    function PodeSalvar: Boolean; virtual;
    procedure PersistirDados; virtual;

    property Modo: TModoCadastro read FModo write SetModo;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  frmCadastroBase: TfrmCadastroBase;

implementation

{$R *.dfm}

{ TForm2 }

constructor TfrmCadastroBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FModo := mcNavegacao;
end;

procedure TfrmCadastroBase.SetModo(const AModo: TModoCadastro);
begin
  FModo := AModo;
  HabilitarCampos(FModo in [mcInclusao, mcEdicao]);
  HabilitarBotoes;
end;

procedure TfrmCadastroBase.Cancelar;
begin
  LimparCampos;
  Modo := mcNavegacao;
end;

procedure TfrmCadastroBase.CarregarLista;
begin
    //implementado nas telas filhas quando necessario
end;


procedure TfrmCadastroBase.Editar;
begin
  Modo := mcEdicao;
end;

procedure TfrmCadastroBase.HabilitarBotoes;
begin
    //implementado nas telas filhas
end;

procedure TfrmCadastroBase.HabilitarCampos(AHabilitar: Boolean);
begin
    //implementado nas telas filhas
end;

procedure TfrmCadastroBase.LimparCampos;
begin
    //implementado nas telas filhas
end;

procedure TfrmCadastroBase.Novo;
begin
  LimparCampos;
  Modo := mcInclusao;

end;

procedure TfrmCadastroBase.PersistirDados;
begin
//implementado nas telas filhas
end;

function TfrmCadastroBase.PodeSalvar: Boolean;
begin
  Result := True;

end;

procedure TfrmCadastroBase.Salvar;
begin
  if not PodeSalvar then
    Exit;

  ValidarCampos;

  PersistirDados;

  Modo := mcNavegacao;
  CarregarLista;

end;



procedure TfrmCadastroBase.ValidarCampos;
begin
  //implementado nas telas filhas
end;

end.
