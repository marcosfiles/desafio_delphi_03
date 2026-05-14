unit Core.Services.Negociacao.Intf;

interface

uses
  System.Generics.Collections,
  Domain.Negociacao;

type
  INegociacaoService = interface
    ['{A8BB18F1-C5BD-4C98-B28B-4D4C2C4B77A1}']

    procedure Salvar(ANegociacao: TNegociacao);
    function BuscarPorId(AId: Integer): TNegociacao;
    function ListarTodos: TObjectList<TNegociacao>;
    function ObterCreditoDisponivel(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer;
      AIdNegociacaoIgnorar: Integer = 0
    ): Currency;

    procedure Aprovar(AIdNegociacao: Integer);
    procedure Concluir(AIdNegociacao: Integer);
    procedure Cancelar(AIdNegociacao: Integer);
  end;

implementation

end.

