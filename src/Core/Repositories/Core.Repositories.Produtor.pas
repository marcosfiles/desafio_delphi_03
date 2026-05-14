unit Core.Repositories.Produtor;

interface

uses
  System.Generics.Collections,
  Domain.Produtor;

type
  IProdutorRepository = interface
    ['{A5ABEA01-AB8E-4D7E-98C3-5F3B7B9B0011}']

    procedure Inserir(AProdutor: TProdutor);
    procedure Atualizar(AProdutor: TProdutor);
    function BuscarPorId(AId: Integer): TProdutor;
    function ListarTodos: TObjectList<TProdutor>;
  end;

implementation

end.

