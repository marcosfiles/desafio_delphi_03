unit Domain.ValidadorCredito.Padrao;

interface

uses
  System.SysUtils,
  Core.Repositories.Credito,
  Core.Repositories.Negociacao,
  Domain.ValidadorCredito.Intf;

type
  TValidadorCreditoPadrao = class(TInterfacedObject, IValidadorCredito)
  private
    FCreditoRepository: ICreditoRepository;
    FNegociacaoRepository: INegociacaoRepository;
  public
    constructor Create(
      ACreditoRepository: ICreditoRepository;
      ANegociacaoRepository: INegociacaoRepository
    );

    procedure Validar(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer;
      AValorNegociacao: Currency;
      AIdNegociacaoIgnorar: Integer = 0
    );

    function ObterCreditoDisponivel(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer;
      AIdNegociacaoIgnorar: Integer = 0
    ): Currency;
  end;

implementation

{ TValidadorCreditoPadrao }

constructor TValidadorCreditoPadrao.Create(
  ACreditoRepository: ICreditoRepository;
  ANegociacaoRepository: INegociacaoRepository);
begin
  inherited Create;
  FCreditoRepository := ACreditoRepository;
  FNegociacaoRepository := ANegociacaoRepository;
end;

procedure TValidadorCreditoPadrao.Validar(
  AIdProdutor: Integer;
  AIdDistribuidor: Integer;
  AValorNegociacao: Currency;
  AIdNegociacaoIgnorar: Integer);
var
  LLimiteCredito: Currency;
  LTotalAprovado: Currency;
begin
  if AIdProdutor <= 0 then
    raise Exception.Create('Produtor nao informado para validacao de credito.');

  if AIdDistribuidor <= 0 then
    raise Exception.Create('Distribuidor nao informado para validacao de credito.');

  if AValorNegociacao <= 0 then
    raise Exception.Create('Valor da negociacao deve ser maior que zero.');

  LLimiteCredito := FCreditoRepository.ObterLimite(AIdProdutor, AIdDistribuidor);
  LTotalAprovado := FNegociacaoRepository.TotalAprovado(
    AIdProdutor,
    AIdDistribuidor,
    AIdNegociacaoIgnorar
  );

  if (LTotalAprovado + AValorNegociacao) > LLimiteCredito then
    raise Exception.CreateFmt(
      'Limite de credito insuficiente. Limite: %.3f, aprovado: %.3f, negociacao: %.3f.',
      [LLimiteCredito, LTotalAprovado, AValorNegociacao]
    );
end;

function TValidadorCreditoPadrao.ObterCreditoDisponivel(
  AIdProdutor: Integer;
  AIdDistribuidor: Integer;
  AIdNegociacaoIgnorar: Integer): Currency;
var
  LLimiteCredito: Currency;
  LTotalAprovado: Currency;
begin
  if AIdProdutor <= 0 then
    raise Exception.Create('Produtor nao informado para consulta de credito.');

  if AIdDistribuidor <= 0 then
    raise Exception.Create('Distribuidor nao informado para consulta de credito.');

  LLimiteCredito := FCreditoRepository.ObterLimite(AIdProdutor, AIdDistribuidor);
  LTotalAprovado := FNegociacaoRepository.TotalAprovado(
    AIdProdutor,
    AIdDistribuidor,
    AIdNegociacaoIgnorar
  );

  Result := LLimiteCredito - LTotalAprovado;
end;

end.

