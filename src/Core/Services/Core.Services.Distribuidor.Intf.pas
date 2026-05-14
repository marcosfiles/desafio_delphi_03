unit Core.Services.Distribuidor.Intf;

interface

uses
  System.Generics.Collections,
  Domain.Distribuidor;

type
  IDistribuidorService = interface
    ['{F4D5D481-2251-4812-8801-A95C39E0319C}']

    procedure Salvar(ADistribuidor: TDistribuidor);
    function BuscarPorId(AId: Integer): TDistribuidor;
    function ListarTodos: TObjectList<TDistribuidor>;
  end;

implementation

end.

