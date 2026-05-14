unit Core.Services.Produto.Intf;

interface

uses
  System.Generics.Collections,
  Domain.Produto;

type
  IProdutoService = interface
    ['{4BBAB621-61C5-4F7F-9E06-070D862DE4C8}']

    procedure Salvar(AProduto: TProduto);
    function BuscarPorId(AId: Integer): TProduto;
    function ListarTodos: TObjectList<TProduto>;
  end;

implementation

end.

