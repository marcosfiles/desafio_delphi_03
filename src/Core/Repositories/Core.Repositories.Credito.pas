unit Core.Repositories.Credito;

interface

uses
  System.Generics.Collections,
  Domain.CreditoProdutorDistribuidor;

type
  ICreditoRepository = interface
    ['{A90DD9A7-B541-4774-93E7-40E39B35A89D}']

    procedure Inserir(ACredito: TCreditoProdutorDistribuidor);
    procedure Atualizar(ACredito: TCreditoProdutorDistribuidor);
    function BuscarPorId(AId: Integer): TCreditoProdutorDistribuidor;
    function BuscarPorProdutorDistribuidor(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer
    ): TCreditoProdutorDistribuidor;
    function ListarTodos: TObjectList<TCreditoProdutorDistribuidor>;
    function ObterLimite(
      AIdProdutor: Integer;
      AIdDistribuidor: Integer
    ): Currency;
  end;

implementation

end.

