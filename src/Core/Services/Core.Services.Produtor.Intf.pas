unit Core.Services.Produtor.Intf;

interface

uses
  System.Generics.Collections,
  Domain.Produtor;

type
  IProdutorService = interface
    ['{9EA6152A-8F67-4B47-AF12-E1BBA51871AA}']

    procedure Salvar(AProdutor: TProdutor);
    function BuscarPorId(AId: Integer): TProdutor;
    function ListarTodos: TObjectList<TProdutor>;
  end;

implementation

end.

