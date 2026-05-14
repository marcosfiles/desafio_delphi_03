unit Domain.Produtor;

interface
uses System.SysUtils;

type TProdutor = class
  private
    FId: Integer;
    FNome: string;
    FCpfCnpj: string;
    FAtivo: Boolean;
    FDataCadastro: TDateTime;

    procedure SetNome(const ANome: String);
    procedure SetCpfCnpj(const ACpfCnpj: String);
  public
    constructor Create;
    procedure Validar;

    property Id: Integer read FId write FId;
    property Nome: string read FNome write SetNome;
    property CpfCnpj: String read FCpfCnpj write SetCpfCnpj;
    property Ativo: Boolean read FAtivo write FAtivo;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
end;

implementation

{ TProdutor }

constructor TProdutor.Create;
begin
  inherited Create;
  FAtivo := True;
  FDataCadastro := Now;
end;

procedure TProdutor.SetCpfCnpj(const ACpfCnpj: String);
begin
  FCpfCnpj := Trim(ACpfCnpj);
end;

procedure TProdutor.SetNome(const ANome: String);
begin
  FNome := Trim(ANome);

end;

procedure TProdutor.Validar;
begin
  if FNome = '' then
    raise Exception.Create('Informe o nome do produtor.');

  if CpfCnpj = '' then
    raise Exception.Create('Informe o CPF/CNPJ do produtor.');

  if not (Length(FCpfCnpj) in [11, 14]) then
    raise Exception.Create('CPF/CNPJ do produtor deve conter 11 ou 14 digitos.');

end;

end.
