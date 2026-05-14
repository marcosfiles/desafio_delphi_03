unit Core.Repositories.Distribuidor;

interface

uses
  System.Generics.Collections,
  Domain.Distribuidor;

type
  IDistribuidorRepository = interface
    ['{E51F5B48-88AD-4B97-9BA5-9235D5F1C23A}']

    procedure Inserir(ADistribuidor: TDistribuidor);
    procedure Atualizar(ADistribuidor: TDistribuidor);
    function BuscarPorId(AId: Integer): TDistribuidor;
    function ListarTodos: TObjectList<TDistribuidor>;
  end;

implementation

end.

