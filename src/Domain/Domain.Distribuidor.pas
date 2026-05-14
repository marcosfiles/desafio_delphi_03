unit Domain.Distribuidor;

interface

uses
  System.SysUtils;

type
  TDistribuidor = class
  private
    FId: Integer;
    FNome: string;
    FCnpj: string;
    FAtivo: Boolean;
    FDataCadastro: TDateTime;

    procedure SetNome(const Value: string);
    procedure SetCnpj(const Value: string);
  public
    constructor Create;

    procedure Validar;

    property Id: Integer read FId write FId;
    property Nome: string read FNome write SetNome;
    property Cnpj: string read FCnpj write SetCnpj;
    property Ativo: Boolean read FAtivo write FAtivo;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
  end;

implementation

{ TDistribuidor }

constructor TDistribuidor.Create;
begin
  inherited Create;
  FAtivo := True;
  FDataCadastro := Now;
end;

procedure TDistribuidor.SetNome(const Value: string);
begin
  FNome := Trim(Value);
end;

procedure TDistribuidor.SetCnpj(const Value: string);
begin
  FCnpj := Trim(Value);
end;

procedure TDistribuidor.Validar;
begin
  if FNome = '' then
    raise Exception.Create('Informe o nome do distribuidor.');

  if FCnpj = '' then
    raise Exception.Create('Informe o CNPJ do distribuidor.');

  if Length(FCnpj) <> 14 then
    raise Exception.Create('CNPJ deve conter 14 digitos.');
end;

end.

