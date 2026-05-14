unit Domain.CreditoProdutorDistribuidor;

interface

uses
  System.SysUtils;

type
  TCreditoProdutorDistribuidor = class
  private
    FId: Integer;
    FIdProdutor: Integer;
    FIdDistribuidor: Integer;
    FLimiteCredito: Currency;
    FDataCadastro: TDateTime;
    FDataAlteracao: TDateTime;

    procedure SetLimiteCredito(const Value: Currency);
  public
    constructor Create;

    procedure Validar;

    property Id: Integer read FId write FId;
    property IdProdutor: Integer read FIdProdutor write FIdProdutor;
    property IdDistribuidor: Integer read FIdDistribuidor write FIdDistribuidor;
    property LimiteCredito: Currency read FLimiteCredito write SetLimiteCredito;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
    property DataAlteracao: TDateTime read FDataAlteracao write FDataAlteracao;
  end;

implementation

{ TCreditoProdutorDistribuidor }

constructor TCreditoProdutorDistribuidor.Create;
begin
  inherited Create;
  FLimiteCredito := 0;
  FDataCadastro := Now;
end;

procedure TCreditoProdutorDistribuidor.SetLimiteCredito(const Value: Currency);
begin
  FLimiteCredito := Value;
end;

procedure TCreditoProdutorDistribuidor.Validar;
begin
  if FIdProdutor <= 0 then
    raise Exception.Create('Informe o produtor do limite de credito.');

  if FIdDistribuidor <= 0 then
    raise Exception.Create('Informe o distribuidor do limite de credito.');

  if FLimiteCredito < 0 then
    raise Exception.Create('Limite de credito nao pode ser negativo.');
end;

end.

