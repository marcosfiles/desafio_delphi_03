unit Domain.ValidadorCredito.Intf;

interface

type
  IValidadorCredito = interface
    ['{9329A80E-988F-4E6F-8E13-1A8353D4F891}']

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

end.

