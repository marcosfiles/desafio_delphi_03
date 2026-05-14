unit Core.Services.Credito.Intf;

interface

uses
  System.Generics.Collections,
  Domain.CreditoProdutorDistribuidor;

type
  ICreditoService = interface
    ['{984FBEEA-B056-47BD-B048-17204EB38B54}']

    procedure Salvar(ACredito: TCreditoProdutorDistribuidor);

    function BuscarPorId(AId: Integer): TCreditoProdutorDistribuidor;

    function BuscarPorProdutorDistribuidor(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer
    ): TCreditoProdutorDistribuidor;

    function ListarTodos: TObjectList<TCreditoProdutorDistribuidor>;
  end;

implementation

end.

