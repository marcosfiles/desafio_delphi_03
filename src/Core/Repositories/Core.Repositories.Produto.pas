unit Core.Repositories.Produto;

interface

uses
  System.Generics.Collections,
  Domain.Produto;

type
  IProdutoRepository = interface
    ['{B4048F7D-F409-4C87-9310-B7F6F8AB2120}']

    procedure Inserir(AProduto: TProduto);
    procedure Atualizar(AProduto: TProduto);
    function BuscarPorId(AId: Integer): TProduto;
    function ListarTodos: TObjectList<TProduto>;
  end;

implementation

end.

