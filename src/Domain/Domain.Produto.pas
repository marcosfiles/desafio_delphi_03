unit Domain.Produto;

interface

uses
  System.SysUtils;

type
  TProduto = class
  private
    FId: Integer;
    FNome: string;
    FPrecoVenda: Currency;
    FAtivo: Boolean;
    FDataCadastro: TDateTime;

    procedure SetNome(const Value: string);
    procedure SetPrecoVenda(const Value: Currency);
  public
    constructor Create;

    procedure Validar;

    property Id: Integer read FId write FId;
    property Nome: string read FNome write SetNome;
    property PrecoVenda: Currency read FPrecoVenda write SetPrecoVenda;
    property Ativo: Boolean read FAtivo write FAtivo;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
  end;

implementation

{ TProduto }

constructor TProduto.Create;
begin
  inherited Create;
  FAtivo := True;
  FDataCadastro := Now;
  FPrecoVenda := 0;
end;

procedure TProduto.SetNome(const Value: string);
begin
  FNome := Trim(Value);
end;

procedure TProduto.SetPrecoVenda(const Value: Currency);
begin
  FPrecoVenda := Value;
end;

procedure TProduto.Validar;
begin
  if FNome = '' then
    raise Exception.Create('Informe o nome do produto.');

  if FPrecoVenda < 0 then
    raise Exception.Create('Preco de venda nao pode ser negativo.');
end;

end.

