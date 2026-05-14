unit Domain.Negociacao;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  App.Types,
  Domain.NegociacaoItem;

type
  TNegociacao = class
  private
    FId: Integer;
    FIdProdutor: Integer;
    FProdutorNome: string;
    FIdDistribuidor: Integer;
    FDistribuidorNome: string;
    FStatus: TStatusNegociacao;
    FValorTotal: Currency;
    FDataCadastro: TDateTime;
    FDataAprovacao: TDateTime;
    FDataConclusao: TDateTime;
    FDataCancelamento: TDateTime;
    FItens: TObjectList<TNegociacaoItem>;

    procedure SetProdutorNome(const Value: string);
    procedure SetDistribuidorNome(const Value: string);
    procedure RecalcularTotal;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AdicionarItem(AItem: TNegociacaoItem);
    procedure RemoverItem(AItem: TNegociacaoItem);
    procedure LimparItens;
    procedure Validar;

    property Id: Integer read FId write FId;
    property IdProdutor: Integer read FIdProdutor write FIdProdutor;
    property ProdutorNome: string read FProdutorNome write SetProdutorNome;
    property IdDistribuidor: Integer read FIdDistribuidor write FIdDistribuidor;
    property DistribuidorNome: string read FDistribuidorNome write SetDistribuidorNome;
    property Status: TStatusNegociacao read FStatus write FStatus;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
    property DataAprovacao: TDateTime read FDataAprovacao write FDataAprovacao;
    property DataConclusao: TDateTime read FDataConclusao write FDataConclusao;
    property DataCancelamento: TDateTime read FDataCancelamento write FDataCancelamento;
    property Itens: TObjectList<TNegociacaoItem> read FItens;
  end;

implementation

{ TNegociacao }

constructor TNegociacao.Create;
begin
  inherited Create;
  FStatus := snPendente;
  FDataCadastro := Now;
  FValorTotal := 0;
  FItens := TObjectList<TNegociacaoItem>.Create(True);
end;

destructor TNegociacao.Destroy;
begin
  FItens.Free;
  inherited Destroy;
end;

procedure TNegociacao.SetProdutorNome(const Value: string);
begin
  FProdutorNome := Trim(Value);
end;

procedure TNegociacao.SetDistribuidorNome(const Value: string);
begin
  FDistribuidorNome := Trim(Value);
end;

procedure TNegociacao.AdicionarItem(AItem: TNegociacaoItem);
begin
  if not Assigned(AItem) then
    raise Exception.Create('Item da negociacao nao informado.');

  AItem.Validar;
  FItens.Add(AItem);
  RecalcularTotal;
end;

procedure TNegociacao.RemoverItem(AItem: TNegociacaoItem);
begin
  FItens.Remove(AItem);
  RecalcularTotal;
end;

procedure TNegociacao.LimparItens;
begin
  FItens.Clear;
  RecalcularTotal;
end;

procedure TNegociacao.RecalcularTotal;
var
  LItem: TNegociacaoItem;
begin
  FValorTotal := 0;

  for LItem in FItens do
    FValorTotal := FValorTotal + LItem.ValorTotal;
end;

procedure TNegociacao.Validar;
var
  LItem: TNegociacaoItem;
begin
  if FIdProdutor <= 0 then
    raise Exception.Create('Informe o produtor da negociacao.');

  if FIdDistribuidor <= 0 then
    raise Exception.Create('Informe o distribuidor da negociacao.');

  if FItens.Count = 0 then
    raise Exception.Create('Informe ao menos um item na negociacao.');

  for LItem in FItens do
    LItem.Validar;

  RecalcularTotal;

  if FValorTotal <= 0 then
    raise Exception.Create('Valor total da negociacao deve ser maior que zero.');
end;

end.

