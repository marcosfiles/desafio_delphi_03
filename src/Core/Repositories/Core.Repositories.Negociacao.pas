unit Core.Repositories.Negociacao;

interface

uses
  System.Generics.Collections,
  Domain.Negociacao;

type
  INegociacaoRepository = interface
    ['{1A3C907C-04CB-4E4E-9710-62E5429464D0}']

    procedure Inserir(ANegociacao: TNegociacao);
    procedure Atualizar(ANegociacao: TNegociacao);
    function BuscarPorId(AId: Integer): TNegociacao;
    function ListarTodos: TObjectList<TNegociacao>;

    function TotalAprovado(
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

