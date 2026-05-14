unit Domain.NegociacaoItem;

interface

uses
  System.SysUtils;

type
  TNegociacaoItem = class
  private
    FId: Integer;
    FIdNegociacao: Integer;
    FIdProduto: Integer;
    FProdutoNome: string;
    FQuantidade: Currency;
    FPrecoUnitario: Currency;
    FValorTotal: Currency;

    procedure SetProdutoNome(const Value: string);
    procedure SetQuantidade(const Value: Currency);
    procedure SetPrecoUnitario(const Value: Currency);
    procedure RecalcularTotal;
  public
    constructor Create;

    procedure Validar;

    property Id: Integer read FId write FId;
    property IdNegociacao: Integer read FIdNegociacao write FIdNegociacao;
    property IdProduto: Integer read FIdProduto write FIdProduto;
    property ProdutoNome: string read FProdutoNome write SetProdutoNome;
    property Quantidade: Currency read FQuantidade write SetQuantidade;
    property PrecoUnitario: Currency read FPrecoUnitario write SetPrecoUnitario;

    //ValorTotal não tem setter público. Ele é sempre calculado por RecalcularTotal.
    //Isso evita inconsistência
    property ValorTotal: Currency read FValorTotal;
  end;

implementation

{ TNegociacaoItem }

constructor TNegociacaoItem.Create;
begin
  inherited Create;
  FQuantidade := 0;
  FPrecoUnitario := 0;
  FValorTotal := 0;
end;

procedure TNegociacaoItem.SetProdutoNome(const Value: string);
begin
  FProdutoNome := Trim(Value);
end;

procedure TNegociacaoItem.SetQuantidade(const Value: Currency);
begin
  FQuantidade := Value;
  RecalcularTotal;
end;

procedure TNegociacaoItem.SetPrecoUnitario(const Value: Currency);
begin
  FPrecoUnitario := Value;
  RecalcularTotal;
end;

procedure TNegociacaoItem.RecalcularTotal;
begin
  FValorTotal := FQuantidade * FPrecoUnitario;
end;

procedure TNegociacaoItem.Validar;
begin
  if FIdProduto <= 0 then
    raise Exception.Create('Informe o produto do item.');

  if FQuantidade <= 0 then
    raise Exception.Create('Quantidade do item deve ser maior que zero.');

  if FPrecoUnitario < 0 then
    raise Exception.Create('Preco unitario do item nao pode ser negativo.');
end;

end.

